import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final displayFont = GoogleFonts.orbitron();
    final bodyFont = GoogleFonts.nunito();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: displayFont.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: displayFont.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: displayFont.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: bodyFont.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: bodyFont.copyWith(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: bodyFont.copyWith(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelLarge: bodyFont.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: displayFont.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: bodyFont.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: bodyFont.copyWith(fontSize: 11),
        unselectedLabelStyle: bodyFont.copyWith(fontSize: 11),
      ),
    );
  }
}
