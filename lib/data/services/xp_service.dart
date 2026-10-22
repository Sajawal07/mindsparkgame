import '../models/player_model.dart';
import '../models/puzzle_result_model.dart';

abstract final class XpService {
  static int calculatePuzzleXp({
    required PuzzleResultModel result,
    required bool hasActiveStreak7,
    required int maxScore,
    required int playerLevel,
  }) {
    var xp = 50;

    if (result.accuracy > 0.8) xp += 20;

    final speedRatio = maxScore > 0 ? result.score / maxScore : 0;
    if (speedRatio >= 0.7) xp += 15;

    if (result.accuracy >= 1.0 && result.score >= maxScore) xp += 30;

    if (hasActiveStreak7) xp += 25;

    if (playerLevel >= 15) {
      if (result.accuracy < 1.0) {
        final wrongRatio = 1.0 - result.accuracy;
        int penalty = (wrongRatio * 150).round();
        xp -= penalty;
      }
    }

    return xp;
  }

  static int sessionCompleteBonus() => 50;

  static PlayerModel applyXp(PlayerModel player, int xpGain) {
    var level = player.level;
    var xp = player.xp + xpGain;
    var coins = player.coins;

    while (xp < 0 && level > 1) {
      level--;
      xp += PlayerModel.xpRequiredForLevel(level);
    }
    if (xp < 0 && level == 1) {
      xp = 0;
    }

    while (level < PlayerModel.maxLevel && xp >= PlayerModel.xpRequiredForLevel(level)) {
      xp -= PlayerModel.xpRequiredForLevel(level);
      level++;
      coins += 150;
    }

    return player.copyWith(level: level, xp: xp, coins: coins);
  }
}
