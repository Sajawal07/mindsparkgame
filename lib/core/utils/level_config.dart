/// Difficulty tiers from PRD section 2.4 based on player level.
abstract final class LevelConfig {
  static int get tier {
    final level = _level;
    if (level <= 5) return 1;
    if (level <= 10) return 2;
    if (level <= 15) return 3;
    if (level <= 20) return 4;
    if (level <= 25) return 5;
    return 6;
  }

  static int _level = 1;

  static int get playerLevel => _level;

  static void setPlayerLevel(int level) => _level = level.clamp(1, 30);

  // Math Blitz
  static int get mathTimeLimitSeconds => switch (tier) {
        1 => 30,
        2 => 25,
        3 => 20,
        4 => 18,
        5 => 15,
        _ => 12,
      };

  static int get mathNumberMax => switch (tier) {
        1 => 20,
        2 => 50,
        3 => 100,
        4 => 200,
        5 => 500,
        _ => 1000,
      };

  static bool get mathUseMultiply => tier >= 2;
  static bool get mathUseDivide => tier >= 3;
  static bool get mathUseAlgebra => tier >= 5;

  // Memory Flip
  static int get memoryRows => switch (tier) {
        1 => 2,
        2 => 3,
        3 => 4,
        4 => 4,
        5 => 5,
        _ => 5,
      };

  static int get memoryCols => switch (tier) {
        1 => 3,
        2 => 4,
        3 => 4,
        4 => 5,
        5 => 5,
        _ => 6,
      };

  static double get memoryPreviewSeconds => switch (tier) {
        1 => 3.0,
        2 => 2.5,
        3 => 2.0,
        4 => 1.5,
        5 => 1.0,
        _ => 0.5,
      };

  // Word Snap
  static int get wordMinLength => switch (tier) {
        1 => 3,
        2 => 4,
        3 => 5,
        4 => 6,
        5 => 7,
        _ => 8,
      };

  static int get wordMaxLength => switch (tier) {
        1 => 4,
        2 => 5,
        3 => 6,
        4 => 7,
        5 => 8,
        _ => 10,
      };

  static int get wordTimeLimitSeconds => switch (tier) {
        1 => 20,
        2 => 18,
        3 => 15,
        4 => 12,
        5 => 10,
        _ => 8,
      };

  // Pattern IQ — option count
  static int get patternChoiceCount => tier <= 1 ? 3 : (tier <= 4 ? 4 : 5);

  // Focus Find
  static int get focusRows => switch (tier) {
        1 => 3,
        2 => 4,
        3 => 4,
        4 => 5,
        5 => 5,
        _ => 6,
      };

  static int get focusCols => switch (tier) {
        1 => 3,
        2 => 4,
        3 => 5,
        4 => 5,
        5 => 6,
        _ => 6,
      };

  static int get focusOddCount => switch (tier) {
        1 => 1,
        2 => 1,
        3 => 2,
        4 => 2,
        5 => 3,
        _ => 3,
      };
}
