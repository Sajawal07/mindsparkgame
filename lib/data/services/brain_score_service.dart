import '../../core/utils/puzzle_scores.dart';
import '../models/daily_session_model.dart';
import '../models/iq_rank.dart';
export '../models/iq_rank.dart';
import '../models/player_model.dart';
import '../models/puzzle_type.dart';

abstract final class BrainScoreService {
  static int get maxPuzzleScore => PuzzleType.dailyOrder
      .map(PuzzleScores.maxScore)
      .fold(0, (sum, max) => sum + max);

  static int calculateBrainScore({
    required DailySessionModel session,
    required PlayerModel player,
  }) {
    final results = session.puzzleResults.where((r) => r.isComplete).toList();
    if (results.length < PuzzleType.dailyOrder.length) return 0;

    final totalScore =
        results.fold<int>(0, (sum, r) => sum + r.score.clamp(0, 999));
    final accuracy = totalScore / maxPuzzleScore;
    final accuracyPts = (accuracy * 400).round().clamp(0, 400);

    final avgTime = results.fold<int>(0, (s, r) => s + r.timeTakenSeconds) /
        results.length;
    final speedRatio = (1 - (avgTime / 300)).clamp(0.0, 1.0);
    final speedPts = (speedRatio * 300).round().clamp(0, 300);

    var consistencyPts = 120;
    if (player.streak >= 7) consistencyPts += 40;
    if (session.isComplete) consistencyPts += 40;
    consistencyPts = consistencyPts.clamp(0, 200);

    final difficultyPts =
        (player.level / PlayerModel.maxLevel * 100).round().clamp(0, 100);

    return (accuracyPts + speedPts + consistencyPts + difficultyPts)
        .clamp(0, 1000);
  }

  static IqRank iqRankForScore(int brainScore) => IqRank.fromBrainScore(brainScore);

  static IqRank simulateIqForRound({required int score, required int maxScore}) {
    if (maxScore <= 0) return IqRank.fromBrainScore(0);
    final percentage = (score / maxScore).clamp(0.0, 1.0);
    final simulatedScore = (percentage * 1000).round();
    return IqRank.fromBrainScore(simulatedScore);
  }

  static int coinsForDailySession({
    required DailySessionModel session,
    required bool wasStreakExtended,
  }) {
    var coins = 100;
    for (final r in session.puzzleResults) {
      if (!r.isComplete) continue;
      final max = PuzzleScores.maxScore(r.puzzleType);
      if (r.score >= max) coins += 50;
    }
    return coins;
  }
}
