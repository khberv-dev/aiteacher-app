import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/vocabulary/data/vocabulary_word.dart';
import 'package:ai_teacher/core/vocabulary/data/word_status.dart';
import 'package:ai_teacher/core/vocabulary/presentation/vocabulary_training_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/vocabulary/widget/hold_mic_button.dart';
import 'package:ai_teacher/ui/vocabulary/widget/training_empty_view.dart';
import 'package:ai_teacher/ui/vocabulary/widget/training_evaluation_card.dart';
import 'package:ai_teacher/ui/vocabulary/widget/training_progress_bar.dart';
import 'package:ai_teacher/ui/vocabulary/widget/training_summary_view.dart';
import 'package:ai_teacher/ui/vocabulary/widget/word_definition_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VocabularyTrainingScreen extends ConsumerWidget {
  const VocabularyTrainingScreen({super.key});

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.main.name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(vocabularyTrainingControllerProvider);
    ref.listen(vocabularyTrainingControllerProvider, (prev, next) {
      final err = next.valueOrNull?.speakingError;
      if (err == null) return;
      if (prev?.valueOrNull?.speakingError == err) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(err)));
      ref
          .read(vocabularyTrainingControllerProvider.notifier)
          .dismissSpeakingError();
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: () => _onBack(context)),
              Expanded(
                child: asyncState.when(
                  loading: () => const _Loading(),
                  error: (e, _) => _Error(
                    message: e.toString(),
                    onRetry: () => ref
                        .read(vocabularyTrainingControllerProvider.notifier)
                        .restart(),
                  ),
                  data: (s) {
                    if (s.isEmpty) {
                      return TrainingEmptyView(
                        onStartSpeaking: () =>
                            context.goNamed(AppRoute.speaking.name),
                      );
                    }
                    if (s.isDone) {
                      return TrainingSummaryView(
                        total: s.batch.length,
                        correct: s.correct,
                        incorrect: s.incorrect,
                        onRestart: () => ref
                            .read(vocabularyTrainingControllerProvider.notifier)
                            .restart(),
                        onExit: () => _onBack(context),
                      );
                    }
                    return _TrainingBody(state: s);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrainingBody extends ConsumerWidget {
  const _TrainingBody({required this.state});

  final VocabularyTrainingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(vocabularyTrainingControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final current = state.current!;
    final showingResult =
        state.speakingPhase == SpeakingCheckPhase.showingResult &&
        state.lastEvaluation != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        children: [
          TrainingProgressBar(
            currentIndex: state.currentIndex,
            total: state.batch.length,
            statsSummary: _statsLine(l10n, state.stats),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: showingResult
                ? TrainingEvaluationCard(
                    key: ValueKey('eval-${current.id}'),
                    word: current.word,
                    evaluation: state.lastEvaluation!,
                    onContinue: notifier.dismissSpeakingResult,
                  )
                : _WordHero(word: current),
          ),
          if (!showingResult) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ThumbButton(
                  emoji: '🤷',
                  color: const Color(0xFFDC2626),
                  bg: const Color(0xFFFEF2F2),
                  border: const Color(0xFFFECACA),
                  onTap: () => WordDefinitionSheet.show(context, current),
                  enabled: state.speakingPhase == SpeakingCheckPhase.idle,
                ),
                HoldMicButton(
                  phase: state.speakingPhase,
                  elapsed: state.recordingElapsed,
                  onPressStart: notifier.startSpeaking,
                  onPressEnd: notifier.stopAndCheck,
                  onPressCancel: notifier.cancelSpeaking,
                ),
                _ThumbButton(
                  emoji: '👍',
                  color: const Color(0xFF16A34A),
                  bg: const Color(0xFFF0FDF4),
                  border: const Color(0xFFBBF7D0),
                  onTap: notifier.skipWord,
                  enabled: state.speakingPhase == SpeakingCheckPhase.idle,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _WordHero extends StatelessWidget {
  const _WordHero({required this.word});

  final VocabularyWord word;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CefrBadge(level: word.cefrLevel),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              word.word,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 52,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: -0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Text(
        level.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF1D4ED8),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

String? _statsLine(AppLocalizations l10n, Map<WordStatus, int>? stats) {
  if (stats == null) return null;
  final n = stats[WordStatus.newWord] ?? 0;
  final l = stats[WordStatus.learning] ?? 0;
  final m = stats[WordStatus.mastered] ?? 0;
  return l10n.vocabularyStatsLine(n, l, m);
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Text(
            l10n.vocabularyTitle,
            style: const TextStyle(
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

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.vocabularyLoadingWords,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbButton extends StatelessWidget {
  const _ThumbButton({
    required this.emoji,
    required this.color,
    required this.bg,
    required this.border,
    required this.onTap,
    required this.enabled,
  });

  final String emoji;
  final Color color;
  final Color bg;
  final Color border;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.35,
      duration: const Duration(milliseconds: 160),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(color: border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 26)),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB91C1C),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.vocabularyLoadError,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}
