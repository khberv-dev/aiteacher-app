import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/battle/data/battle_dtos.dart';
import 'package:ai_teacher/core/battle/presentation/battle_controller.dart';
import 'package:ai_teacher/ui/battle/widget/battle_game_over_view.dart';
import 'package:ai_teacher/ui/battle/widget/battle_idle_view.dart';
import 'package:ai_teacher/ui/battle/widget/battle_playing_view.dart';
import 'package:ai_teacher/ui/battle/widget/battle_queue_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BattleScreen extends ConsumerWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(battleControllerProvider);
    final notifier = ref.read(battleControllerProvider.notifier);

    ref.listen(battleControllerProvider, (prev, next) {
      final err = next.error;
      if (err == null) return;
      if (prev?.error == err) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(err)));
    });

    final inProgress =
        state.phase == BattlePhase.queuing ||
        state.phase == BattlePhase.playing;

    return PopScope(
      canPop: !inProgress,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmLeave(context, state.phase);
        if (leave && context.mounted) {
          if (state.phase == BattlePhase.queuing) notifier.leaveQueue();
          if (context.mounted) context.pop();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.background,
        ),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  phase: state.phase,
                  onBack: () {
                    if (!inProgress) {
                      context.pop();
                    } else {
                      _confirmLeave(context, state.phase).then((leave) {
                        if (leave && context.mounted) {
                          if (state.phase == BattlePhase.queuing) {
                            notifier.leaveQueue();
                          }
                          if (context.mounted) context.pop();
                        }
                      });
                    }
                  },
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: switch (state.phase) {
                      BattlePhase.idle => BattleIdleView(
                        key: const ValueKey('idle'),
                        onFindOpponent: notifier.joinQueue,
                      ),
                      BattlePhase.queuing => BattleQueueView(
                        key: const ValueKey('queue'),
                        lobbyPlayers: state.lobbyPlayers,
                        lobbyTick: state.lobbyTick,
                        onCancel: notifier.leaveQueue,
                      ),
                      BattlePhase.playing => BattlePlayingView(
                        key: ValueKey('playing-${state.currentRound}'),
                        state: state,
                        onAnswer: notifier.submitAnswer,
                      ),
                      BattlePhase.gameOver => BattleGameOverView(
                        key: const ValueKey('gameover'),
                        state: state,
                        onPlayAgain: notifier.joinQueue,
                        onExit: () {
                          notifier.reset();
                          context.pop();
                        },
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<bool> _confirmLeave(
    BuildContext context,
    BattlePhase phase,
  ) async {
    final body = phase == BattlePhase.playing
        ? "O'yinni tark etsangiz, siz yutqazgan hisoblanasiz."
        : "Navbatdan chiqasizmi?";

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text(
          'Chiqasizmi?',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Qolish',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Chiqish',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.phase, required this.onBack});

  final BattlePhase phase;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF0F172A),
          ),
          const SizedBox(width: 4),
          const Text(
            "So'z Jangi",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
