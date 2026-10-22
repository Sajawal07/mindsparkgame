/// Difficulty / scoring config for Color Brain (Stroop).
abstract final class ColorBrainConfig {
  /// level → (colorCount, secondsPerWord, autoAdvance)
  static Map<String, dynamic> forLevel(int level) {
    if (level >= 50) {
      return {
        'colors': 8,
        'seconds': 2.0,
        'autoAdvance': true,
        'wordsPerSession': 20,
      };
    }
    if (level >= 30) {
      return {
        'colors': 8,
        'seconds': 4.0,
        'autoAdvance': false,
        'wordsPerSession': 16,
      };
    }
    if (level >= 10) {
      return {
        'colors': 6,
        'seconds': 7.0,
        'autoAdvance': false,
        'wordsPerSession': 14,
      };
    }
    return {
      'colors': 4,
      'seconds': 10.0,
      'autoAdvance': false,
      'wordsPerSession': 12,
    };
  }

  static const basePoints = 12;
  static const streakForX2 = 5;
  static const streakForX5 = 10;

  static double comboMultiplier(int streak) {
    if (streak >= streakForX5) return 5;
    if (streak >= streakForX2) return 2;
    return 1;
  }

  /// Stars: accuracy + avg reaction.
  static int starsFor({
    required double accuracy,
    required double avgReactionMs,
  }) {
    if (accuracy >= 0.9 && avgReactionMs <= 700) return 3;
    if (accuracy >= 0.7 && avgReactionMs <= 1100) return 2;
    if (accuracy >= 0.45) return 1;
    return 0;
  }

  static String rankFor(int score) {
    if (score >= 260) return 'MASTER';
    if (score >= 210) return 'DIAMOND';
    if (score >= 160) return 'GOLD';
    if (score >= 110) return 'SILVER';
    return 'BRONZE';
  }
}
