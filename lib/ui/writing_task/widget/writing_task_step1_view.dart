import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class WritingTaskStep1View extends StatefulWidget {
  const WritingTaskStep1View({
    super.key,
    required this.theme,
    required this.originText,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final String theme;
  final String originText;
  final bool isSubmitting;
  final ValueChanged<String> onSubmit;

  @override
  State<WritingTaskStep1View> createState() => _WritingTaskStep1ViewState();
}

class _WritingTaskStep1ViewState extends State<WritingTaskStep1View> {
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
            padding: const EdgeInsets.all(16),
            child: _OriginCard(theme: widget.theme, text: widget.originText),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  l10n.writingTaskStep1Instructions,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    controller: _ctrl,
                    enabled: !widget.isSubmitting,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.writingTaskStep1Hint,
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
                ),
              ),
            ],
          ),
        ),
        _SubmitBar(
          label: l10n.writingTaskStep1SubmitButton,
          enabled: _hasText && !widget.isSubmitting,
          isLoading: widget.isSubmitting,
          onTap: () => widget.onSubmit(_ctrl.text.trim()),
        ),
      ],
    );
  }
}

class _OriginCard extends StatelessWidget {
  const _OriginCard({required this.theme, required this.text});

  final String theme;
  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  theme,
                  style: const TextStyle(
                    color: Color(0xFF065F46),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.writingTaskOriginTextLabel,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
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
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
