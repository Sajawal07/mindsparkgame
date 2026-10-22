/// Difficulty / scoring config for Weight Balance.
enum WeightBalanceDifficulty {
  easy,
  medium,
  hard,
  expert,
}

extension WeightBalanceDifficultyX on WeightBalanceDifficulty {
  String get label => switch (this) {
        WeightBalanceDifficulty.easy => 'Easy',
        WeightBalanceDifficulty.medium => 'Medium',
        WeightBalanceDifficulty.hard => 'Hard',
        WeightBalanceDifficulty.expert => 'Expert',
      };

  int get unknownCount => switch (this) {
        WeightBalanceDifficulty.easy => 2,
        WeightBalanceDifficulty.medium => 2,
        WeightBalanceDifficulty.hard => 3,
        WeightBalanceDifficulty.expert => 4,
      };

  /// MCQ for all difficulties on mobile — keypad was clipping the Done key.
  bool get useKeypad => false;

  /// Seconds allowed per puzzle (forces fast decisions).
  int get secondsPerPuzzle => switch (this) {
        WeightBalanceDifficulty.easy => 25,
        WeightBalanceDifficulty.medium => 20,
        WeightBalanceDifficulty.hard => 18,
        WeightBalanceDifficulty.expert => 15,
      };

  double get difficultyFactor => switch (this) {
        WeightBalanceDifficulty.easy => 0.85,
        WeightBalanceDifficulty.medium => 1.0,
        WeightBalanceDifficulty.hard => 1.1,
        WeightBalanceDifficulty.expert => 1.2,
      };
}

abstract final class WeightBalanceConfig {
  static const emojis = ['🍎', '🍌', '🍇', '🍊', '🍉', '🍓'];

  static const puzzlesPerSession = 5;
  static const maxScore = 300;

  /// Base points per correct answer (5 × 40 = 200).
  static const basePointsPerCorrect = 40;

  /// Max speed bonus per puzzle (5 × 20 = 100 → total 300).
  static const maxSpeedBonus = 20;

  /// Soft time target (seconds) for full speed bonus.
  static const speedTargetSeconds = 8;

  /// Hard cutoff (seconds) after which speed bonus is 0.
  static const speedCutoffSeconds = 25;

  static int speedBonusFor(double elapsedSeconds) {
    if (elapsedSeconds <= speedTargetSeconds) return maxSpeedBonus;
    if (elapsedSeconds >= speedCutoffSeconds) return 0;
    final t = (elapsedSeconds - speedTargetSeconds) /
        (speedCutoffSeconds - speedTargetSeconds);
    return (maxSpeedBonus * (1 - t)).round().clamp(0, maxSpeedBonus);
  }

  static int starsFor({
    required double accuracy,
    required double avgSeconds,
  }) {
    if (accuracy >= 0.9 && avgSeconds <= 10) return 3;
    if (accuracy >= 0.7 && avgSeconds <= 16) return 2;
    if (accuracy >= 0.4) return 1;
    return 0;
  }

  static String rankFor(int score) {
    if (score >= 260) return 'MASTER';
    if (score >= 210) return 'DIAMOND';
    if (score >= 160) return 'GOLD';
    if (score >= 110) return 'SILVER';
    return 'BRONZE';
  }

  /// Map player level → session difficulty mix.
  static List<WeightBalanceDifficulty> sessionDifficulties(int level) {
    if (level <= 5) {
      return const [
        WeightBalanceDifficulty.easy,
        WeightBalanceDifficulty.easy,
        WeightBalanceDifficulty.easy,
        WeightBalanceDifficulty.medium,
        WeightBalanceDifficulty.medium,
      ];
    }
    if (level <= 12) {
      return const [
        WeightBalanceDifficulty.easy,
        WeightBalanceDifficulty.medium,
        WeightBalanceDifficulty.medium,
        WeightBalanceDifficulty.hard,
        WeightBalanceDifficulty.hard,
      ];
    }
    if (level <= 20) {
      return const [
        WeightBalanceDifficulty.medium,
        WeightBalanceDifficulty.medium,
        WeightBalanceDifficulty.hard,
        WeightBalanceDifficulty.hard,
        WeightBalanceDifficulty.expert,
      ];
    }
    return const [
      WeightBalanceDifficulty.medium,
      WeightBalanceDifficulty.hard,
      WeightBalanceDifficulty.hard,
      WeightBalanceDifficulty.expert,
      WeightBalanceDifficulty.expert,
    ];
  }

  /// Arena: medium→hard progression across the 5 puzzles.
  static List<WeightBalanceDifficulty> arenaDifficulties(int level) {
    if (level <= 10) {
      return const [
        WeightBalanceDifficulty.easy,
        WeightBalanceDifficulty.medium,
        WeightBalanceDifficulty.medium,
        WeightBalanceDifficulty.hard,
        WeightBalanceDifficulty.hard,
      ];
    }
    return const [
      WeightBalanceDifficulty.medium,
      WeightBalanceDifficulty.medium,
      WeightBalanceDifficulty.hard,
      WeightBalanceDifficulty.hard,
      WeightBalanceDifficulty.expert,
    ];
  }
}
