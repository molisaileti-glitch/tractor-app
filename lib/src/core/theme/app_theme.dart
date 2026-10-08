import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const deepGreen = Color(0xFF102A30);
  static const fieldGreen = Color(0xFF16A99A);
  static const successGreen = Color(0xFF16A99A);
  static const mint = Color(0xFFE7F7F5);
  static const cream = Color(0xFFFFF8E8);
  static const pageBackground = Color(0xFFF5F7FA);
  static const cardBackground = Colors.white;
  static const text = Color(0xFF172033);
  static const mutedText = Color(0xFF8492A6);
  static const warning = Color(0xFFC8872B);
  static const info = Color(0xFF277DA1);
  static const danger = Color(0xFFE11D48);
  static const routeBlue = Color(0xFF2563EB);
  static const tractorOrange = Color(0xFFF97316);
  static const purple = Color(0xFF7B4BD2);
}

class AppTheme {
  static ThemeData light() {
    const seed = AppColors.fieldGreen;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    final baseTextTheme = Typography.material2021().black;
    final textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      textTheme: textTheme,
      colorScheme: scheme.copyWith(
        primary: seed,
        secondary: AppColors.warning,
        tertiary: AppColors.info,
        surface: Colors.white,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.pageBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        contentTextStyle: const TextStyle(color: AppColors.text),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.fieldGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.fieldGreen.withValues(alpha: 0.34),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.72),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepGreen,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.fieldGreen, width: 1.6),
        ),
      ),
    );
  }
}
