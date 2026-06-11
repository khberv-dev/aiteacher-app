import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/assignment/data/assignment_dtos.dart';
import 'package:ai_teacher/core/assignment/presentation/my_assignments_controller.dart';
import 'package:ai_teacher/core/call/presentation/call_controller.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:ai_teacher/ui/call/call_rating_sheet.dart';
import 'package:ai_teacher/ui/call/widget/call_avatar_rings.dart';
import 'package:ai_teacher/ui/call/widget/call_round_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CallScreen extends ConsumerWidget {
  const CallScreen({super.key});

  static const _ratingThreshold = Duration(minutes: 7);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callControllerProvider);
    final controller = ref.read(callControllerProvider.notifier);
    final peerName = _resolvePeerName(ref, state.assignmentId);
    final peerSubtitle = _resolvePeerSubtitle(ref, state.assignmentId);
    final initials = _initialsFrom(peerName);

    ref.listen(callControllerProvider, (prev, next) {
      if (prev?.phase != CallPhase.ended &&
          next.phase == CallPhase.ended &&
          next.elapsed >= _ratingThreshold &&
          next.callId != null) {
        final callId = next.callId!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            CallRatingSheet.show(context, callId: callId);
          }
        });
      }
    });

    if (state.phase == CallPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(AppRoute.main.name);
        }
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.navy,
      ),
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                _TopBadge(phase: state.phase, elapsed: state.elapsed),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CallAvatarRings(
                        initials: initials,
                        color: _ringColor(state.phase),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        peerName.isEmpty ? '—' : peerName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _Subtitle(
                        phase: state.phase,
                        elapsed: state.elapsed,
                        endedDuration: state.elapsed,
                        peerSubtitle: peerSubtitle,
                      ),
                    ],
                  ),
                ),
                _Actions(state: state, controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _resolvePeerName(WidgetRef ref, String? assignmentId) {
  if (assignmentId == null) return '';
  final assignments = ref.watch(myAssignmentsProvider).valueOrNull;
  if (assignments == null) return '';
  final a = _findAssignment(assignments, assignmentId);
  if (a == null) return '';
  final currentUserId = ref.watch(currentUserProvider).valueOrNull?.id;
  if (currentUserId == null) return '';
  return a.mentor.userId == currentUserId
      ? a.student.fullName
      : a.mentor.fullName;
}

String _resolvePeerSubtitle(WidgetRef ref, String? assignmentId) {
  if (assignmentId == null) return '';
  final assignments = ref.watch(myAssignmentsProvider).valueOrNull;
  if (assignments == null) return '';
  final a = _findAssignment(assignments, assignmentId);
  if (a == null) return '';
  return 'Ingliz tili amaliyoti';
}

Assignment? _findAssignment(List<Assignment> list, String id) {
  for (final a in list) {
    if (a.id == id) return a;
  }
  return null;
}

String _initialsFrom(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  final f = parts.first.isNotEmpty ? parts.first[0] : '';
  final l = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
  final c = '$f$l'.toUpperCase();
  return c.isEmpty ? '?' : c;
}

Color _ringColor(CallPhase phase) {
  switch (phase) {
    case CallPhase.incoming:
    case CallPhase.outgoing:
    case CallPhase.connecting:
      return AppColors.primaryLight;
    case CallPhase.active:
      return const Color(0xFF22C55E);
    case CallPhase.reconnecting:
      return AppColors.accent;
    case CallPhase.ended:
    case CallPhase.idle:
      return Colors.white24;
  }
}

class _TopBadge extends StatelessWidget {
  const _TopBadge({required this.phase, required this.elapsed});

  final CallPhase phase;
  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final (icon, label, fg, bg) = switch (phase) {
      CallPhase.incoming => (
        Icons.call_received_rounded,
        'Kiruvchi qo\'ng\'iroq',
        Colors.white70,
        const Color(0x1FFFFFFF),
      ),
      CallPhase.active => (
        null,
        'Ulandi · ${_format(elapsed)}',
        const Color(0xFFBBF7D0),
        const Color(0xFF064E3B),
      ),
      CallPhase.ended => (
        null,
        "Qo'ng'iroq tugadi",
        Colors.white70,
        const Color(0x1FFFFFFF),
      ),
      _ => (null, '', Colors.white, Colors.transparent),
    };
    if (label.isEmpty) return const SizedBox(height: 24);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 14),
            const SizedBox(width: 6),
          ] else if (phase == CallPhase.active)
            const _PulseDot(),
          if (phase == CallPhase.active) const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({
    required this.phase,
    required this.elapsed,
    required this.endedDuration,
    required this.peerSubtitle,
  });

  final CallPhase phase;
  final Duration elapsed;
  final Duration endedDuration;
  final String peerSubtitle;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case CallPhase.incoming:
        return Text(
          peerSubtitle.isEmpty ? 'Suhbat kutilmoqda' : peerSubtitle,
          style: const TextStyle(
            color: Color(0xFFB7BCC8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        );
      case CallPhase.outgoing:
      case CallPhase.connecting:
        return const Text(
          'Ulanmoqda...',
          style: TextStyle(
            color: AppColors.primaryLight,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        );
      case CallPhase.reconnecting:
        return const Text(
          'Qayta ulanmoqda...',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        );
      case CallPhase.active:
        return Text(
          peerSubtitle.isEmpty ? '' : peerSubtitle,
          style: const TextStyle(
            color: Color(0xFFB7BCC8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        );
      case CallPhase.ended:
        return _EndedCard(duration: endedDuration);
      case CallPhase.idle:
        return const SizedBox.shrink();
    }
  }
}

class _EndedCard extends StatelessWidget {
  const _EndedCard({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFFB7BCC8), size: 16),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Davomiyligi',
                style: TextStyle(
                  color: Color(0xFFB7BCC8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _format(duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.state, required this.controller});

  final CallState state;
  final CallController controller;

  @override
  Widget build(BuildContext context) {
    switch (state.phase) {
      case CallPhase.incoming:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CallRoundButton(
              icon: Icons.call_end_rounded,
              label: 'Rad etish',
              background: const Color(0xFFEF4444),
              large: true,
              onTap: controller.decline,
            ),
            CallRoundButton(
              icon: Icons.call_rounded,
              label: 'Qabul qilish',
              background: const Color(0xFF22C55E),
              large: true,
              onTap: controller.accept,
            ),
          ],
        );
      case CallPhase.outgoing:
      case CallPhase.connecting:
      case CallPhase.reconnecting:
        return Center(
          child: CallRoundButton(
            icon: Icons.call_end_rounded,
            label: state.phase == CallPhase.reconnecting
                ? 'Tugatish'
                : 'Bekor qilish',
            background: const Color(0xFFEF4444),
            large: true,
            onTap: () => controller.hangup(),
          ),
        );
      case CallPhase.active:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CallRoundButton(
              icon: state.muted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: 'Mikrofon',
              background: state.muted
                  ? const Color(0x4DFFFFFF)
                  : const Color(0x33FFFFFF),
              onTap: controller.toggleMute,
            ),
            CallRoundButton(
              icon: state.speakerphone
                  ? Icons.volume_up_rounded
                  : Icons.volume_down_rounded,
              label: 'Karnay',
              background: state.speakerphone
                  ? const Color(0x4DFFFFFF)
                  : const Color(0x33FFFFFF),
              onTap: controller.toggleSpeaker,
            ),
            CallRoundButton(
              icon: Icons.call_end_rounded,
              label: 'Tugatish',
              background: const Color(0xFFEF4444),
              large: true,
              onTap: () => controller.hangup(),
            ),
          ],
        );
      case CallPhase.ended:
        return Center(
          child: CallRoundButton(
            icon: Icons.close_rounded,
            label: 'Yopish',
            background: const Color(0x33FFFFFF),
            onTap: controller.reset,
          ),
        );
      case CallPhase.idle:
        return const SizedBox.shrink();
    }
  }
}

String _format(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
