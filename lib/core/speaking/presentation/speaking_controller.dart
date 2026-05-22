import 'dart:async';

import 'package:ai_teacher/app/data/network_config.dart';
import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/core/speaking/data/speaking_repository.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

enum SpeakingPhase { idle, recording, processing, speaking, error }

class SpeakingTurn {
  const SpeakingTurn({required this.role, required this.transcript});

  final String role; // 'user' | 'assistant'
  final String transcript;
}

class SpeakingState {
  const SpeakingState({
    this.phase = SpeakingPhase.idle,
    this.elapsed = Duration.zero,
    this.lastUserTranscript,
    this.lastReplyTranscript,
    this.conversationId,
    this.turns = const [],
    this.amplitudes = const [],
    this.readyForAnalyze = false,
    this.analyzingReport = false,
    this.error,
  });

  final SpeakingPhase phase;
  final Duration elapsed;
  final String? lastUserTranscript;
  final String? lastReplyTranscript;
  final String? conversationId;
  final List<SpeakingTurn> turns;

  /// Rolling buffer of normalized mic amplitudes (0..1) while recording.
  final List<double> amplitudes;

  /// Server says there's enough speech to generate a speaking report.
  final bool readyForAnalyze;

  /// Report generation in flight (POST /assessments/conversation/:id/report).
  final bool analyzingReport;
  final String? error;

  bool get isRecording => phase == SpeakingPhase.recording;

  bool get isBusy =>
      phase == SpeakingPhase.processing ||
      phase == SpeakingPhase.speaking ||
      analyzingReport;

