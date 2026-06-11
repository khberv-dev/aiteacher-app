import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/call/data/call_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallRatingSheet extends ConsumerStatefulWidget {
  const CallRatingSheet({super.key, required this.callId});

  final String callId;

  static Future<void> show(BuildContext context, {required String callId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CallRatingSheet(callId: callId),
    );
  }

  @override
  ConsumerState<CallRatingSheet> createState() => _CallRatingSheetState();
}

class _CallRatingSheetState extends ConsumerState<CallRatingSheet> {
  int _selected = 0;
  bool _submitting = false;

  Future<void> _submit() async {
    if (_selected == 0 || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(callRepositoryProvider).rate(widget.callId, _selected);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grabber
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.star_rounded, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          const Text(
            'Qo\'ng\'iroqni baholang',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mentor bilan bo\'lgan suhbatingiz\nqanday o\'tdi?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              final filled = star <= _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      key: ValueKey(filled),
                      size: 44,
                      color: filled
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: (_selected > 0 && !_submitting) ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.35,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Yuborish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            child: const Text(
              'O\'tkazib yuborish',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
