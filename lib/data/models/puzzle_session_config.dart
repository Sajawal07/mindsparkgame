import 'game_difficulty.dart';
import 'game_mode.dart';
import 'puzzle_type.dart';

/// Active puzzle context (set before launching a puzzle route).
class PuzzleSessionConfig {
  const PuzzleSessionConfig({
    required this.mode,
    this.type,
    this.arenaRoundIndex,
    this.blitzSessionId,
    this.practiceDifficulty,
  });

  final GameMode mode;
  final PuzzleType? type;
  final int? arenaRoundIndex;
  final String? blitzSessionId;
  final GameDifficulty? practiceDifficulty;

  static const daily = PuzzleSessionConfig(mode: GameMode.daily);

  PuzzleSessionConfig copyWith({
    GameMode? mode,
    PuzzleType? type,
    int? arenaRoundIndex,
    String? blitzSessionId,
    GameDifficulty? practiceDifficulty,
  }) {
    return PuzzleSessionConfig(
      mode: mode ?? this.mode,
      type: type ?? this.type,
      arenaRoundIndex: arenaRoundIndex ?? this.arenaRoundIndex,
      blitzSessionId: blitzSessionId ?? this.blitzSessionId,
      practiceDifficulty: practiceDifficulty ?? this.practiceDifficulty,
    );
  }
}

