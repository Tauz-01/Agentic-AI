import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const canvas = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const navy = Color(0xFF0F172A);
  static const navySoft = Color(0xFF1E293B);
  static const muted = Color(0xFF64748B);
  static const outline = Color(0xFFE2E8F0);
  static const outlineStrong = Color(0xFFCBD5E1);
  static const sky = Color(0xFF0284C7);
  static const skySoft = Color(0xFFE0F2FE);
  static const skyBorder = Color(0xFFBAE6FD);
  static const ember = Color(0xFFEA580C);
  static const emberSoft = Color(0xFFFFF7ED);
  static const emberBorder = Color(0xFFFED7AA);
  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFDCFCE7);
  static const successBorder = Color(0xFF86EFAC);
  static const successText = Color(0xFF15803D);
  static const demoFill = Color(0xFFF1F5F9);
  static const delayText = Color(0xFFC2410C);
}

class AppTheme {
  static ThemeData light() {
    final text = GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.navy,
      displayColor: AppColors.navy,
    );
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        onPrimary: Colors.white,
        secondary: AppColors.sky,
        surface: AppColors.surface,
        error: Color(0xFFBA1A1A),
      ),
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outline),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sky, width: 2),
        ),
      ),
    );
  }
}

TextStyle tabular(TextStyle style) => style.copyWith(fontFeatures: const [
      FontFeature.tabularFigures(),
    ]);
