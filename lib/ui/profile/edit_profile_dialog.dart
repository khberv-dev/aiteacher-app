import 'package:ai_teacher/core/user/data/user_repository.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  const EditProfileDialog({super.key, required this.initialFirstName});

  final String initialFirstName;

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialFirstName,
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _error = l10n.profileNameRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(userRepositoryProvider).updateMe(firstName: value);
      if (!mounted) return;
      ref.invalidate(currentUserProvider);
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.profileSaveError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.profileEditInfoTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            enabled: !_saving,
            decoration: InputDecoration(labelText: l10n.profileNameLabel),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? l10n.profileSavingInProgress : l10n.commonSave),
        ),
      ],
    );
  }
}
