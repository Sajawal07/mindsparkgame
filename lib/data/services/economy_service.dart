/// Unified coins + XP reporting surface for premium games.
///
/// Games report earnings here; persistence still flows through [SaveService]
/// via [finishPuzzleAndShowResult] / Arena completion — this keeps currency
/// math in one place for standalone session rewards.
abstract final class EconomyService {
  /// Coins from a finished session given normalized performance 0–1.
  static int coinsForSession({
    required double performance01,
    required int stars,
    bool won = true,
  }) {
    if (!won && performance01 < 0.25) return 5;
    final base = (12 + performance01 * 28).round();
    final starBonus = stars * 4;
    return (base + starBonus).clamp(5, 60);
  }

  /// XP from a finished session.
  static int xpForSession({
    required double performance01,
    required int stars,
    bool won = true,
  }) {
    if (!won && performance01 < 0.25) return 15;
    final base = (40 + performance01 * 120).round();
    final starBonus = stars * 15;
    return (base + starBonus).clamp(15, 250);
  }
}
