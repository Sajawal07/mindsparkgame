import 'arena_config.dart';
import 'arena_match_state.dart';
import 'puzzle_type.dart';

/// Persisted in-progress arena match (survives app restart).
///
/// Schema version 2: includes [roundOrder] for the 4-game Arena.
/// Legacy snapshots without [roundOrder] (old Math/Memory/Word rounds)
/// are treated as abandoned so aggregation never crashes on old types.
class ArenaMatchSnapshot {
  const ArenaMatchSnapshot({
    required this.playerTotal,
    required this.round,
    required this.playerRoundScores,
    required this.playerPerfectRounds,
    required this.roundOrder,
    this.schemaVersion = 3,
  });

  static const currentSchemaVersion = 3;

  final int playerTotal;
  final int round;
  final List<int> playerRoundScores;
  final List<bool> playerPerfectRounds;
  final List<PuzzleType> roundOrder;
  final int schemaVersion;

  /// True when this snapshot is from the old Arena modes and should be dropped.
  bool get isLegacy =>
      schemaVersion < currentSchemaVersion ||
      roundOrder.length != ArenaConfig.roundsPerMatch;

  factory ArenaMatchSnapshot.fromState(ArenaMatchState state) {
    return ArenaMatchSnapshot(
      playerTotal: state.playerTotal,
      round: state.round,
      playerRoundScores: List<int>.from(state.playerRoundScores),
      playerPerfectRounds: List<bool>.from(state.playerPerfectRounds),
      roundOrder: List<PuzzleType>.from(state.roundOrder),
      schemaVersion: currentSchemaVersion,
    );
  }

  ArenaMatchState toState() {
    final state = ArenaMatchState(
      roundOrder: List<PuzzleType>.from(roundOrder),
    )
      ..playerTotal = playerTotal
      ..round = round
      ..playerRoundScores.addAll(playerRoundScores)
      ..playerPerfectRounds.addAll(playerPerfectRounds);
    return state;
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'playerTotal': playerTotal,
        'round': round,
        'playerRoundScores': playerRoundScores,
        'playerPerfectRounds': playerPerfectRounds,
        'roundOrder': roundOrder.map((t) => t.name).toList(),
      };

  factory ArenaMatchSnapshot.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'] as int? ?? 1;
    final orderRaw = json['roundOrder'] as List<dynamic>?;
    final order = <PuzzleType>[];
    if (orderRaw != null) {
      for (final name in orderRaw) {
        final parsed = _parsePuzzleType(name as String?);
        if (parsed != null) order.add(parsed);
      }
    }

    return ArenaMatchSnapshot(
      playerTotal: json['playerTotal'] as int? ?? 0,
      round: json['round'] as int? ?? 0,
      playerRoundScores: (json['playerRoundScores'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      playerPerfectRounds: (json['playerPerfectRounds'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          [],
      roundOrder: order,
      schemaVersion: version,
    );
  }

  static PuzzleType? _parsePuzzleType(String? name) {
    if (name == null) return null;
    for (final t in PuzzleType.values) {
      if (t.name == name) return t;
    }
    return null;
  }
}
