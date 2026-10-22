import 'maze_type.dart';

enum MazeDifficulty {
  easy,
  medium,
  hard;

  static const mapsPerDifficulty = 30;

  String get displayName => switch (this) {
        easy => 'Easy',
        medium => 'Medium',
        hard => 'Hard',
      };

  /// Base sizes (map 1–10). Maps 11–20 and 21–30 step up slightly.
  int get squareGridSize => squareGridSizeForMap(0);

  (int rings, int segmentsPerRing) get circularConfig =>
      circularConfigForMap(0);

  int get triangleRows => triangleRowsForMap(0);

  /// Easy ≈ current small maze; Hard is huge (unique path, ~5+ min).
  int squareGridSizeForMap(int mapIndex) {
    final tier = _tier(mapIndex);
    return switch (this) {
      easy => 6 + tier, // 6 → 7 → 8
      medium => 11 + tier * 2, // 11 → 13 → 15
      hard => 24 + tier * 3, // 24 → 27 → 30
    };
  }

  (int rings, int segmentsPerRing) circularConfigForMap(int mapIndex) {
    final tier = _tier(mapIndex);
    return switch (this) {
      easy => (3 + tier, 8 + tier * 2), // (3,8) → (4,10) → (5,12)
      medium => (5 + tier, 12 + tier * 2), // (5,12) → (6,14) → (7,16)
      hard => (11 + tier * 2, 20 + tier * 4), // (11,20) → (13,24) → (15,28)
    };
  }

  int triangleRowsForMap(int mapIndex) {
    final tier = _tier(mapIndex);
    return switch (this) {
      easy => 6 + tier, // 6 → 7 → 8
      medium => 10 + tier * 2, // 10 → 12 → 14
      hard => 20 + tier * 3, // 20 → 23 → 26
    };
  }

  /// Soft time budget for stars / countdown. Hard allows 5+ minutes.
  int get estimatedSolveTimeSeconds => switch (this) {
        easy => 40,
        medium => 90,
        hard => 360, // 6 minutes — large unique-path mazes
      };

  int get starRatingHint => switch (this) {
        easy => 1,
        medium => 2,
        hard => 3,
      };

  /// Deterministic seed so Map N always regenerates the same layout.
  static int seedFor({
    required MazeType type,
    required MazeDifficulty difficulty,
    required int mapIndex,
  }) {
    final map = mapIndex.clamp(0, mapsPerDifficulty - 1);
    return Object.hash(type.index, difficulty.index, map, 0x4D415A45);
  }

  static int _tier(int mapIndex) {
    final i = mapIndex.clamp(0, mapsPerDifficulty - 1);
    return i ~/ 10; // 0, 1, or 2
  }
}
