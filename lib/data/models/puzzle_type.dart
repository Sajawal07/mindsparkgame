import '../../core/constants/app_assets.dart';

enum PuzzleType {
  mathBlitz,
  memoryFlip,
  patternIq,
  wordSnap,
  focusFind,
  whoAmI,
  scienceSnap,
  wordLadder,
  colorBrain,
  cupShuffle,
  weightBalance,
  pathFinder;

  /// Fast-paced games that rotate in Blitz Mode (60s solo).
  static const List<PuzzleType> blitzGames = [
    PuzzleType.mathBlitz,
    PuzzleType.wordSnap,
    PuzzleType.patternIq,
    PuzzleType.scienceSnap,
    PuzzleType.focusFind,
  ];

  static const List<PuzzleType> dailyOrder = [
    PuzzleType.mathBlitz,
    PuzzleType.memoryFlip,
    PuzzleType.patternIq,
    PuzzleType.wordSnap,
    PuzzleType.focusFind,
    PuzzleType.whoAmI,
    PuzzleType.scienceSnap,
    PuzzleType.wordLadder,
  ];

  /// Premium Arena games — also playable from Practice via explicit launch.
  static const List<PuzzleType> arenaGames = [
    PuzzleType.colorBrain,
    PuzzleType.cupShuffle,
    PuzzleType.weightBalance,
    PuzzleType.pathFinder,
  ];
}

extension PuzzleTypeX on PuzzleType {
  String get displayName => switch (this) {
        PuzzleType.mathBlitz => 'Math Blitz',
        PuzzleType.memoryFlip => 'Memory Flip',
        PuzzleType.patternIq => 'Pattern IQ',
        PuzzleType.wordSnap => 'Word Snap',
        PuzzleType.focusFind => 'Focus Find',
        PuzzleType.whoAmI => 'Who Am I',
        PuzzleType.scienceSnap => 'Science Snap',
        PuzzleType.wordLadder => 'Word Ladder',
        PuzzleType.colorBrain => 'Color Brain',
        PuzzleType.cupShuffle => 'Cup Shuffle',
        PuzzleType.weightBalance => 'Weight Balance',
        PuzzleType.pathFinder => 'Path Finder',
      };

  String get iconAsset => switch (this) {
        PuzzleType.mathBlitz => AppAssets.mathBlitzIcon,
        PuzzleType.memoryFlip => AppAssets.memoryFlipIcon,
        PuzzleType.patternIq => AppAssets.patternIqIcon,
        PuzzleType.wordSnap => AppAssets.wordSnapIcon,
        PuzzleType.focusFind => AppAssets.focusFindIcon,
        PuzzleType.whoAmI => AppAssets.whoAmIIcon,
        PuzzleType.scienceSnap => AppAssets.scienceSnapIcon,
        PuzzleType.wordLadder => AppAssets.wordLadderIcon,
        PuzzleType.colorBrain => AppAssets.patternIqIcon,
        PuzzleType.cupShuffle => AppAssets.memoryFlipIcon,
        PuzzleType.weightBalance => AppAssets.mathBlitzIcon,
        PuzzleType.pathFinder => AppAssets.focusFindIcon,
      };

  String get islandAsset => switch (this) {
        PuzzleType.mathBlitz => AppAssets.islandMathBlitz,
        PuzzleType.memoryFlip => AppAssets.islandMemoryFlip,
        PuzzleType.patternIq => AppAssets.islandPatternIq,
        PuzzleType.wordSnap => AppAssets.islandWordSnap,
        PuzzleType.focusFind => AppAssets.islandFocusFind,
        PuzzleType.whoAmI => AppAssets.islandWhoAmI,
        PuzzleType.scienceSnap => AppAssets.islandScienceSnap,
        PuzzleType.wordLadder => AppAssets.islandWordLadder,
        PuzzleType.colorBrain => AppAssets.islandPatternIq,
        PuzzleType.cupShuffle => AppAssets.islandMemoryFlip,
        PuzzleType.weightBalance => AppAssets.islandMathBlitz,
        PuzzleType.pathFinder => AppAssets.islandFocusFind,
      };
}