  SpeakingState copyWith({
    SpeakingPhase? phase,
    Duration? elapsed,
    Object? lastUserTranscript = _sentinel,
    Object? lastReplyTranscript = _sentinel,
    Object? conversationId = _sentinel,
    List<SpeakingTurn>? turns,
    List<double>? amplitudes,
    bool? readyForAnalyze,
    bool? analyzingReport,
    Object? error = _sentinel,
  }) {
    return SpeakingState(
      phase: phase ?? this.phase,
      elapsed: elapsed ?? this.elapsed,
      lastUserTranscript: identical(lastUserTranscript, _sentinel)
          ? this.lastUserTranscript
          : lastUserTranscript as String?,
      lastReplyTranscript: identical(lastReplyTranscript, _sentinel)
          ? this.lastReplyTranscript
          : lastReplyTranscript as String?,
      conversationId: identical(conversationId, _sentinel)
          ? this.conversationId
          : conversationId as String?,
      turns: turns ?? this.turns,
      amplitudes: amplitudes ?? this.amplitudes,
      readyForAnalyze: readyForAnalyze ?? this.readyForAnalyze,
      analyzingReport: analyzingReport ?? this.analyzingReport,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();

final speakingControllerProvider =
    NotifierProvider<SpeakingController, SpeakingState>(SpeakingController.new);

class SpeakingController extends Notifier<SpeakingState> {
  AudioRecorder? _recorder;
  AudioPlayer? _player;
  StreamSubscription<void>? _playerCompleteSub;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Timer? _ticker;
  final Stopwatch _stopwatch = Stopwatch();
  String? _recordingPath;

  static const int _amplitudeHistory = 40;

  @override
  SpeakingState build() {
    ref.onDispose(_disposeAll);
    return const SpeakingState();
  }

  Future<void> _disposeAll() async {
    _ticker?.cancel();
    _ticker = null;
    try {
      await _playerCompleteSub?.cancel();
    } catch (_) {}
    _playerCompleteSub = null;
    try {
      await _amplitudeSub?.cancel();
    } catch (_) {}
    _amplitudeSub = null;
    try {
      await _recorder?.dispose();
    } catch (_) {}
    _recorder = null;
    try {
      await _player?.dispose();
    } catch (_) {}
    _player = null;
  }

  Future<void> startRecording() async {
    if (state.isRecording || state.isBusy) return;
    final recorder = _recorder ??= AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        state = state.copyWith(
          phase: SpeakingPhase.error,
          error: 'Mikrofonga ruxsat berilmagan. Sozlamalardan yoqing.',
        );
        return;
      }

      // Stop any AI playback when the user starts to speak.
      await _player?.stop();

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/turn_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 44100),
        path: path,
      );
      _recordingPath = path;
      _stopwatch
        ..reset()
        ..start();
      state = state.copyWith(
        phase: SpeakingPhase.recording,
        elapsed: Duration.zero,
        amplitudes: const [],
        error: null,
      );
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (state.phase == SpeakingPhase.recording) {
          state = state.copyWith(elapsed: _stopwatch.elapsed);
        }
      });
      await _amplitudeSub?.cancel();
      _amplitudeSub = recorder
          .onAmplitudeChanged(const Duration(milliseconds: 80))
          .listen(_onAmplitude);
    } catch (e) {
      state = state.copyWith(
        phase: SpeakingPhase.error,
        error: 'Yozib olishda xatolik: $e',
      );
    }
  }

  void _onAmplitude(Amplitude amp) {
    if (state.phase != SpeakingPhase.recording) return;
    // amp.current is in dBFS (~-160..0). Map ~-50..0 to 0..1.
    final db = amp.current;
    final normalized = ((db + 50) / 50).clamp(0.0, 1.0);
    final next = List<double>.from(state.amplitudes)..add(normalized);
    if (next.length > _amplitudeHistory) {
      next.removeRange(0, next.length - _amplitudeHistory);
    }
    state = state.copyWith(amplitudes: next);
  }

  /// Stops the current recording and sends it as the next conversation turn.
  /// Auto-plays the assistant's audio reply when available.
  Future<void> stopAndSend() async {
    if (state.phase != SpeakingPhase.recording) return;
    final recorder = _recorder;
    if (recorder == null) return;

    _ticker?.cancel();
    _ticker = null;
    _stopwatch.stop();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    state = state.copyWith(
      phase: SpeakingPhase.processing,
      amplitudes: const [],
    );

    String? path;
    try {
      path = await recorder.stop();
    } catch (e) {
      state = state.copyWith(
        phase: SpeakingPhase.error,
        error: "Yozuvni to'xtatib bo'lmadi: $e",
      );
      return;
    }
    final filePath = path ?? _recordingPath;
    if (filePath == null) {
      state = state.copyWith(
        phase: SpeakingPhase.error,
        error: 'Audio fayl topilmadi',
      );
      return;
    }

    try {
      final repo = ref.read(speakingRepositoryProvider);
      final result = await repo.converse(
        filePath: filePath,
        mimeType: 'audio/aac',
        conversationId: state.conversationId,
      );
      final nextTurns = <SpeakingTurn>[
        ...state.turns,
        SpeakingTurn(role: 'user', transcript: result.userTranscript),
        SpeakingTurn(role: 'assistant', transcript: result.reply.transcript),
      ];
      state = state.copyWith(
        phase: SpeakingPhase.speaking,
        conversationId: result.conversationId,
        lastUserTranscript: result.userTranscript,
        lastReplyTranscript: result.reply.transcript,
        turns: nextTurns,
        readyForAnalyze: result.readyForAnalyze,
        error: null,
      );
      await _playReply(result.reply.audioUrl);
    } catch (e, st) {
      debugPrint('converse failed: $e\n$st');
      state = state.copyWith(
        phase: SpeakingPhase.error,
        error: 'Yuborishda xatolik. Qaytadan urinib koring.',
      );
    }
  }

  Future<void> _playReply(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      state = state.copyWith(phase: SpeakingPhase.idle);
      return;
    }
    final fullUrl = NetworkConfig.resolveStatic(audioUrl);
    try {
      _player ??= AudioPlayer();
      await _playerCompleteSub?.cancel();
      _playerCompleteSub = _player!.onPlayerComplete.listen((_) {
        if (state.phase == SpeakingPhase.speaking) {
          state = state.copyWith(phase: SpeakingPhase.idle);
        }
      });
      await _player!.stop();
      await _player!.play(UrlSource(fullUrl));
    } catch (e) {
      debugPrint('reply playback failed: $e');
      state = state.copyWith(phase: SpeakingPhase.idle);
    }
  }

  /// Generates a speaking report for the active conversation. Returns the
  /// report on success; null on failure. The screen should navigate to the
  /// report view when a non-null result is returned.
  Future<Assessment?> requestReport() async {
    final id = state.conversationId;
    if (id == null || state.analyzingReport) return null;
    state = state.copyWith(analyzingReport: true, error: null);
    try {
      await _player?.stop();
      final repo = ref.read(speakingRepositoryProvider);
      final report = await repo.analyzeConversation(id);
      state = state.copyWith(analyzingReport: false);
      return report;
    } catch (e, st) {
      debugPrint('analyzeConversation failed: $e\n$st');
      state = state.copyWith(
        analyzingReport: false,
        error: "Hisobotni tayyorlab bo'lmadi. Qaytadan urinib koring.",
        phase: SpeakingPhase.error,
      );
      return null;
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player?.stop();
    } catch (_) {}
    if (state.phase == SpeakingPhase.speaking) {
      state = state.copyWith(phase: SpeakingPhase.idle);
    }
  }

  void resetError() {
    if (state.phase == SpeakingPhase.error) {
      state = state.copyWith(phase: SpeakingPhase.idle, error: null);
    }
  }

  /// End the current conversation and start fresh on the next mic press.
  void endConversation() {
    _player?.stop();
    state = const SpeakingState();
  }
}
