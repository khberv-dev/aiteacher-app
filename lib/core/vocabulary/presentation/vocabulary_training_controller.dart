import 'dart:async';
import 'dart:io';

import 'package:ai_teacher/core/vocabulary/data/speaking_evaluation.dart';
import 'package:ai_teacher/core/vocabulary/data/vocabulary_repository.dart';
import 'package:ai_teacher/core/vocabulary/data/vocabulary_word.dart';
import 'package:ai_teacher/core/vocabulary/data/word_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Sub-phase tracked for the audio-driven speaking check that can be
/// run from inside a training session.
enum SpeakingCheckPhase {
  /// No speaking check in flight — the regular Bilaman/Bilmadim buttons
  /// (or the mic button) are usable.
  idle,

  /// Microphone permission granted and the recorder is capturing audio.
  recording,

  /// Audio file uploaded; waiting for the server's Gemini evaluation.
  checking,

  /// Evaluation returned and is being shown to the learner.
  showingResult,
}

/// In-memory state of an active training session.
@immutable
class VocabularyTrainingState {
  const VocabularyTrainingState({
    required this.batch,
    required this.currentIndex,
    required this.correct,
    required this.incorrect,
    this.stats,
    this.speakingPhase = SpeakingCheckPhase.idle,
    this.recordingElapsed = Duration.zero,
    this.lastEvaluation,
    this.speakingError,
  });

  /// Words to walk through this session, in order.
  final List<VocabularyWord> batch;

  /// 0-based pointer into [batch]. When equal to `batch.length` the
  /// session is finished and the summary should be shown instead.
  final int currentIndex;

  final int correct;
  final int incorrect;

  /// Snapshot of the per-status totals at session start. Used to colour
  /// the summary header; null while it loads in the background.
  final Map<WordStatus, int>? stats;

  final SpeakingCheckPhase speakingPhase;
  final Duration recordingElapsed;
  final SpeakingEvaluation? lastEvaluation;
  final String? speakingError;

  bool get isEmpty => batch.isEmpty;

  bool get isDone => batch.isNotEmpty && currentIndex >= batch.length;

  VocabularyWord? get current => isDone || isEmpty ? null : batch[currentIndex];

  VocabularyTrainingState copyWith({
    List<VocabularyWord>? batch,
    int? currentIndex,
    int? correct,
    int? incorrect,
    Map<WordStatus, int>? stats,
    SpeakingCheckPhase? speakingPhase,
    Duration? recordingElapsed,
    SpeakingEvaluation? lastEvaluation,
    Object? speakingError = _sentinel,
    bool clearEvaluation = false,
  }) {
    return VocabularyTrainingState(
      batch: batch ?? this.batch,
      currentIndex: currentIndex ?? this.currentIndex,
      correct: correct ?? this.correct,
      incorrect: incorrect ?? this.incorrect,
      stats: stats ?? this.stats,
      speakingPhase: speakingPhase ?? this.speakingPhase,
      recordingElapsed: recordingElapsed ?? this.recordingElapsed,
      lastEvaluation: clearEvaluation
          ? null
          : (lastEvaluation ?? this.lastEvaluation),
      speakingError: identical(speakingError, _sentinel)
          ? this.speakingError
          : speakingError as String?,
    );
  }
}

const Object _sentinel = Object();

