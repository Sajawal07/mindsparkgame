import '../../data/models/arena_config.dart';
import '../../data/models/puzzle_type.dart';

/// Raw session metrics used to produce a fair 0–100 Arena round score,
/// then scaled to [ArenaConfig.maxScorePerRound] (300).
class ArenaRoundRawResult {
  const ArenaRoundRawResult({
    required this.accuracy,
    this.avgReactionMs,
    this.timeTakenSeconds,
    this.mistakes = 0,
    this.won = true,
    this.streak = 0,
    this.difficultyFactor = 1.0,
  });

  /// 0–1 correct ratio or equivalent.
  final double accuracy;

  /// Color Brain: average reaction time in ms (lower is better).
  final double? avgReactionMs;

  /// Path Finder / Weight Balance: seconds to finish.
  final int? timeTakenSeconds;

  final int mistakes;
  final bool won;

  /// Cup Shuffle / Color Brain: best streak this session.
  final int streak;

  /// 0.8–1.2 difficulty weight.
  final double difficultyFactor;
}

/// Normalize each game's native metrics to a comparable 0–100 score.
///
/// Formulas:
/// - **Color Brain**: `0.55 * accuracy% + 0.30 * reactionPercentile + 0.15 * streakBonus`
///   Reaction percentile: 350ms → 100, 1500ms → 0 (linear).
/// - **Cup Shuffle**: `correct ? (70 + speedBonus + difficultyBonus) : (accuracy * 40)`
///   Win with higher difficulty and fewer mistakes scores higher.
/// - **Weight Balance**: `correctness * 70 + timeBonus * 30` (faster solve → more).
/// - **Path Finder**: `completion * 60 + timeBonus * 25 - mistakesPenalty * 15`
abstract final class ArenaScoreNormalize {
  static double normalizeRoundScore(
    PuzzleType gameType,
    ArenaRoundRawResult raw,
  ) {
    final score = switch (gameType) {
      PuzzleType.colorBrain => _colorBrain(raw),
      PuzzleType.cupShuffle => _cupShuffle(raw),
      PuzzleType.weightBalance => _weightBalance(raw),
      PuzzleType.pathFinder => _pathFinder(raw),
      _ => (raw.accuracy * 100).clamp(0.0, 100.0),
    };
    return (score * raw.difficultyFactor).clamp(0.0, 100.0);
  }

  /// Map 0–100 normalized score → Arena points (0–300).
  static int toArenaPoints(double normalized0to100) =>
      ((normalized0to100 / 100) * ArenaConfig.maxScorePerRound)
          .round()
          .clamp(0, ArenaConfig.maxScorePerRound);

  static double _colorBrain(ArenaRoundRawResult raw) {
    final accuracyPart = raw.accuracy * 55;
    final ms = raw.avgReactionMs ?? 900;
    final reactionPct = (1 - ((ms - 350) / (1500 - 350))).clamp(0.0, 1.0);
    final reactionPart = reactionPct * 30;
    final streakPart = (raw.streak / 15).clamp(0.0, 1.0) * 15;
    return accuracyPart + reactionPart + streakPart;
  }

  static double _cupShuffle(ArenaRoundRawResult raw) {
    if (raw.won) {
      final speed = raw.timeTakenSeconds == null
          ? 15.0
          : (1 - (raw.timeTakenSeconds! / 45).clamp(0.0, 1.0)) * 20;
      final diff = ((raw.difficultyFactor - 0.8) / 0.4).clamp(0.0, 1.0) * 10;
      return 70 + speed + diff;
    }
    return (raw.accuracy * 40).clamp(0.0, 40.0);
  }

  static double _weightBalance(ArenaRoundRawResult raw) {
    final correct = raw.won || raw.accuracy >= 1.0 ? 70.0 : raw.accuracy * 70;
    final t = raw.timeTakenSeconds ?? 60;
    final timeBonus = (1 - (t / 90).clamp(0.0, 1.0)) * 30;
    return correct + timeBonus;
  }

  static double _pathFinder(ArenaRoundRawResult raw) {
    final completion = raw.won ? 60.0 : raw.accuracy * 40;
    final t = raw.timeTakenSeconds ?? 90;
    final timeBonus = (1 - (t / 120).clamp(0.0, 1.0)) * 25;
    final mistakePenalty = (raw.mistakes * 5).clamp(0, 15).toDouble();
    return (completion + timeBonus - mistakePenalty).clamp(0.0, 100.0);
  }
}
