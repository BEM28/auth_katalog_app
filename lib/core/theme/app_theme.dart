import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF693C);
  static const Color onPrimary = Colors.white;
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFECEEF2);
  static const Color text = Color(0xFF1B1B1F);
  static const Color textMuted = Color(0xFF8A8F98);
  static const Color success = Color(0xFF2BB673);
  static const Color error = Color(0xFFE5484D);

  static const double rSm = 8;
  static const double rMd = 12;
  static const double rLg = 16;
  static const double rPill = 999;

  // Kompatibilitas dengan pemakaian lama (AppColors.radius / AppColors.accent).
  static const double radius = rPill;
  static const Color accent = primary;
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    surface: AppColors.surface,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.radius),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.radius),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.radius),
      borderSide: const BorderSide(color: AppColors.accent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.radius),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.radius),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.text,
    elevation: 0,
  ),
);
