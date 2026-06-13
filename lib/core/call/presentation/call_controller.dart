import 'dart:async';

import 'package:ai_teacher/core/call/data/call_dtos.dart';
import 'package:ai_teacher/core/call/data/call_repository.dart';
import 'package:ai_teacher/core/call/data/call_socket.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

enum CallPhase {
  idle,
  incoming,
  outgoing,
  connecting,
  active,
  reconnecting,
  ended,
}

class CallState {
  const CallState({
    this.phase = CallPhase.idle,
    this.callId,
    this.assignmentId,
    this.callerId,
    this.calleeId,
    this.muted = false,
    this.speakerphone = false,
    this.elapsed = Duration.zero,
    this.endedReason,
    this.error,
  });

  final CallPhase phase;
  final String? callId;
  final String? assignmentId;
  final String? callerId;
  final String? calleeId;
  final bool muted;
  final bool speakerphone;
  final Duration elapsed;
  final String? endedReason;
  final String? error;

  bool get isIncomingForMe => phase == CallPhase.incoming;

  bool get isOutgoingForMe => phase == CallPhase.outgoing;

  bool get isLive =>
      phase == CallPhase.connecting ||
      phase == CallPhase.active ||
      phase == CallPhase.reconnecting;

  CallState copyWith({
    CallPhase? phase,
    String? callId,
    String? assignmentId,
    String? callerId,
    String? calleeId,
    bool? muted,
    bool? speakerphone,
    Duration? elapsed,
    Object? endedReason = _sentinel,
    Object? error = _sentinel,
  }) {
    return CallState(
      phase: phase ?? this.phase,
      callId: callId ?? this.callId,
      assignmentId: assignmentId ?? this.assignmentId,
      callerId: callerId ?? this.callerId,
      calleeId: calleeId ?? this.calleeId,
      muted: muted ?? this.muted,
      speakerphone: speakerphone ?? this.speakerphone,
      elapsed: elapsed ?? this.elapsed,
      endedReason: identical(endedReason, _sentinel)
          ? this.endedReason
          : endedReason as String?,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();

final callControllerProvider = NotifierProvider<CallController, CallState>(
  CallController.new,
);

class CallController extends Notifier<CallState> {
  StreamSubscription<CallEvent>? _eventsSub;
  RTCPeerConnection? _peer;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  Timer? _elapsedTimer;
  Timer? _retryTimer;
  DateTime? _activeAt;
  bool _isCaller = false;
  bool _socketStarted = false;
  int _retryCount = 0;

  static const _retryDelays = [2, 4, 8, 16, 30];

  static const _iceServers = <Map<String, dynamic>>[
    {'urls': 'stun:stun.l.google.com:19302'},
  ];

  @override
  CallState build() {
    ref.onDispose(_disposeAll);
    return const CallState();
  }

  MediaStream? get localStream => _localStream;

  MediaStream? get remoteStream => _remoteStream;

  /// Subscribe to the /call socket so we hear `incoming-call`. Call this once
  /// from a long-lived widget (e.g. the main shell) after the user is signed
  /// in. Retries with exponential backoff on failure.
  Future<void> ensureListening() async {
    if (_socketStarted) return;
    _socketStarted = true;
    _retryTimer?.cancel();
    _retryTimer = null;
    try {
      final socket = ref.read(callSocketProvider);
      await socket.connect();
      _eventsSub = socket.events.listen(_handleEvent);
      _retryCount = 0;
    } catch (e) {
      _socketStarted = false;
      debugPrint('call socket connect failed: $e');
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    final seconds = _retryDelays[_retryCount.clamp(0, _retryDelays.length - 1)];
    _retryCount++;
    debugPrint('call socket retry in ${seconds}s (attempt $_retryCount)');
    _retryTimer = Timer(Duration(seconds: seconds), () {
      _retryTimer = null;
      ensureListening();
    });
  }

  /// Mentor-initiated call. Posts to `/calls`, the server fires
  /// `incoming-call` to the callee. We move into `outgoing` and wait for
  /// `call-accepted`.
  Future<void> startCall(String assignmentId) async {
    try {
      await ensureListening();
      final call = await ref.read(callRepositoryProvider).start(assignmentId);
      _isCaller = true;
      state = state.copyWith(
        phase: CallPhase.outgoing,
        callId: call.id,
        assignmentId: call.assignmentId,
        callerId: call.callerId,
        calleeId: call.calleeId,
        elapsed: Duration.zero,
        endedReason: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Qo\'ng\'iroqni boshlab bo\'lmadi');
      rethrow;
    }
  }

  Future<void> accept() async {
    final id = state.callId;
    if (id == null || state.phase != CallPhase.incoming) return;
    try {
      _isCaller = false;
      state = state.copyWith(phase: CallPhase.connecting, error: null);
      await _initLocalMedia();
      await _initPeer();
      await ref.read(callSocketProvider).accept(id);
    } catch (e) {
      debugPrint('accept failed: $e');
      state = state.copyWith(
        phase: CallPhase.ended,
        endedReason: 'failed',
        error: 'Qabul qilinmadi',
      );
      await _closePeer();
    }
  }

  Future<void> decline() async {
    final id = state.callId;
    if (id == null) return;
    try {
      await ref.read(callSocketProvider).decline(id);
    } catch (e) {
      debugPrint('decline failed: $e');
    }
    state = state.copyWith(phase: CallPhase.ended, endedReason: 'declined');
    await _closePeer();
  }

  Future<void> hangup({String reason = 'hangup'}) async {
    final id = state.callId;
    if (id != null) {
      try {
        await ref.read(callSocketProvider).hangup(id, reason: reason);
      } catch (e) {
        debugPrint('hangup failed: $e');
      }
    }
    state = state.copyWith(phase: CallPhase.ended, endedReason: reason);
    _stopElapsedTimer();
    await _closePeer();
  }

  void toggleMute() {
    final stream = _localStream;
    if (stream == null) return;
    final next = !state.muted;
    for (final track in stream.getAudioTracks()) {
      track.enabled = !next;
    }
    state = state.copyWith(muted: next);
  }

  void toggleSpeaker() {
    final stream = _localStream;
    final next = !state.speakerphone;
    if (stream != null) {
      // Helper.setSpeakerphoneOn requires the audio session on iOS/Android.
      Helper.setSpeakerphoneOn(next);
    }
    state = state.copyWith(speakerphone: next);
  }

  /// Reset back to idle so the screen can dismiss after `ended`.
  void reset() {
    state = const CallState();
  }

  Future<void> _handleEvent(CallEvent event) async {
    switch (event) {
      case IncomingCallEvent e:
        if (state.isLive || state.phase == CallPhase.incoming) {
          // Already in a call — auto-decline duplicate ring.
          try {
            await ref.read(callSocketProvider).decline(e.callId);
          } catch (_) {}
          return;
        }
        state = CallState(
          phase: CallPhase.incoming,
          callId: e.callId,
          assignmentId: e.assignmentId,
          callerId: e.callerId,
        );
      case CallAcceptedEvent _:
        if (!_isCaller) return;
        state = state.copyWith(phase: CallPhase.connecting);
        await _initLocalMedia();
        await _initPeer();
        await _sendOffer();
      case CallDeclinedEvent _:
        state = state.copyWith(phase: CallPhase.ended, endedReason: 'declined');
        await _closePeer();
      case CallEndedEvent e:
        state = state.copyWith(
          phase: CallPhase.ended,
          endedReason: e.reason ?? 'ended',
        );
        _stopElapsedTimer();
        await _closePeer();
      case CallOfferEvent e:
        await _handleRemoteOffer(e.sdp);
      case CallAnswerEvent e:
        await _handleRemoteAnswer(e.sdp);
      case CallIceEvent e:
        await _handleRemoteIce(e.candidate);
    }
  }

  Future<void> _initLocalMedia() async {
    _localStream ??= await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });
  }

  Future<void> _initPeer() async {
    if (_peer != null) return;
    final peer = await createPeerConnection({
      'iceServers': _iceServers,
      'sdpSemantics': 'unified-plan',
      'encodedInsertableStreams': true,
    });

    final local = _localStream;
    if (local != null) {
      for (final track in local.getTracks()) {
        await peer.addTrack(track, local);
      }
    }

    peer.onIceCandidate = (candidate) {
      final id = state.callId;
      if (id == null) return;
      ref
          .read(callSocketProvider)
          .sendIceCandidate(id, {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          })
          .catchError((e) => debugPrint('ice send failed: $e'));
    };

    peer.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
      }
    };

    peer.onConnectionState = (s) {
      debugPrint('peer connection state: $s');
      switch (s) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _activeAt ??= DateTime.now();
          _startElapsedTimer();
          state = state.copyWith(phase: CallPhase.active);
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          state = state.copyWith(phase: CallPhase.reconnecting);
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          state = state.copyWith(phase: CallPhase.ended, endedReason: 'failed');
          _stopElapsedTimer();
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          break;
        default:
          break;
      }
    };

