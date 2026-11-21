// ============================================================================
// ملف: app_theme.dart
// الوظيفة: تعريف الهوية البصرية الكاملة للتطبيق (الألوان، الخطوط، الثيم الفاتح
// والداكن). تم استخراج 3 ألوان رئيسية من شعار الشركة (ALMUGAHED CARS):
//   1) اللون الأساسي (Primary)  -> أسود فحمي غامق  #0D0D0D  (خلفية الشعار)
//   2) اللون الثانوي (Secondary)-> أبيض ناصع        #FFFFFF  (رسمة السيارة والنص)
//   3) لون التمييز (Accent)     -> أحمر/كرزي دافئ   #C41E3A  (النص الصغير أسفل الشعار)
//
// ملاحظة: الخط المستخدم هو "Cairo" مرفق محليًا داخل assets/fonts (وليس عبر
// حزمة google_fonts) حتى يعمل التطبيق بالكامل دون الحاجة لاتصال إنترنت.
// ============================================================================

import 'package:flutter/material.dart';

const String kAppFontFamily = 'Cairo';

class AppColors {
  AppColors._();

  // الألوان الثلاثة المستخرجة من الشعار
  static const Color primaryBlack = Color(0xFF0D0D0D);
  static const Color secondaryWhite = Color(0xFFFFFFFF);
  static const Color accentRed = Color(0xFFC41E3A);

  // ألوان مشتقة لدعم الواجهة الفاتحة
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceGrey = Color(0xFF2C2C2C);
  static const Color background = Color(0xFFF7F7F8);
  static const Color textPrimary = Color(0xFF161616);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC41E3A);
  static const Color divider = Color(0xFFE0E0E0);

  // ألوان مخصصة للوضع الداكن
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkDivider = Color(0xFF33333A);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: kAppFontFamily,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlack,
        primary: AppColors.primaryBlack,
        secondary: AppColors.accentRed,
        surface: AppColors.secondaryWhite,
        brightness: Brightness.light,
        error: AppColors.error,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.secondaryWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: kAppFontFamily,
          color: AppColors.secondaryWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.secondaryWhite),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.secondaryWhite,
      ),

      cardTheme: CardThemeData(
        color: AppColors.secondaryWhite,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlack, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        labelStyle: const TextStyle(fontFamily: kAppFontFamily, color: AppColors.textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlack,
          foregroundColor: AppColors.secondaryWhite,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: kAppFontFamily, fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlack,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primaryBlack),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: kAppFontFamily, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      chipTheme: ChipThemeData(
        selectedColor: AppColors.accentRed,
        backgroundColor: AppColors.surfaceGrey.withOpacity(0.08),
        labelStyle: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
    );
  }

  /// الوضع الداكن — نفس هوية الألوان لكن بخلفيات وأسطح داكنة لراحة العين.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: kAppFontFamily,
      scaffoldBackgroundColor: AppColors.darkBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentRed,
        primary: AppColors.secondaryWhite,
        secondary: AppColors.accentRed,
        surface: AppColors.darkSurface,
        brightness: Brightness.dark,
        error: AppColors.error,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.secondaryWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: kAppFontFamily,
          color: AppColors.secondaryWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.secondaryWhite),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.secondaryWhite,
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkDivider),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        labelStyle: const TextStyle(fontFamily: kAppFontFamily, color: AppColors.darkTextSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentRed,
          foregroundColor: AppColors.secondaryWhite,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: kAppFontFamily, fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryWhite,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.darkDivider),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: kAppFontFamily, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.darkDivider, thickness: 1),
    );
  }
}
