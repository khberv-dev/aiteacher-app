import 'package:ai_teacher/core/user/data/user_repository.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditPasswordDialog extends ConsumerStatefulWidget {
  const EditPasswordDialog({super.key});

  @override
  ConsumerState<EditPasswordDialog> createState() => _EditPasswordDialogState();
}

class _EditPasswordDialogState extends ConsumerState<EditPasswordDialog> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final oldP = _oldController.text;
    final newP = _newController.text;
    final confirmP = _confirmController.text;
    if (oldP.isEmpty) {
      setState(() => _error = l10n.profileOldPasswordRequired);
      return;
    }
    if (newP.length < 6) {
      setState(() => _error = l10n.profileNewPasswordMinLengthError);
      return;
    }
    if (newP != confirmP) {
      setState(() => _error = l10n.profilePasswordsMismatchError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(userRepositoryProvider)
          .updatePassword(oldPassword: oldP, newPassword: newP);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.profileChangePasswordError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.profileChangePassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _oldController,
            obscureText: true,
            enabled: !_saving,
            decoration: InputDecoration(
              labelText: l10n.profileOldPasswordLabel,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newController,
            obscureText: true,
            enabled: !_saving,
            decoration: InputDecoration(
              labelText: l10n.profileNewPasswordLabel,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            obscureText: true,
            enabled: !_saving,
            decoration: InputDecoration(
              labelText: l10n.profileConfirmNewPasswordLabel,
            ),
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
