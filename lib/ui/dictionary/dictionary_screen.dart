import 'package:ai_teacher/core/dictionary/presentation/dictionary_controller.dart';
import 'package:ai_teacher/ui/dictionary/widget/dictionary_definition_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dictionaryControllerProvider, (previous, next) {
      final prevTab = previous?.valueOrNull?.tab;
      final nextTab = next.valueOrNull?.tab;
      if (nextTab != null && nextTab != prevTab) {
        _searchController.clear();
      }
    });

    final async = ref.watch(dictionaryControllerProvider);
    final notifier = ref.read(dictionaryControllerProvider.notifier);

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
              _Header(onBack: () => Navigator.of(context).pop()),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: _TabSwitch(
                  tab: async.valueOrNull?.tab,
                  onChanged: notifier.switchTab,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _SearchField(
                  controller: _searchController,
                  onChanged: notifier.search,
                ),
              ),
              Expanded(
                child: async.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const _ErrorState(),
                  data: (value) => _DictionaryTabs(
                    state: value,
                    isFavorite: value.isFavorite,
                    onToggleFavorite: notifier.toggleFavorite,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                "Lug'at",
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

class _TabSwitch extends StatelessWidget {
  const _TabSwitch({required this.tab, required this.onChanged});

  final DictionaryTab? tab;
  final ValueChanged<DictionaryTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final values = DictionaryTab.values;
    final selectedIndex = tab == null ? 0 : values.indexOf(tab!);

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / values.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: segmentWidth * selectedIndex,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: values.map((value) {
                  final selected = value == tab;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(value),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          child: Text(value.label),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: "So'z qidirish",
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D9488)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}

class _DictionaryTabs extends StatelessWidget {
  const _DictionaryTabs({
    required this.state,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final DictionaryState state;
  final bool Function(DictionaryListItem item) isFavorite;
  final ValueChanged<DictionaryListItem> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final tabs = DictionaryTab.values;
    return IndexedStack(
      index: tabs.indexOf(state.tab),
      children: tabs.map((tab) {
        if (!state.hasEntries(tab)) {
          return _EmptyState(key: ValueKey(tab), tab: tab);
        }
        return _DictionaryList(
          key: ValueKey(tab),
          items: state.itemsFor(tab),
          isFavorite: isFavorite,
          onToggleFavorite: onToggleFavorite,
        );
      }).toList(),
    );
  }
}

class _DictionaryList extends StatelessWidget {
  const _DictionaryList({
    super.key,
    required this.items,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final List<DictionaryListItem> items;
  final bool Function(DictionaryListItem item) isFavorite;
  final ValueChanged<DictionaryListItem> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          "Hech narsa topilmadi",
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
      itemBuilder: (context, i) {
        final item = items[i];
        return InkWell(
          onTap: () => DictionaryDefinitionSheet.show(
            context,
            item: item,
            isFavorite: isFavorite(item),
            onToggleFavorite: () => onToggleFavorite(item),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.entry.word,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key, required this.tab});

  final DictionaryTab tab;

  @override
  Widget build(BuildContext context) {
    final message = tab == DictionaryTab.favorites
        ? "Hali sevimli so'zlar yo'q"
        : "Lug'at bo'sh";
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Center(
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
                onPressed: () => ref.invalidate(dictionaryControllerProvider),
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        );
      },
    );
  }
}
