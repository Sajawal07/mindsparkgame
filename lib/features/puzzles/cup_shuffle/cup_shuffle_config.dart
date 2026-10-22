/// Difficulty / scoring config for Cup Shuffle.
enum CupShuffleDifficulty { easy, medium, hard, master }

abstract final class CupShuffleConfig {
  static const roundsPerSession = 5;
  static const maxScore = 300;

  /// Ball briefly visible before cups cover it.
  static const ballRevealMs = 1200;
  static const coverMs = 380;
  static const revealHoldMs = 900;
  static const betweenRoundsMs = 700;

  /// Swap animation ranges (hand-shuffled feel).
  static const swapDurationMinMs = 280;
  static const swapDurationMaxMs = 550;
  static const swapPauseMinMs = 50;
  static const swapPauseMaxMs = 150;
  static const liftPx = -24.0;
  static const feintLiftPx = -12.0;
  static const feintChance = 0.22;

  /// level / mode → difficulty settings map.
  static const Map<CupShuffleDifficulty, Map<String, dynamic>> difficultyConfig =
      {
    CupShuffleDifficulty.easy: {
      'cups': 3,
      'swaps': 5,
      'randomSpeed': false,
      'feints': false,
      'pointsPerWin': 50,
      'baseDurationMs': 420,
    },
    CupShuffleDifficulty.medium: {
      'cups': 4,
      'swaps': 10,
      'randomSpeed': false,
      'feints': false,
      'pointsPerWin': 55,
      'baseDurationMs': 380,
    },
    CupShuffleDifficulty.hard: {
      'cups': 5,
      'swaps': 15,
      'randomSpeed': false,
      'feints': false,
      'pointsPerWin': 60,
      'baseDurationMs': 340,
    },
    CupShuffleDifficulty.master: {
      'cups': 5,
      'swaps': 15,
      'randomSpeed': true,
      'feints': true,
      'pointsPerWin': 60,
      'baseDurationMs': 320,
    },
  };

  /// Map player level (and arena) to difficulty.
  /// Arena uses Medium or Hard based on player level.
  static CupShuffleDifficulty forPlayerLevel(
    int level, {
    required bool isArena,
  }) {
    if (isArena) {
      return level >= 25
          ? CupShuffleDifficulty.hard
          : CupShuffleDifficulty.medium;
    }
    if (level >= 50) return CupShuffleDifficulty.master;
    if (level >= 30) return CupShuffleDifficulty.hard;
    if (level >= 10) return CupShuffleDifficulty.medium;
    return CupShuffleDifficulty.easy;
  }

  static CupShuffleSettings settingsFor(CupShuffleDifficulty difficulty) {
    final map = difficultyConfig[difficulty]!;
    return CupShuffleSettings(
      difficulty: difficulty,
      cupCount: map['cups'] as int,
      swapCount: map['swaps'] as int,
      randomSpeed: map['randomSpeed'] as bool,
      includesFeints: map['feints'] as bool,
      pointsPerWin: map['pointsPerWin'] as int,
      baseDurationMs: map['baseDurationMs'] as int,
    );
  }

  static CupShuffleSettings forPlayer(
    int level, {
    required bool isArena,
  }) {
    return settingsFor(forPlayerLevel(level, isArena: isArena));
  }
}

class CupShuffleSettings {
  const CupShuffleSettings({
    required this.difficulty,
    required this.cupCount,
    required this.swapCount,
    required this.randomSpeed,
    required this.includesFeints,
    required this.pointsPerWin,
    required this.baseDurationMs,
  });

  final CupShuffleDifficulty difficulty;
  final int cupCount;
  final int swapCount;
  final bool randomSpeed;
  final bool includesFeints;
  final int pointsPerWin;
  final int baseDurationMs;

  String get label => switch (difficulty) {
        CupShuffleDifficulty.easy => 'Easy',
        CupShuffleDifficulty.medium => 'Medium',
        CupShuffleDifficulty.hard => 'Hard',
        CupShuffleDifficulty.master => 'Master',
      };
}
