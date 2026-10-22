import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF0D0B1E);
  static const Color surface = Color(0xFF1A1730);
  static const Color surfaceLight = Color(0xFF252244);
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFFB388FF);
  static const Color accent = Color(0xFF00E5FF);
  static const Color gold = Color(0xFFFFD54F);
  static const Color streakOrange = Color(0xFFFF6D00);
  static const Color success = Color(0xFF69F0AE);
  static const Color error = Color(0xFFFF5252);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0AEC8);
  static const Color ringEmpty = Color(0xFF3D3A5C);
  static const Color ringFilled = Color(0xFF7C4DFF);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1040), Color(0xFF0D0B1E)],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
  );
}
