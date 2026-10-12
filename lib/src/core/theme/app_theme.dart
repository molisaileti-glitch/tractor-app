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
  static const darkBackground = Color(0xFF07111F);
  static const darkSurface = Color(0xFF14212B);
  static const darkSurfaceHigh = Color(0xFF1A2A35);
  static const darkText = Color(0xFFF2F6FA);
  static const darkMutedText = Color(0xFF66D9CE);

  static Color adaptiveText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkText : text;

  static Color adaptiveMutedText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkMutedText
      : mutedText;
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

  static ThemeData dark() {
    const seed = AppColors.fieldGreen;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ).copyWith(
          primary: seed,
          onPrimary: Colors.white,
          secondary: const Color(0xFF35C7B8),
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkText,
          onSurfaceVariant: AppColors.darkMutedText,
          outline: const Color(0xFF334552),
          outlineVariant: const Color(0xFF263743),
          error: const Color(0xFFFF6B81),
        );
    final baseTextTheme = Typography.material2021().white;
    final textTheme = baseTextTheme
        .apply(bodyColor: AppColors.darkText, displayColor: AppColors.darkText)
        .copyWith(
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
        color: AppColors.darkText,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: AppColors.darkText,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: AppColors.darkMutedText,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      textTheme: textTheme,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkSurface,
      dividerColor: scheme.outlineVariant,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: seed.withValues(alpha: 0.22),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? seed
                : AppColors.darkMutedText,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? seed
                : AppColors.darkText,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.darkText,
        iconColor: AppColors.darkMutedText,
        selectedColor: AppColors.fieldGreen,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF273A46)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSurfaceHigh,
        contentTextStyle: const TextStyle(color: AppColors.darkText),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: seed.withValues(alpha: 0.28)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: seed.withValues(alpha: 0.28),
          disabledForegroundColor: Colors.white54,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: seed,
          side: const BorderSide(color: Color(0xFF3A5360)),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceHigh,
        hintStyle: const TextStyle(color: AppColors.darkMutedText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334A57)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: seed, width: 1.6),
        ),
      ),
    );
  }
}
