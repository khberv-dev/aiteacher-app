import 'package:ai_teacher/app/data/network_config.dart';
import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/course/data/course_dtos.dart';
import 'package:ai_teacher/core/course/presentation/courses_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(coursesControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kurslarni yuklashda xatolik',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(coursesControllerProvider.notifier).refresh(),
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () =>
              ref.read(coursesControllerProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'Kurslar',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              if (state.mine.isNotEmpty) ...[
                _SectionHeader(title: 'Mening kurslarim'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: state.mine.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _CourseCard(course: state.mine[i], enrolled: true),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
              _SectionHeader(title: 'Barcha kurslar'),
              state.active.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Text(
                          'Hozircha faol kurslar yo\'q',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.separated(
                        itemCount: state.active.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) => _CourseCard(
                          course: state.active[i],
                          enrolled: state.mine.any(
                            (m) => m.id == state.active[i].id,
                          ),
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.enrolled});

  final Course course;
  final bool enrolled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              context.pushNamed(AppRoute.courseWeb.name, extra: course),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _CourseThumbnail(coverUrl: course.coverUrl, enrolled: enrolled),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      if (enrolled) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Biriktirilgan',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseThumbnail extends StatelessWidget {
  const _CourseThumbnail({required this.coverUrl, required this.enrolled});

  final String? coverUrl;
  final bool enrolled;

  @override
  Widget build(BuildContext context) {
    final fullUrl = coverUrl != null
        ? '${NetworkConfig.hostUrl}/public/$coverUrl'
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        height: 64,
        child: fullUrl != null
            ? Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: enrolled
          ? AppColors.primary.withValues(alpha: 0.1)
          : const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: Icon(
        Icons.school_rounded,
        size: 30,
        color: enrolled ? AppColors.primary : const Color(0xFF94A3B8),
      ),
    );
  }
}
