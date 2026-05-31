import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/core/writing_task/presentation/writing_task_list_controller.dart';
import 'package:ai_teacher/ui/writing_task/widget/writing_task_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WritingTaskListScreen extends ConsumerStatefulWidget {
  const WritingTaskListScreen({super.key});

  @override
  ConsumerState<WritingTaskListScreen> createState() =>
      _WritingTaskListScreenState();
}

class _WritingTaskListScreenState extends ConsumerState<WritingTaskListScreen> {
  bool _autoNavigated = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(writingTaskListControllerProvider, (_, next) {
      if (_autoNavigated) return;
      final tasks = next.valueOrNull;
      if (tasks != null && tasks.isEmpty) {
        _autoNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pushNamed(AppRoute.writingTaskDetail.name);
        });
      }
    });

    final async = ref.watch(writingTaskListControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(
                onBack: () => Navigator.of(context).pop(),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFE2E8F0),
              ),
              Expanded(
                child: async.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Yuklanmadi',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => ref
                              .read(writingTaskListControllerProvider.notifier)
                              .refresh(),
                          child: const Text('Qayta urinish'),
                        ),
                      ],
                    ),
                  ),
                  data: (tasks) => tasks.isEmpty
                      ? _EmptyState(
                          onStart: () => context.pushNamed(
                            AppRoute.writingTaskDetail.name,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(writingTaskListControllerProvider.notifier)
                              .refresh(),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            itemCount: tasks.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) =>
                                WritingTaskListItem(
                                  task: tasks[i],
                                  onTap: () => context.pushNamed(
                                    AppRoute.writingTaskDetail.name,
                                    extra: tasks[i].id,
                                  ),
                                ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: async.valueOrNull?.isNotEmpty == true
            ? _NewTaskFab(
                onTap: () =>
                    context.pushNamed(AppRoute.writingTaskDetail.name),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF64748B),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Yozish vazifalari',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.edit_note_rounded,
                size: 38,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Hali vazifalar yo'q",
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Birinchi yozish vazifangizni boshlang",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Vazifa boshlash',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewTaskFab extends StatelessWidget {
  const _NewTaskFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF059669),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text(
            'Yangi vazifa',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
