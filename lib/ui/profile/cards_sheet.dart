import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/cards/data/card_dtos.dart';
import 'package:ai_teacher/core/cards/presentation/cards_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/profile/add_card_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardsSheet extends ConsumerWidget {
  const CardsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const CardsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(cardsControllerProvider);
    final bottom = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.credit_card_rounded,
                      size: 20,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.profileCardsTitle,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.profileCardsLoadError,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref
                            .read(cardsControllerProvider.notifier)
                            .refresh(),
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                ),
                data: (cards) => cards.isEmpty
                    ? ListView(
                        controller: scrollController,
                        children: const [_EmptyCardsView()],
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
                        itemCount: cards.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _CardTile(
                          card: cards[i],
                          onDelete: () =>
                              _confirmDelete(context, ref, cards[i]),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
              child: FilledButton.icon(
                onPressed: () => AddCardDialog.show(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  l10n.profileAddCardAction,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    UserCard card,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.profileDeleteCardTitle,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          l10n.profileDeleteCardConfirmMessage(card.maskedNumber),
          style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.commonCancel,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.commonDelete,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(cardsControllerProvider.notifier).remove(card.id);
    }
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.onDelete});

  final UserCard card;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.credit_card_rounded,
              size: 22,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.maskedNumber,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  card.displayExpiry,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: const Color(0xFFEF4444),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _EmptyCardsView extends StatelessWidget {
  const _EmptyCardsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.credit_card_off_outlined,
              size: 36,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.profileNoCardsTitle,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.profileNoCardsSubtitle,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
