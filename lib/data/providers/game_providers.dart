import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme_palette.dart';
import '../models/arena_config.dart';
import '../models/arena_match_state.dart';
import '../models/iap/currency_bundle.dart';
import '../models/puzzle_type.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../services/save_service.dart';
import '../services/storage_service.dart';

export 'puzzle_session_provider.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final gameStateProvider = ChangeNotifierProvider<GameState>((ref) {
  return GameState(SaveService(ref.watch(storageServiceProvider)));
});

final themePaletteProvider = Provider<AppThemePalette>((ref) {
  final player = ref.watch(gameStateProvider.select((g) => g.save.player));
  final themeId = AppThemePalette.themeIdFromEquipped(player.equippedTheme);
  return AppThemePalette.forThemeId(themeId);
});

class GameState extends ChangeNotifier {
  GameState(this.save);

  final SaveService save;
  bool isLoaded = false;
  ArenaMatchState? activeArenaMatch;
  bool pendingLevelUp = false;
  int pendingLevelUpLevel = 0;
  int homeLevelUpCheckTick = 0;
  final _rng = Random();

  void _noteLevelUp(int oldLevel) {
    final newLevel = save.player.level;
    if (newLevel > oldLevel) {
      pendingLevelUp = true;
      pendingLevelUpLevel = newLevel;
    }
  }

  int? consumePendingLevelUp() {
    if (!pendingLevelUp) return null;
    pendingLevelUp = false;
    final level = pendingLevelUpLevel > 0
        ? pendingLevelUpLevel
        : save.player.level;
    pendingLevelUpLevel = 0;
    return level;
  }

  void notifyHomeVisible() {
    homeLevelUpCheckTick++;
    notifyListeners();
  }

  AppThemePalette get palette =>
      AppThemePalette.forThemeId(
        AppThemePalette.themeIdFromEquipped(save.player.equippedTheme),
      );

  Future<void> load({bool force = false}) async {
    if (isLoaded && !force) {
      notifyListeners();
      return;
    }
    try {
      await save.load();
      activeArenaMatch = save.activeArenaMatch;
      // Keep the daily 7:00 PM reminder in sync with the saved progress.
      try {
        await NotificationService.instance
            .syncDailyReminder(isTodayComplete: save.isTodaySessionComplete);
      } catch (e, st) {
        debugPrint('MindSpark: notification sync failed: $e\n$st');
      }
    } catch (e, st) {
      debugPrint('MindSpark: save load failed: $e\n$st');
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<void> _persistArenaMatch() async {
    await save.saveActiveArenaMatch(activeArenaMatch);
  }

  Future<void> completeOnboarding() async {
    await save.completeOnboarding();
    notifyListeners();
  }

  Future<PuzzleCompleteResult> completePuzzle({
    required PuzzleType type,
    required int score,
    required double accuracy,
    required int timeTakenSeconds,
  }) async {
    final oldLevel = save.player.level;
    final outcome = await save.completePuzzle(
      type: type,
      score: score,
      accuracy: accuracy,
      timeTakenSeconds: timeTakenSeconds,
    );
    _noteLevelUp(oldLevel);
    notifyListeners();
    return outcome;
  }

  Future<PracticePuzzleResult> completePracticePuzzle({
    required PuzzleType type,
    required int score,
  }) async {
    final oldLevel = save.player.level;
    final r = await save.completePracticePuzzle(type: type, score: score);
    _noteLevelUp(oldLevel);
    notifyListeners();
    return r;
  }

  Future<BlitzSessionResult> completeBlitzSession(int score) async {
    final oldLevel = save.player.level;
    final r = await save.completeBlitzSession(score);
    _noteLevelUp(oldLevel);
    notifyListeners();
    return r;
  }

  Future<ArenaMatchState?> startArenaMatch() async {
    if (save.player.arenaMatchesRemaining <= 0) return null;

    activeArenaMatch = ArenaMatchState(
      roundOrder: ArenaConfig.generateMatchOrder(_rng),
    );
    await _persistArenaMatch();
    notifyListeners();
    return activeArenaMatch;
  }

  int addArenaRoundScore({
    required int playerRoundScore,
    required int maxRoundScore,
    required bool isPerfect,
  }) {
    final m = activeArenaMatch;
    if (m == null) return 0;

    m.playerRoundScores.add(playerRoundScore);
    m.playerPerfectRounds.add(isPerfect);
    m.playerTotal += playerRoundScore;

    m.round++;

    _persistArenaMatch();
    notifyListeners();
    return 0;
  }

  Future<ArenaMatchResult?> finishArenaMatch() async {
    final m = activeArenaMatch;
    if (m == null) return null;
    final oldLevel = save.player.level;
    final result = await save.completeArenaMatch(
      playerScore: m.playerTotal,
      perfectRoundCount: m.perfectRoundCount,
    );
    activeArenaMatch = null;
    _noteLevelUp(oldLevel);
    notifyListeners();
    return result;
  }

  Future<void> abandonArenaMatch() async {
    activeArenaMatch = null;
    await save.clearActiveArenaMatch();
    notifyListeners();
  }

  PuzzleType? get currentArenaRoundType {
    final m = activeArenaMatch;
    if (m == null || m.isComplete) return null;
    return m.currentRoundType;
  }

  Future<String?> purchaseItem(String itemId) async {
    final err = await save.purchaseItem(itemId);
    notifyListeners();
    return err;
  }

  Future<String?> equipItem(String itemId) async {
    final err = await save.equipItem(itemId);
    notifyListeners();
    return err;
  }

  Future<bool> consumeClueToken() async {
    final success = await save.consumeClueToken();
    if (success) notifyListeners();
    return success;
  }

  Future<bool> spendCoins(int amount) async {
    final success = await save.spendCoins(amount);
    if (success) notifyListeners();
    return success;
  }

  Future<int> addCoins(int amount) async {
    final newBalance = await save.addCoins(amount);
    notifyListeners();
    return newBalance;
  }

  Future<int?> claimChallenge(String id) async {
    final coins = await save.claimChallenge(id);
    notifyListeners();
    return coins;
  }

  Future<int?> claimShareReward() async {
    final coins = await save.claimShareReward();
    notifyListeners();
    return coins;
  }

  Future<void> updateAudioSettings(AudioSettings settings) async {
    await save.saveAudioSettings(settings);
    notifyListeners();
  }

  Future<CurrencyGrantResult> grantCurrencyBundle(CurrencyBundle bundle) async {
    final result = await save.grantCurrencyBundle(bundle);
    notifyListeners();
    return result;
  }

  bool get arenaUnlockDialogShown => save.arenaUnlockDialogShown;

  Future<void> markArenaUnlockDialogShown() async {
    await save.markArenaUnlockDialogShown();
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
