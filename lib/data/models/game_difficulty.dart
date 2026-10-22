enum GameDifficulty {
  easy,
  medium,
  hard;

  String get label => switch (this) {
        GameDifficulty.easy => 'Easy',
        GameDifficulty.medium => 'Medium',
        GameDifficulty.hard => 'Hard',
      };

  /// Simulated player level for difficulty calculations:
  /// Easy: level 5
  /// Medium: level 20
  /// Hard: level 40
  int get simulatedLevel => switch (this) {
        GameDifficulty.easy => 5,
        GameDifficulty.medium => 20,
        GameDifficulty.hard => 40,
      };
}
