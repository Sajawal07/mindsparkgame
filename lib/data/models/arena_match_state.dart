import 'arena_config.dart';
import 'puzzle_type.dart';

/// In-progress arena match (4 randomized rounds).
class ArenaMatchState {
  ArenaMatchState({
    List<PuzzleType>? roundOrder,
  }) : roundOrder = roundOrder ?? ArenaConfig.generateMatchOrder();

  final List<PuzzleType> roundOrder;
  int playerTotal = 0;
  int round = 0;
  final List<int> playerRoundScores = [];
  final List<bool> playerPerfectRounds = [];

  bool get isComplete => round >= ArenaConfig.roundsPerMatch;

  int get perfectRoundCount =>
      playerPerfectRounds.where((p) => p).length;

  PuzzleType? get currentRoundType {
    if (isComplete || round < 0 || round >= roundOrder.length) return null;
    return roundOrder[round];
  }
}
