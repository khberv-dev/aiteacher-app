import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/app/theme/app_radius.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const String fontFamily = 'PlusJakartaSans';

  static const double inputCornerRadius = 14;
  static const Color inputHintColor = Color(0xFFCCCCCC);

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textInverse,
      primaryContainer: AppColors.primarySubtle,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.accent,
      onSecondary: AppColors.navy,
      tertiary: AppColors.navy,
      onTertiary: AppColors.textInverse,
      error: Color(0xFFC41A1A),
      onError: AppColors.textInverse,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.background,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.borderStrong,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.border,
      inputDecorationTheme: _inputDecorationTheme,
      filledButtonTheme: _filledButtonTheme,
      iconButtonTheme: _iconButtonTheme,
      cardTheme: _cardTheme,
    );
  }

  static const InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: inputHintColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(inputCornerRadius)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(inputCornerRadius)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(inputCornerRadius)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(inputCornerRadius)),
          borderSide: BorderSide(color: Color(0xFFC41A1A), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(inputCornerRadius)),
          borderSide: BorderSide(color: Color(0xFFC41A1A), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(inputCornerRadius)),
          borderSide: BorderSide.none,
        ),
        errorStyle: TextStyle(
          color: Color(0xFFC41A1A),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );

  static final FilledButtonThemeData _filledButtonTheme = FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
      foregroundColor: const WidgetStatePropertyAll(AppColors.textInverse),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(54)),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      elevation: const WidgetStatePropertyAll(0),
    ),
  );

  static final IconButtonThemeData _iconButtonTheme = IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(AppColors.textTertiary),
      backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
      padding: const WidgetStatePropertyAll(EdgeInsets.all(9)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
      ),
      iconSize: const WidgetStatePropertyAll(18),
    ),
  );

  static const CardThemeData _cardTheme = CardThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shadowColor: Color(0x14000000),
    elevation: 2,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
    ),
  );
}
