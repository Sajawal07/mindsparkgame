import 'package:flutter/material.dart';

import '../../data/models/store_item.dart';

class AppThemePalette {
  const AppThemePalette({
    required this.backgroundGradient,
    required this.primary,
    required this.primaryLight,
  });

  final LinearGradient backgroundGradient;
  final Color primary;
  final Color primaryLight;

  static AppThemePalette forThemeId(String themeId) {
    return switch (themeId) {
      'theme_neon_city' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0033), Color(0xFF0A0014)],
          ),
          primary: Color(0xFFFF00E5),
          primaryLight: Color(0xFF00FFFF),
        ),
      'theme_nature_zen' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B3D2F), Color(0xFF0D1F17)],
          ),
          primary: Color(0xFF66BB6A),
          primaryLight: Color(0xFFA5D6A7),
        ),
      'theme_retro_arcade' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D1B4E), Color(0xFF12082A)],
          ),
          primary: Color(0xFFFF5722),
          primaryLight: Color(0xFFFFEB3B),
        ),
      'theme_golden_luxury' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A2410), Color(0xFF0D0B1E)],
          ),
          primary: Color(0xFFFFD700),
          primaryLight: Color(0xFFFFF8E1),
        ),
      'theme_ocean_deep' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D3B66), Color(0xFF051525)],
          ),
          primary: Color(0xFF0288D1),
          primaryLight: Color(0xFF4FC3F7),
        ),
      'theme_dark_galaxy' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1040), Color(0xFF0D0B1E)],
          ),
          primary: Color(0xFF7C4DFF),
          primaryLight: Color(0xFFB388FF),
        ),
      'theme_ancient_wisdom' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D2E14), Color(0xFF1A1208)],
          ),
          primary: Color(0xFFC9A227),
          primaryLight: Color(0xFFE8D48B),
        ),
      'theme_equation_storm' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1A33), Color(0xFF020810)],
          ),
          primary: Color(0xFF29B6F6),
          primaryLight: Color(0xFF81D4FA),
        ),
      'theme_neuron_network' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A2E), Color(0xFF0A0514)],
          ),
          primary: Color(0xFFAB47BC),
          primaryLight: Color(0xFFCE93D8),
        ),
      'theme_periodic_table' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D2B22), Color(0xFF051410)],
          ),
          primary: Color(0xFF26A69A),
          primaryLight: Color(0xFF80CBC4),
        ),
      'arena_theme_gladiator' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D1F0A), Color(0xFF1A0D05)],
          ),
          primary: Color(0xFFFF7043),
          primaryLight: Color(0xFFFFAB91),
        ),
      'arena_theme_blood_moon' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E0A0A), Color(0xFF140505)],
          ),
          primary: Color(0xFFE53935),
          primaryLight: Color(0xFFEF9A9A),
        ),
      'arena_theme_battle_of_minds' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0A0A14)],
          ),
          primary: Color(0xFF5C6BC0),
          primaryLight: Color(0xFF9FA8DA),
        ),
      'arena_theme_lightning_theorem' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2233), Color(0xFF080C14)],
          ),
          primary: Color(0xFFFFEE58),
          primaryLight: Color(0xFFFFF59D),
        ),
      'arena_theme_war_of_scholars' => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1F10), Color(0xFF100C06)],
          ),
          primary: Color(0xFF8D6E63),
          primaryLight: Color(0xFFBCAAA4),
        ),
      _ => const AppThemePalette(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1040), Color(0xFF0D0B1E)],
          ),
          primary: Color(0xFF7C4DFF),
          primaryLight: Color(0xFFB388FF),
        ),
    };
  }

  static String themeIdFromEquipped(String equipped) {
    if (equipped.isEmpty || equipped == StoreCatalog.defaultThemeId) {
      return StoreCatalog.defaultThemeId;
    }
    return equipped;
  }
}
