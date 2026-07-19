import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class WritingTaskStep2View extends StatefulWidget {
  const WritingTaskStep2View({
    super.key,
    required this.uzbekTranslation,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final String uzbekTranslation;
  final bool isSubmitting;
  final ValueChanged<String> onSubmit;

  @override
  State<WritingTaskStep2View> createState() => _WritingTaskStep2ViewState();
}

class _WritingTaskStep2ViewState extends State<WritingTaskStep2View> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UzbekCard(text: widget.uzbekTranslation),
                const SizedBox(height: 16),
                Text(
                  l10n.writingTaskStep2Instructions,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.writingTaskStep2Subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ctrl,
                  enabled: !widget.isSubmitting,
                  minLines: 6,
                  maxLines: 12,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.writingTaskStep2Hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _SubmitBar(
          enabled: _hasText && !widget.isSubmitting,
          isLoading: widget.isSubmitting,
          onTap: () => widget.onSubmit(_ctrl.text.trim()),
        ),
      ],
    );
  }
}

class _UzbekCard extends StatelessWidget {
  const _UzbekCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.writingTaskStep2YourTranslationLabel,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                l10n.writingTaskStep2SubmitButton,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
