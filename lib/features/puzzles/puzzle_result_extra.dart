import '../../data/models/game_mode.dart';
import '../../data/models/puzzle_type.dart';

class PuzzleResultExtra {
  const PuzzleResultExtra({
    required this.mode,
    required this.type,
    required this.score,
    required this.maxScore,
    required this.accuracy,
    required this.correctCount,
    required this.totalCount,
    this.xpEarned = 0,
    this.sessionComplete = false,
    this.isNewBest = false,
    this.previousBest = 0,
  });

  final GameMode mode;
  final PuzzleType type;
  final int score;
  final int maxScore;
  final double accuracy;
  final int correctCount;
  final int totalCount;
  final int xpEarned;
  final bool sessionComplete;
  final bool isNewBest;
  final int previousBest;
}
