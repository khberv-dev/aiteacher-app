import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/cards/data/card_dtos.dart';
import 'package:ai_teacher/core/cards/data/card_repository.dart';
import 'package:ai_teacher/core/cards/presentation/cards_controller.dart';
import 'package:ai_teacher/utils/uz_phone_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Step { form, otp }

class AddCardDialog extends ConsumerStatefulWidget {
  const AddCardDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddCardDialog(),
    );
  }

  @override
  ConsumerState<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends ConsumerState<AddCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  _Step _step = _Step.form;
  bool _loading = false;
  String? _error;

  // retained between steps
  late AddCardResult _addResult;
  late String _cardNumber; // digits only
  late String _expireDate; // YYMM

  @override
  void dispose() {
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // MM/YY → YYMM
  String _toApiExpiry(String input) {
    final parts = input.split('/');
    if (parts.length != 2) return input;
    return '${parts[1]}${parts[0]}';
  }

  Future<void> _onInitiate() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() { _loading = true; _error = null; });
    try {
      _cardNumber = _cardCtrl.text.replaceAll(' ', '');
      _expireDate = _toApiExpiry(_expiryCtrl.text);
      final phone = UzPhoneFormatter.toE164(_phoneCtrl.text);
      _addResult = await ref.read(cardRepositoryProvider).initiateAdd(
        cardNumber: _cardNumber,
        expireDate: _expireDate,
        userPhone: phone,
      );
      setState(() { _step = _Step.otp; _loading = false; });
    } catch (e) {
      setState(() { _error = _parseError(e); _loading = false; });
    }
  }

  Future<void> _onConfirm() async {
    if (_otpFormKey.currentState?.validate() != true) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(cardRepositoryProvider).confirmAdd(
        session: _addResult.session,
        otp: _otpCtrl.text.trim(),
        cardNumber: _cardNumber,
        expireDate: _expireDate,
      );
      ref.invalidate(cardsControllerProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() { _error = _parseError(e); _loading = false; });
    }
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('400')) return "Karta ma'lumotlari noto'g'ri";
    if (msg.contains('404')) return 'Karta topilmadi';
    return 'Xatolik yuz berdi';
  }

  String? _validateCard(String? value) {
    final digits = value?.replaceAll(' ', '') ?? '';
    if (digits.isEmpty) return 'Karta raqamini kiriting';
    if (digits.length != 16) return "16 ta raqam bo'lishi kerak";
    return null;
  }

  String? _validateExpiry(String? value) {
    final v = value ?? '';
    if (v.length != 5) return "Amal qilish muddatini kiriting";
    final month = int.tryParse(v.split('/').first) ?? 0;
    if (month < 1 || month > 12) return "Noto'g'ri oy";
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = UzPhoneFormatter.digitsOf(value ?? '');
    if (digits.isEmpty) return 'Telefon raqamini kiriting';
    if (digits.length != 9) return "9 ta raqam bo'lishi kerak";
    return null;
  }

  String? _validateOtp(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Kodni kiriting';
    if (v.length < 4) return 'Kod noto\'g\'ri';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _step == _Step.form ? _buildFormDialog() : _buildOtpDialog();
  }

  Widget _buildFormDialog() {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Karta qo'shish",
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              _ErrorBanner(_error!),
              const SizedBox(height: 12),
            ],
            _FieldLabel('KARTA RAQAMI'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _cardCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [_CardNumberFormatter()],
              validator: _validateCard,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: Color(0xFF0F172A),
              ),
              decoration: _dec('8600 0000 0000 0000'),
            ),
            const SizedBox(height: 14),
            _FieldLabel('TELEFON RAQAMI'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: const [UzPhoneFormatter()],
              validator: _validatePhone,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: _dec('90 123 45 67').copyWith(
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  child: Text(
                    '+998',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(height: 14),
            _FieldLabel('AMAL QILISH MUDDATI'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _expiryCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [_ExpiryFormatter()],
              validator: _validateExpiry,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: Color(0xFF0F172A),
              ),
              decoration: _dec('MM/YY'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Bekor qilish',
            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
        ),
        FilledButton(
          onPressed: _loading ? null : _onInitiate,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text("Davom etish", style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildOtpDialog() {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Tasdiqlash',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Form(
        key: _otpFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_addResult.otpSentPhone} raqamiga tasdiqlash kodi yuborildi',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              _ErrorBanner(_error!),
              const SizedBox(height: 12),
            ],
            _FieldLabel('TASDIQLASH KODI'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateOtp,
              autofocus: true,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                color: Color(0xFF0F172A),
              ),
              decoration: _dec('• • • • • •'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading
              ? null
              : () => setState(() { _step = _Step.form; _error = null; _otpCtrl.clear(); }),
          child: const Text(
            'Orqaga',
            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
        ),
        FilledButton(
          onPressed: _loading ? null : _onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text("Tasdiqlash", style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: Color(0xFFCBD5E1),
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.5,
    ),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF64748B),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      message,
      style: const TextStyle(
        color: Color(0xFFEF4444),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    if (digits.length > 16) return old;
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final s = buf.toString();
    return TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('/', '');
    if (digits.length > 4) return old;
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buf.write('/');
      buf.write(digits[i]);
    }
    final s = buf.toString();
    return TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}
