import '../../data/models/puzzle_type.dart';

abstract final class PuzzleScores {
  static int maxScore(PuzzleType type) => switch (type) {
        PuzzleType.mathBlitz => 150,
        PuzzleType.memoryFlip => 200,
        PuzzleType.patternIq => 200,
        PuzzleType.wordSnap => 240,
        PuzzleType.focusFind => 300,
        PuzzleType.whoAmI => 100,
        PuzzleType.scienceSnap => 100,
        PuzzleType.wordLadder => 300,
        PuzzleType.colorBrain => 300,
        PuzzleType.cupShuffle => 300,
        PuzzleType.weightBalance => 300,
        PuzzleType.pathFinder => 300,
      };

  static int puzzleIndex(PuzzleType type) =>
      PuzzleType.dailyOrder.indexOf(type);
}
