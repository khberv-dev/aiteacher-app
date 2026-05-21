import 'package:flutter/services.dart';

/// Formats a stream of digits into the Uzbek operator+number layout
/// `XX XXX XX XX` (e.g. `993334455` -> `99 333 44 55`). Caps input at 9 digits.
class UzPhoneFormatter extends TextInputFormatter {
  const UzPhoneFormatter();

  static const int _maxDigits = 9;

  static String format(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > _maxDigits
        ? digits.substring(0, _maxDigits)
        : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 2 || i == 5 || i == 7) buffer.write(' ');
      buffer.write(capped[i]);
    }
    return buffer.toString();
  }

  static String digitsOf(String formatted) =>
      formatted.replaceAll(RegExp(r'\D'), '');

  /// Returns the E.164-formatted phone (`+998XXXXXXXXX`) from any input that
  /// contains the 9-digit Uzbek subscriber number.
  static String toE164(String formatted) => '+998${digitsOf(formatted)}';

  /// Formats any phone input — bare digits, national, or E.164 — into the
  /// national display layout `XX XXX XX XX`. Uses the last 9 digits.
  static String formatNational(String input) {
    final digits = digitsOf(input);
    if (digits.isEmpty) return '';
    final last9 = digits.length > _maxDigits
        ? digits.substring(digits.length - _maxDigits)
        : digits;
    return format(last9);
  }

  /// Same as [formatNational] but prefixed with the `+998` country code,
  /// e.g. `+998 99 777 88 99`.
  static String formatInternational(String input) {
    final national = formatNational(input);
    if (national.isEmpty) return '';
    return '+998 $national';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = format(newValue.text);
    final digitsBeforeCursor = newValue.text
        .substring(
          0,
          newValue.selection.baseOffset.clamp(0, newValue.text.length),
        )
        .replaceAll(RegExp(r'\D'), '')
        .length;
    final cursor = _cursorForDigitIndex(formatted, digitsBeforeCursor);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  int _cursorForDigitIndex(String formatted, int digitIndex) {
    if (digitIndex <= 0) return 0;
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (formatted[i] != ' ') {
        seen++;
        if (seen == digitIndex) return i + 1;
      }
    }
    return formatted.length;
  }
}
