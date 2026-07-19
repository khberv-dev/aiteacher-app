import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/cards/data/card_dtos.dart';
import 'package:ai_teacher/core/cards/data/card_repository.dart';
import 'package:ai_teacher/core/cards/presentation/cards_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/utils/uz_phone_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Step { form, otp }

class AddCardDialog extends ConsumerStatefulWidget {
  const AddCardDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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

  late AddCardResult _addResult;
  late String _cardNumber;
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _cardNumber = _cardCtrl.text.replaceAll(' ', '');
      _expireDate = _toApiExpiry(_expiryCtrl.text);
      final phone = UzPhoneFormatter.toE164(_phoneCtrl.text);
      _addResult = await ref
          .read(cardRepositoryProvider)
          .initiateAdd(
            cardNumber: _cardNumber,
            expireDate: _expireDate,
            userPhone: phone,
          );
      setState(() {
        _step = _Step.otp;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = _parseError(e);
        _loading = false;
      });
    }
  }

  Future<void> _onConfirm() async {
    if (_otpFormKey.currentState?.validate() != true) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(cardRepositoryProvider)
          .confirmAdd(
            session: _addResult.session,
            otp: _otpCtrl.text.trim(),
            cardNumber: _cardNumber,
            expireDate: _expireDate,
          );
      ref.invalidate(cardsControllerProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = _parseError(e);
        _loading = false;
      });
    }
  }

  String _parseError(Object e) {
    final l10n = AppLocalizations.of(context);
    final msg = e.toString();
    if (msg.contains('400')) return l10n.profileAddCardInvalidDataError;
    if (msg.contains('404')) return l10n.profileAddCardNotFoundError;
    return l10n.profileAddCardGenericError;
  }

  String? _validateCard(String? value) {
    final l10n = AppLocalizations.of(context);
    final digits = value?.replaceAll(' ', '') ?? '';
    if (digits.isEmpty) return l10n.profileAddCardNumberRequired;
    if (digits.length != 16) return l10n.profileAddCardNumberLengthError;
    return null;
  }

  String? _validateExpiry(String? value) {
    final l10n = AppLocalizations.of(context);
    final v = value ?? '';
    if (v.length != 5) return l10n.profileAddCardExpiryRequired;
    final month = int.tryParse(v.split('/').first) ?? 0;
    if (month < 1 || month > 12) return l10n.profileAddCardExpiryInvalidMonth;
    return null;
  }

  String? _validatePhone(String? value) {
    final l10n = AppLocalizations.of(context);
    final digits = UzPhoneFormatter.digitsOf(value ?? '');
    if (digits.isEmpty) return l10n.profileAddCardPhoneRequired;
    if (digits.length != 9) return l10n.profileAddCardPhoneLengthError;
    return null;
  }

  String? _validateOtp(String? value) {
    final l10n = AppLocalizations.of(context);
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.profileAddCardOtpRequired;
    if (v.length != 6) return l10n.profileAddCardOtpLengthError;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: _step == _Step.form ? _buildFormSheet() : _buildOtpSheet(),
    );
  }

  Widget _buildFormSheet() {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 8, 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.credit_card_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.profileAddCardAction,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loading ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null) ...[
                  _ErrorBanner(_error!),
                  const SizedBox(height: 14),
                ],
                _FieldLabel(l10n.profileAddCardNumberLabel),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(l10n.profileAddCardPhoneLabel),
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 13,
                                ),
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(l10n.profileAddCardExpiryLabel),
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
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _loading ? null : _onInitiate,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.profileAddCardContinueButton,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpSheet() {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          child: Row(
            children: [
              IconButton(
                onPressed: _loading
                    ? null
                    : () => setState(() {
                        _step = _Step.form;
                        _error = null;
                        _otpCtrl.clear();
                      }),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l10n.profileAddCardOtpTitle,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loading ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Form(
            key: _otpFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sms_outlined,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.profileAddCardOtpSentMessage(
                            _addResult.otpSentPhone,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  _ErrorBanner(_error!),
                  const SizedBox(height: 14),
                ],
                _FieldLabel(l10n.profileAddCardOtpLabel),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: _validateOtp,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  buildCounter:
                      (
                        _, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  onChanged: (v) {
                    if (v.length == 6) _onConfirm();
                  },
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: _dec('• • • • • •'),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _loading ? null : _onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.profileAddCardConfirmButton,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
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
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 16,
          color: Color(0xFFEF4444),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final digits = next.text.replaceAll(' ', '');
    if (digits.length > 16) return old;
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final s = buf.toString();
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final digits = next.text.replaceAll('/', '');
    if (digits.length > 4) return old;
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buf.write('/');
      buf.write(digits[i]);
    }
    final s = buf.toString();
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}