class VocabularyTrainingController
    extends AutoDisposeAsyncNotifier<VocabularyTrainingState> {
  AudioRecorder? _recorder;
  Timer? _recordingTicker;
  final Stopwatch _recordingStopwatch = Stopwatch();
  String? _recordingPath;

  @override
  Future<VocabularyTrainingState> build() async {
    ref.onDispose(_disposeAudio);
    final repo = ref.read(vocabularyRepositoryProvider);
    final batch = await repo.getTrainingBatch();
    // Fire-and-forget stats so the first card paints sooner.
    unawaited(
      repo
          .stats()
          .then((s) {
            final cur = state.valueOrNull;
            if (cur != null) state = AsyncData(cur.copyWith(stats: s));
          })
          .catchError((_) {}),
    );
    return VocabularyTrainingState(
      batch: batch,
      currentIndex: 0,
      correct: 0,
      incorrect: 0,
    );
  }

  Future<void> _disposeAudio() async {
    _recordingTicker?.cancel();
    _recordingTicker = null;
    _recordingStopwatch.stop();
    try {
      if (await _recorder?.isRecording() ?? false) {
        await _recorder?.stop();
      }
      await _recorder?.dispose();
    } catch (_) {}
    _recorder = null;
    final path = _recordingPath;
    _recordingPath = null;
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  VocabularyTrainingState _advance(VocabularyTrainingState s, bool correct) {
    return s.copyWith(
      currentIndex: s.currentIndex + 1,
      correct: s.correct + (correct ? 1 : 0),
      incorrect: s.incorrect + (correct ? 0 : 1),
      speakingPhase: SpeakingCheckPhase.idle,
      recordingElapsed: Duration.zero,
      clearEvaluation: true,
      speakingError: null,
    );
  }

  /// Starts capturing microphone audio for the current word. No-op if
  /// already busy or out of cards.
  Future<void> startSpeaking() async {
    final s = state.valueOrNull;
    if (s == null || s.isDone || s.isEmpty) return;
    if (s.speakingPhase != SpeakingCheckPhase.idle) return;

    final recorder = _recorder ??= AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        state = AsyncData(
          s.copyWith(
            speakingError:
                'Mikrofonga ruxsat berilmagan. Sozlamalardan yoqing.',
          ),
        );
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/vocab_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 44100),
        path: path,
      );
      _recordingPath = path;
      _recordingStopwatch
        ..reset()
        ..start();
      state = AsyncData(
        s.copyWith(
          speakingPhase: SpeakingCheckPhase.recording,
          recordingElapsed: Duration.zero,
          speakingError: null,
        ),
      );
      _recordingTicker?.cancel();
      _recordingTicker = Timer.periodic(const Duration(milliseconds: 250), (_) {
        final cur = state.valueOrNull;
        if (cur == null) return;
        if (cur.speakingPhase != SpeakingCheckPhase.recording) return;
        state = AsyncData(
          cur.copyWith(recordingElapsed: _recordingStopwatch.elapsed),
        );
      });
    } catch (e) {
      state = AsyncData(
        s.copyWith(
          speakingPhase: SpeakingCheckPhase.idle,
          speakingError: 'Yozib olishda xatolik: $e',
        ),
      );
    }
  }

  /// Cancels an in-progress recording (e.g. user hit "back" on the
  /// recording UI). Does NOT send the audio.
  Future<void> cancelSpeaking() async {
    final s = state.valueOrNull;
    if (s == null) return;
    if (s.speakingPhase != SpeakingCheckPhase.recording) return;
    _recordingTicker?.cancel();
    _recordingTicker = null;
    _recordingStopwatch.stop();
    try {
      await _recorder?.stop();
    } catch (_) {}
    final path = _recordingPath;
    _recordingPath = null;
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
    state = AsyncData(
      s.copyWith(
        speakingPhase: SpeakingCheckPhase.idle,
        recordingElapsed: Duration.zero,
        clearEvaluation: true,
        speakingError: null,
      ),
    );
  }

  /// Stops the recorder and uploads the audio for evaluation.
  Future<void> stopAndCheck() async {
    final s = state.valueOrNull;
    if (s == null || s.isDone || s.isEmpty) return;
    if (s.speakingPhase != SpeakingCheckPhase.recording) return;
    final word = s.current!;
    _recordingTicker?.cancel();
    _recordingTicker = null;
    _recordingStopwatch.stop();

    String? path;
    try {
      path = await _recorder?.stop();
    } catch (e) {
      debugPrint('stop recorder failed: $e');
    }
    path ??= _recordingPath;
    _recordingPath = null;

    if (path == null) {
      state = AsyncData(
        s.copyWith(
          speakingPhase: SpeakingCheckPhase.idle,
          speakingError: 'Audio yozuv topilmadi',
        ),
      );
      return;
    }

    state = AsyncData(
      s.copyWith(
        speakingPhase: SpeakingCheckPhase.checking,
        speakingError: null,
      ),
    );

    try {
      final evaluation = await ref
          .read(vocabularyRepositoryProvider)
          .checkSpeaking(
            wordId: word.id,
            filePath: path,
            mimeType: 'audio/m4a',
          );
      final latest = state.valueOrNull ?? s;
      state = AsyncData(
        latest.copyWith(
          speakingPhase: SpeakingCheckPhase.showingResult,
          lastEvaluation: evaluation,
        ),
      );
    } catch (e) {
      final latest = state.valueOrNull ?? s;
      state = AsyncData(
        latest.copyWith(
          speakingPhase: SpeakingCheckPhase.idle,
          speakingError: "Baholashda xatolik: $e",
        ),
      );
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  /// Closes the evaluation result and advances to the next card. If the
  /// learner got it right, also removes the word from their list
  /// server-side (fire-and-forget) — they've demonstrated mastery.
  void dismissSpeakingResult() {
    final s = state.valueOrNull;
    if (s == null) return;
    if (s.speakingPhase != SpeakingCheckPhase.showingResult) return;
    final evaluation = s.lastEvaluation;
    final word = s.current;
    final wasCorrect = evaluation?.correct ?? false;

    if (wasCorrect && word != null) {
      unawaited(
        ref.read(vocabularyRepositoryProvider).removeWord(word.id).catchError((
          e,
        ) {
          debugPrint('removeWord failed for ${word.word}: $e');
        }),
      );
    }

    // The server's checkSpeaking already recorded the result in the
    // training counters, so we just advance the local cursor without
    // double-counting.
    state = AsyncData(_advance(s, wasCorrect));
  }

  /// Advances past the current word without recording a result.
  void skipWord() {
    final s = state.valueOrNull;
    if (s == null || s.isDone || s.isEmpty) return;
    if (s.speakingPhase != SpeakingCheckPhase.idle) return;
    state = AsyncData(
      VocabularyTrainingState(
        batch: s.batch,
        currentIndex: s.currentIndex + 1,
        correct: s.correct,
        incorrect: s.incorrect,
        stats: s.stats,
      ),
    );
  }

  /// Clears any inline speaking error banner.
  void dismissSpeakingError() {
    final s = state.valueOrNull;
    if (s == null || s.speakingError == null) return;
    state = AsyncData(s.copyWith(speakingError: null));
  }

  /// Pulls a fresh batch from the server (e.g. after the session ends).
  Future<void> restart() async {
    await _disposeAudio();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(vocabularyRepositoryProvider);
      final batch = await repo.getTrainingBatch();
      Map<WordStatus, int>? stats;
      try {
        stats = await repo.stats();
      } catch (_) {}
      return VocabularyTrainingState(
        batch: batch,
        currentIndex: 0,
        correct: 0,
        incorrect: 0,
        stats: stats,
      );
    });
  }
}

final vocabularyTrainingControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      VocabularyTrainingController,
      VocabularyTrainingState
    >(VocabularyTrainingController.new);
