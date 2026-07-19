import 'package:ai_teacher/app/data/network_config.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/course/data/course_dtos.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class CourseInfoSheet extends StatelessWidget {
  const CourseInfoSheet({
    super.key,
    required this.course,
    required this.actionLabel,
    required this.onAction,
  });

  final Course course;
  final String actionLabel;
  final VoidCallback onAction;

  static Future<void> showEnrolled(
    BuildContext context, {
    required Course course,
    required VoidCallback onNavigate,
  }) {
    final l10n = AppLocalizations.of(context);
    return _show(
      context,
      course: course,
      actionLabel: l10n.coursesEnterCourseLabel,
      onAction: onNavigate,
    );
  }

  static Future<void> showAvailable(
    BuildContext context, {
    required Course course,
    required VoidCallback onDemo,
  }) {
    final l10n = AppLocalizations.of(context);
    final demoPrice = course.demoPrice;
    final label = demoPrice != null
        ? l10n.coursesDemoPriceLabel(_formatPrice(demoPrice))
        : l10n.coursesMoreInfoLabel;
    return _show(context, course: course, actionLabel: label, onAction: onDemo);
  }

  static Future<void> _show(
    BuildContext context, {
    required Course course,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CourseInfoSheet(
        course: course,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const _Handle(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  _Cover(coverUrl: course.coverUrl),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                        if ((course.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            course.description!,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onAction();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              actionLabel,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final fullUrl = coverUrl != null
        ? '${NetworkConfig.hostUrl}/public/$coverUrl'
        : null;

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: fullUrl != null
          ? Image.network(
              fullUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.primary.withValues(alpha: 0.08),
    alignment: Alignment.center,
    child: Icon(
      Icons.school_rounded,
      size: 64,
      color: AppColors.primary.withValues(alpha: 0.4),
    ),
  );
}

String _formatPrice(num value) {
  final s = value.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return "${buf.toString()} so'm";
}