    _peer = peer;
  }

  Future<void> _sendOffer() async {
    final peer = _peer;
    final id = state.callId;
    if (peer == null || id == null) return;
    final offer = await peer.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': false,
    });
    await peer.setLocalDescription(offer);
    await ref.read(callSocketProvider).sendOffer(id, {
      'type': offer.type,
      'sdp': offer.sdp,
    });
  }

  Future<void> _handleRemoteOffer(Map<String, dynamic> sdp) async {
    await _initLocalMedia();
    await _initPeer();
    final peer = _peer!;
    final id = state.callId;
    if (id == null) return;
    await peer.setRemoteDescription(
      RTCSessionDescription(sdp['sdp'] as String?, sdp['type'] as String?),
    );
    final answer = await peer.createAnswer({});
    await peer.setLocalDescription(answer);
    await ref.read(callSocketProvider).sendAnswer(id, {
      'type': answer.type,
      'sdp': answer.sdp,
    });
  }

  Future<void> _handleRemoteAnswer(Map<String, dynamic> sdp) async {
    final peer = _peer;
    if (peer == null) return;
    await peer.setRemoteDescription(
      RTCSessionDescription(sdp['sdp'] as String?, sdp['type'] as String?),
    );
  }

  Future<void> _handleRemoteIce(Map<String, dynamic> candidate) async {
    final peer = _peer;
    if (peer == null) return;
    final cand = RTCIceCandidate(
      candidate['candidate'] as String?,
      candidate['sdpMid'] as String?,
      candidate['sdpMLineIndex'] is int
          ? candidate['sdpMLineIndex'] as int
          : null,
    );
    try {
      await peer.addCandidate(cand);
    } catch (e) {
      debugPrint('addCandidate failed: $e');
    }
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    final start = _activeAt ?? DateTime.now();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsed: DateTime.now().difference(start));
    });
  }

  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  Future<void> _closePeer() async {
    _stopElapsedTimer();
    try {
      await _peer?.close();
    } catch (_) {}
    _peer = null;
    try {
      for (final track in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
        await track.stop();
      }
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;
    _remoteStream = null;
    _activeAt = null;
    _isCaller = false;
  }

  void _disposeAll() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _eventsSub?.cancel();
    _eventsSub = null;
    _stopElapsedTimer();
    _peer?.close();
    _localStream?.dispose();
  }
}
