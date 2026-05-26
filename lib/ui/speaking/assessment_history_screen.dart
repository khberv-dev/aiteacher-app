import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/speaking/data/conversation_summary.dart';
import 'package:ai_teacher/core/speaking/data/speaking_repository.dart';
import 'package:ai_teacher/core/speaking/presentation/assessment_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AssessmentHistoryScreen extends ConsumerStatefulWidget {
  const AssessmentHistoryScreen({super.key});

  @override
  ConsumerState<AssessmentHistoryScreen> createState() =>
      _AssessmentHistoryScreenState();
}

class _AssessmentHistoryScreenState
    extends ConsumerState<AssessmentHistoryScreen> {
  String? _openingId;

  Future<void> _onOpen(ConversationSummary item) async {
    if (_openingId != null) return;
    if (!item.hasReport) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Bu suhbatda hali hisobot yo'q")),
        );
      return;
    }
    setState(() => _openingId = item.id);
    try {
      final report = await ref
          .read(speakingRepositoryProvider)
          .getConversationReport(item.id);
      if (!mounted) return;
      if (report == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text("Hisobot topilmadi")));
        return;
      }
      context.pushNamed(AppRoute.speakingReport.name, extra: report);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Hisobotni yuklab bo'lmadi")),
        );
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(assessmentHistoryProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFFF5F7FF),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: () => _onBack(context)),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(assessmentHistoryProvider);
                    await ref.read(assessmentHistoryProvider.future);
                  },
                  child: historyAsync.when(
                    loading: () => const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    ),
                    error: (_, _) =>
                        const _Empty(text: "Tarixni yuklab bo'lmadi"),
                    data: (items) {
                      if (items.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            _Empty(text: "Hozircha suhbat tarixi yo'q"),
                          ],
                        );
                      }
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _HistoryItem(
                            item: item,
                            loading: _openingId == item.id,
                            onTap: () => _onOpen(item),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.main.name);
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF6B7A9F),
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            "Suhbatlar tarixi",
            style: TextStyle(
              color: Color(0xFF0D1B4B),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.item,
    required this.loading,
    required this.onTap,
  });

  final ConversationSummary item;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tappable = item.hasReport;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F0D1B4B),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !item.hasReport
                      ? const Color(0xFFF1F5F9)
                      : item.isFullReportAvailable
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  !item.hasReport
                      ? Icons.history_rounded
                      : item.isFullReportAvailable
                      ? Icons.assignment_turned_in_rounded
                      : Icons.lock_outline_rounded,
                  color: !item.hasReport
                      ? const Color(0xFF64748B)
                      : item.isFullReportAvailable
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB45309),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDate(item.updatedAt.toLocal()),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusChip(
                          label: !item.hasReport
                              ? (item.readyForAnalyze
                                    ? 'Tayyor'
                                    : "Yetarli emas")
                              : item.isFullReportAvailable
                              ? "To'liq hisobot"
                              : 'Qisman ko\'rinadi',
                          background: !item.hasReport
                              ? (item.readyForAnalyze
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFF1F5F9))
                              : item.isFullReportAvailable
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          textColor: !item.hasReport
                              ? (item.readyForAnalyze
                                    ? const Color(0xFFB45309)
                                    : const Color(0xFF64748B))
                              : item.isFullReportAvailable
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB45309),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.primary,
                  ),
                )
              else if (tappable)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB7BCC8),
                  size: 22,
                )
              else
                const SizedBox(width: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8580),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

const _uzMonths = [
  'yanvar',
  'fevral',
  'mart',
  'aprel',
  'may',
  'iyun',
  'iyul',
  'avgust',
  'sentabr',
  'oktabr',
  'noyabr',
  'dekabr',
];

String _formatDate(DateTime d) {
  final month = (d.month >= 1 && d.month <= 12) ? _uzMonths[d.month - 1] : '';
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '${d.day}-$month ${d.year} · $h:$m';
}
