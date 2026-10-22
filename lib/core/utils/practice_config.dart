import 'dart:math';

import 'level_config.dart';

/// Practice-mode overrides: mixed difficulty, varied grids, more rounds.
abstract final class PracticeConfig {
  static bool _enabled = false;
  static final Random _rng = Random();

  static void setEnabled(bool enabled) => _enabled = enabled;
  static bool get isEnabled => _enabled;

  /// Picks a difficulty tier (1–6) mixing easy and hard around the player's level.
  static int mixedTier(int playerLevel) {
    LevelConfig.setPlayerLevel(playerLevel);
    final base = LevelConfig.tier;
    final roll = _rng.nextInt(100);
    if (roll < 15) return (base - 2).clamp(1, 6);
    if (roll < 35) return (base - 1).clamp(1, 6);
    if (roll < 65) return base;
    if (roll < 85) return (base + 1).clamp(1, 6);
    return (base + 2).clamp(1, 6);
  }

  /// Memory Flip — random board size (pair count varies each session).
  static ({int rows, int cols}) randomMemoryGrid() {
    const presets = [
      (2, 3),
      (2, 4),
      (3, 4),
      (4, 4),
      (4, 5),
      (5, 4),
      (5, 6),
    ];
    final pick = presets[_rng.nextInt(presets.length)];
    return (rows: pick.$1, cols: pick.$2);
  }

  static double previewSecondsForPairs(int pairs) {
    if (pairs <= 4) return 2.5;
    if (pairs <= 8) return 2.0;
    if (pairs <= 10) return 1.5;
    return 1.0;
  }

  /// Focus Find — minimum 5 rounds in practice.
  static int get focusRoundCount => 5 + _rng.nextInt(2);

  /// Per-round grid spec for Focus Find practice.
  static List<({int rows, int cols, int oddCount, int difficulty})>
      focusRoundSpecs(int roundCount) {
    final specs = <({int rows, int cols, int oddCount, int difficulty})>[];
    for (var i = 0; i < roundCount; i++) {
      final difficulty = i < 2 ? 0 : (i < 4 ? 1 : 2);
      final (rows, cols, odds) = switch (difficulty) {
        0 => (3 + _rng.nextInt(2), 3 + _rng.nextInt(2), 1),
        1 => (4 + _rng.nextInt(2), 4 + _rng.nextInt(2), 1 + _rng.nextInt(2)),
        _ => (5 + _rng.nextInt(2), 5 + _rng.nextInt(2), 2 + _rng.nextInt(2)),
      };
      specs.add((rows: rows, cols: cols, oddCount: odds, difficulty: difficulty));
    }
    return specs;
  }

  static int wordSessionCount() => 8 + _rng.nextInt(3);

  /// Map tier (1–6) to a player level for [LevelConfig] temporarily.
  static int levelForTier(int tier) => switch (tier.clamp(1, 6)) {
        1 => 1,
        2 => 7,
        3 => 12,
        4 => 17,
        5 => 22,
        _ => 28,
      };
}

/// Temporarily apply a tier for one generator call.
class TierScope {
  TierScope(int tier) : _saved = LevelConfig.playerLevel {
    LevelConfig.setPlayerLevel(PracticeConfig.levelForTier(tier));
  }

  final int _saved;
  void restore() => LevelConfig.setPlayerLevel(_saved);
}
