import '../models/puzzle_type.dart';

typedef AchievementListener = void Function(AchievementEvent event);

/// Game-completion event bus for achievements.
/// Games emit events; ChallengeService / UI can listen without games knowing
/// about specific achievement IDs.
class AchievementEvent {
  const AchievementEvent({
    required this.type,
    required this.score,
    required this.accuracy,
    this.perfect = false,
    this.extra = const {},
  });

  final PuzzleType type;
  final int score;
  final double accuracy;
  final bool perfect;
  final Map<String, Object?> extra;
}

abstract final class AchievementService {
  static final List<AchievementListener> _listeners = [];

  static void addListener(AchievementListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(AchievementListener listener) {
    _listeners.remove(listener);
  }

  static void emit(AchievementEvent event) {
    for (final l in List<AchievementListener>.from(_listeners)) {
      l(event);
    }
  }

  static void emitGameComplete({
    required PuzzleType type,
    required int score,
    required double accuracy,
    bool perfect = false,
    Map<String, Object?> extra = const {},
  }) {
    emit(AchievementEvent(
      type: type,
      score: score,
      accuracy: accuracy,
      perfect: perfect,
      extra: extra,
    ));
  }
}
