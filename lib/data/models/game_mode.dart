/// How the player entered a puzzle session.
enum GameMode {
  daily,
  practice,
  blitz,
  arena,
}

extension GameModeX on GameMode {
  String get displayName => switch (this) {
        GameMode.daily => 'Daily Challenge',
        GameMode.practice => 'Practice',
        GameMode.blitz => 'Blitz',
        GameMode.arena => 'Arena',
      };

  bool get affectsDailyProgress => this == GameMode.daily;

  bool get awardsCoinsAndXp => this == GameMode.daily || this == GameMode.arena;
}
