import '../models/player_model.dart';
import '../models/store_item.dart';

class StoreService {
  /// Returns a human-readable lock reason if the item cannot be unlocked,
  /// or null if it can.
  String? canUnlock(StoreItem item, PlayerModel player, GameUnlockContext ctx) {
    final req = item.unlockRequirement;
    if (req == null) return null;
    if (req.startsWith('level_')) {
      final lvl = int.tryParse(req.substring(6)) ?? 0;
      if (player.level < lvl) return 'Requires Level $lvl';
      return null;
    }

    return switch (req) {
      'einstein_rank' =>
        player.hasReachedEinsteinRank ? null : 'Reach Einstein rank first',
      'streak_7'  => player.longestStreakEver >= 7  ? null : 'Requires 7-day streak',
      'streak_14' => player.longestStreakEver >= 14 ? null : 'Requires 14-day streak',
      'streak_30' => player.longestStreakEver >= 30 ? null : 'Requires 30-day streak',
      'streak_60' => player.longestStreakEver >= 60 ? null : 'Requires 60-day streak',
      'streak_100' => player.longestStreakEver >= 100 ? null : 'Requires 100-day streak',
      'math_140_x20' =>
        player.mathBlitz140PlusCount >= 20 ? null : 'Score 140+ on Math Blitz 20 times',
      'memory_perfect_x50' =>
        player.perfectMemoryFlipCount >= 50 ? null : '50 perfect Memory Flip games',
      'pattern_perfect_x30' =>
        player.perfectPatternIQCount >= 30 ? null : 'Perfect Pattern IQ 30 times',
      'word_perfect_x30' =>
        player.perfectWordSnapCount >= 30 ? null : 'Perfect Word Snap 30 times',
      'focus_perfect_x25' =>
        player.perfectFocusCount >= 25 ? null : 'Perfect Focus Find 25 times',
      'daily_challenges_x50' =>
        player.dailyChallengesCompletedTotal >= 50 ? null : 'Complete 50 daily challenges',
      'arena_wins_50' =>
        player.arenaWins >= 50 ? null : 'Requires 50 Arena Wins',
      _ => null,
    };
  }

  bool isOwned(StoreItem item, PlayerModel player) {
    if (item.category == StoreCategory.theme && item.id == 'theme_default') {
      return true;
    }
    if (item.category == StoreCategory.avatar &&
        (item.id == StoreCatalog.defaultAvatarId || item.id == 'avatar_the_rookie')) {
      return true;
    }
    return player.ownedItems.contains(item.id);
  }

  bool isEquipped(StoreItem item, PlayerModel player) {
    return switch (item.category) {
      StoreCategory.theme        => player.equippedTheme == item.id,
      StoreCategory.frame        => player.equippedFrame == item.id,
      StoreCategory.title        => player.equippedTitle == item.id,
      StoreCategory.victoryFlair => player.equippedVictoryFlair == item.id,
      StoreCategory.avatar       => player.equippedAvatar == item.id,
      StoreCategory.powerUp      => false,
    };
  }

  String? validatePurchase(
    StoreItem item,
    PlayerModel player,
    GameUnlockContext ctx,
  ) {
    if (StoreCatalog.isArenaExclusive(item.id) &&
        item.currencyType != CurrencyType.arenaPoints) {
      return 'Arena items can only be purchased with Arena Points';
    }
    if (StoreCatalog.isMainStoreItem(item.id) &&
        item.currencyType != CurrencyType.coins) {
      return 'Main store items use coins only';
    }
    if (isOwned(item, player) && item.category != StoreCategory.powerUp) {
      return 'Already owned';
    }
    final unlock = canUnlock(item, player, ctx);
    if (unlock != null) return unlock;

    if (item.currencyType == CurrencyType.coins) {
      if (player.coins < item.cost) return 'Not enough coins';
    } else {
      if (player.arenaPoints < item.cost) return 'Not enough AP';
    }

    if (item.category == StoreCategory.powerUp && item.maxStock != null) {
      final stock = player.powerupInventory[item.id] ?? 0;
      if (stock >= item.maxStock!) return 'Max stock reached';
    }
    return null;
  }

  /// Main Store: coins catalog only. Arena Store: AP catalog only.
  List<StoreItem> getItemsByCategory(
    StoreCategory category,
    CurrencyType currencyType, [
    PlayerModel? player,
  ]) {
    final catalog = currencyType == CurrencyType.coins
        ? StoreCatalog.mainStoreItems
        : StoreCatalog.arenaStoreItems;
    return catalog.where((i) => i.category == category).toList();
  }
}

class GameUnlockContext {
  const GameUnlockContext({
    required this.hasEinsteinRank,
    required this.lifetimeCounters,
    required this.dailyChallengesCompleted,
  });

  final bool hasEinsteinRank;
  final Map<String, int> lifetimeCounters;
  final int dailyChallengesCompleted;

  int counter(String key) => lifetimeCounters[key] ?? 0;
}
