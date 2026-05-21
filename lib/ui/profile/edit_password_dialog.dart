import 'package:ai_teacher/core/user/data/user_repository.dart';
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
    final oldP = _oldController.text;
    final newP = _newController.text;
    final confirmP = _confirmController.text;
    if (oldP.isEmpty) {
      setState(() => _error = 'Eski parolni kiriting');
      return;
    }
    if (newP.length < 6) {
      setState(() => _error = "Yangi parol kamida 6 ta belgi bo'lishi kerak");
      return;
    }
    if (newP != confirmP) {
      setState(() => _error = "Parollar bir xil emas");
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
        _error = "Parolni o'zgartirishda xatolik";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Parolni o'zgartirish"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _oldController,
            obscureText: true,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'Eski parol'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newController,
            obscureText: true,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'Yangi parol'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            obscureText: true,
            enabled: !_saving,
            decoration: const InputDecoration(
              labelText: 'Yangi parolni takrorlang',
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
          child: const Text('Bekor qilish'),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saqlanmoqda...' : 'Saqlash'),
        ),
      ],
    );
  }
}
