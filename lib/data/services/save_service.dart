import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

import '../../core/utils/arena_week_utils.dart';
import '../../core/utils/puzzle_scores.dart';
import '../models/arena_config.dart';
import '../models/arena_match_snapshot.dart';
import '../models/arena_match_state.dart';
import '../models/challenge_model.dart';
import '../models/daily_session_model.dart';
import '../models/game_meta_model.dart';
import '../models/player_model.dart';
import '../models/puzzle_result_model.dart';
import '../models/iap/currency_bundle.dart';
import '../models/mode_progress_model.dart';
import '../models/puzzle_type.dart';
import '../models/store_item.dart';
import 'arena_leaderboard_service.dart';
import 'audio_service.dart';
import 'brain_score_service.dart';
import 'challenge_service.dart';
import 'storage_service.dart';
import 'notification_service.dart';
import 'store_service.dart';
import 'xp_service.dart';
import 'app_backend_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PracticePuzzleResult {
  const PracticePuzzleResult({
    required this.score,
    required this.isNewBest,
    required this.previousBest,
    this.xpEarned = 0,
  });

  final int score;
  final bool isNewBest;
  final int previousBest;
  final int xpEarned;
}

class BlitzSessionResult {
  const BlitzSessionResult({
    required this.score,
    required this.beatAllTimeBest,
    required this.beatTodayBest,
    required this.coinsEarned,
    required this.xpEarned,
    required this.motivationalMessage,
  });

  final int score;
  final bool beatAllTimeBest;
  final bool beatTodayBest;
  final int coinsEarned;
  final int xpEarned;
  final String motivationalMessage;

  bool get isNewHighScore => beatAllTimeBest;
}

class ArenaMatchResult {
  const ArenaMatchResult({
    required this.playerScore,
    required this.arenaPointsDelta,
    required this.coinsEarned,
    required this.xpEarned,
    this.perfectRoundBonus = 0,
    this.baseAp = 0,
  });

  final int playerScore;
  final int arenaPointsDelta;
  final int coinsEarned;
  final int xpEarned;
  final int perfectRoundBonus;
  final int baseAp;
}

class CurrencyGrantResult {
  const CurrencyGrantResult({
    required this.coinsGranted,
    required this.arenaPointsGranted,
  });

  final int coinsGranted;
  final int arenaPointsGranted;
}

class PuzzleCompleteResult {
  const PuzzleCompleteResult({
    required this.xpEarned,
    required this.coinsEarned,
    required this.sessionNowComplete,
    required this.brainScore,
  });

  final int xpEarned;
  final int coinsEarned;
  final bool sessionNowComplete;
  final int brainScore;
}

class SaveService {
  SaveService(this._storage)
      : _challengeService = ChallengeService(),
        _storeService = StoreService();

  final StorageService _storage;
  final ChallengeService _challengeService;
  final StoreService _storeService;

  PlayerModel _player = const PlayerModel();
  DailySessionModel? _todaySession;
  GameMetaModel _meta = const GameMetaModel();

  PlayerModel get player => _player;
  DailySessionModel? get todaySession => _todaySession;
  GameMetaModel get meta => _meta;

  static String todayDateKey() =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  static String yesterdayDateKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd').format(yesterday);
  }

  Future<void> load() async {
    Map<String, dynamic>? playerData;
    Map<String, dynamic>? metaData;
    Map<String, dynamic>? sessionData;
    final today = todayDateKey();

    final userDoc = AppBackendService.instance.userDoc;
    if (userDoc != null) {
      try {
        print("Fetching userDoc...");
        final snap = await userDoc.get(const GetOptions(source: Source.serverAndCache)).timeout(const Duration(seconds: 3));
        print("userDoc fetched.");
        if (snap.exists && snap.data() != null) {
          final data = snap.data()!;
          if (data['player'] != null) playerData = Map<String, dynamic>.from(data['player']);
          if (data['meta'] != null) metaData = Map<String, dynamic>.from(data['meta']);
        }
        
        print("Fetching sessionDoc...");
        final sessionSnap = await AppBackendService.instance.userSessionsCollection?.doc(today).get(const GetOptions(source: Source.serverAndCache)).timeout(const Duration(seconds: 3));
        print("sessionDoc fetched.");
        if (sessionSnap != null && sessionSnap.exists && sessionSnap.data() != null) {
          sessionData = Map<String, dynamic>.from(sessionSnap.data()!);
        }
      } catch (e) {
        print("Firestore fetch failed or timed out: $e");
      }
    }

    if (playerData == null) playerData = _storage.getPlayerData();
    if (metaData == null) metaData = _storage.getMetaData();
    if (sessionData == null) sessionData = _storage.getDailySession(today);

    _player = playerData != null
        ? PlayerModel.fromJson(playerData)
        : const PlayerModel();

    final user = AppBackendService.instance.currentUser;
    if (user != null) {
      String newName = _player.name;
      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        newName = user.displayName!.trim().split(' ').first;
      } else if (user.email != null && user.email!.trim().isNotEmpty) {
        newName = user.email!.trim().split('@').first;
      }
      
      if (newName.isNotEmpty && newName != _player.name) {
        _player = _player.copyWith(name: newName);
        unawaited(ArenaLeaderboardService.instance.syncPlayerStats(_player));
      } else if (_player.name == 'Player') {
        // Just in case it never synced
        unawaited(ArenaLeaderboardService.instance.syncPlayerStats(_player));
      }
    }

    // Seed default theme
    if (!_player.ownedItems.contains(StoreCatalog.defaultThemeId)) {
      _player = _player.copyWith(
        ownedItems: [..._player.ownedItems, StoreCatalog.defaultThemeId],
        equippedTheme: _player.equippedTheme.isEmpty
            ? StoreCatalog.defaultThemeId
            : _player.equippedTheme,
      );
    }
    // Seed default avatar
    if (!_player.ownedItems.contains(StoreCatalog.defaultAvatarId)) {
      _player = _player.copyWith(
        ownedItems: [..._player.ownedItems, StoreCatalog.defaultAvatarId],
        equippedAvatar: _player.equippedAvatar.isEmpty
            ? StoreCatalog.defaultAvatarId
            : _player.equippedAvatar,
      );
    }

    _validateStreak();

    _todaySession = sessionData != null
        ? DailySessionModel.fromJson(sessionData)
        : DailySessionModel(dateKey: today);

    _meta = metaData != null
        ? GameMetaModel.fromJson(metaData)
        : const GameMetaModel();

    _meta = _challengeService.ensureChallenges(_meta, today);

    // Drop in-progress Arena matches from the old 3-round Math/Memory/Word format.
    final arenaSnap = _meta.activeArenaMatch;
    if (arenaSnap != null &&
        (arenaSnap.isLegacy ||
            arenaSnap.round >= ArenaConfig.roundsPerMatch)) {
      _meta = _meta.copyWith(clearActiveArenaMatch: true);
    }

    // Migration from ModeProgress to PlayerModel
    final progress = _meta.modeProgress;
    _player = _player.copyWith(
      arenaPoints: _player.arenaPoints == 0 && progress.arenaPoints != 100
          ? progress.arenaPoints
          : _player.arenaPoints,
      arenaWins: _player.arenaWins == 0
          ? progress.arenaWins
          : _player.arenaWins,
      arenaLosses: _player.arenaLosses == 0
          ? progress.arenaLosses
          : _player.arenaLosses,
      blitzAllTimeBest: _player.blitzAllTimeBest == 0
          ? progress.blitzHighScore
          : _player.blitzAllTimeBest,
      blitzTotalRuns: _player.blitzTotalRuns == 0
          ? progress.totalBlitzSessions
          : _player.blitzTotalRuns,
      arenaMatchesRemaining: _player.arenaCycleRefreshTime.isEmpty
          ? progress.availableArenaMatches
          : _player.arenaMatchesRemaining,
      arenaCycleRefreshTime: _player.arenaCycleRefreshTime.isEmpty
          ? progress.lastArenaMatchGenTime
          : _player.arenaCycleRefreshTime,
      arenaAllTimeAP: _player.arenaAllTimeAP == 0
          ? _player.arenaPoints
          : _player.arenaAllTimeAP,
    );

    _refreshArenaMatches();
    _refreshArenaWeeklyAP();

    final audioJson = _storage.getAudioSettings();
    AudioService.instance.applySettings(AudioSettings.fromJson(audioJson));
    await AudioService.instance.init();

    await _persistPlayer();
    await _persistMeta();
  }

  void _refreshArenaMatches() {
    var matches = _player.arenaMatchesRemaining;
    var lastGenStr = _player.arenaCycleRefreshTime;
    final now = DateTime.now();

    if (lastGenStr.isEmpty) {
      _player = _player.copyWith(
        arenaMatchesRemaining: 3,
        arenaCycleRefreshTime: now.toIso8601String(),
      );
      _syncArenaMatchesToMeta(matches: 3, refreshTime: now.toIso8601String());
      return;
    }

    final lastGen = DateTime.tryParse(lastGenStr) ?? now;
    final diff = now.difference(lastGen);
    final hours = diff.inHours;

    if (hours >= 8 && matches < 3) {
      final generated = hours ~/ 8;
      matches = (matches + generated).clamp(0, 3);
      final newLast = lastGen.add(Duration(hours: 8 * generated));
      final refreshIso = newLast.toIso8601String();

      _player = _player.copyWith(
        arenaMatchesRemaining: matches,
        arenaCycleRefreshTime: refreshIso,
      );
      _syncArenaMatchesToMeta(matches: matches, refreshTime: refreshIso);
    }
  }

  void _refreshArenaWeeklyAP() {
    final weekKey = ArenaWeekUtils.currentWeekKey();
    if (_player.arenaWeeklyResetWeekKey == weekKey) return;

    _player = _player.copyWith(
      arenaWeeklyAP: 0,
      arenaWeeklyResetWeekKey: weekKey,
    );
  }

  ArenaMatchState? get activeArenaMatch {
    final snapshot = _meta.activeArenaMatch;
    if (snapshot == null) return null;
    // Drop legacy 3-round (Math/Memory/Word) snapshots — keep win/loss/AP history.
    if (snapshot.isLegacy ||
        snapshot.round >= ArenaConfig.roundsPerMatch) {
      return null;
    }
    return snapshot.toState();
  }

  Future<void> saveActiveArenaMatch(ArenaMatchState? match) async {
    if (match == null || match.isComplete) {
      _meta = _meta.copyWith(clearActiveArenaMatch: true);
    } else {
      _meta = _meta.copyWith(
        activeArenaMatch: ArenaMatchSnapshot.fromState(match),
      );
    }
    await _persistMeta();
  }

  Future<void> clearActiveArenaMatch() => saveActiveArenaMatch(null);

  void _syncArenaMatchesToMeta({required int matches, required String refreshTime}) {
    _meta = _meta.copyWith(
      modeProgress: _meta.modeProgress.copyWith(
        availableArenaMatches: matches,
        lastArenaMatchGenTime: refreshTime,
      ),
    );
  }

  DateTime? get arenaNextRefreshTime {
    final refresh = _player.arenaCycleRefreshTime;
    if (refresh.isEmpty) return null;
    final base = DateTime.tryParse(refresh);
    if (base == null) return null;
    return base.add(const Duration(hours: 8));
  }

  Future<void> saveAudioSettings(AudioSettings settings) async {
    AudioService.instance.applySettings(settings);
    await _storage.saveAudioSettings(settings.toJson());
  }

  ModeProgressModel get modeProgress => _meta.modeProgress;

  void _validateStreak() {
    final today = todayDateKey();
    final yesterday = yesterdayDateKey();
    final last = _player.lastPlayDateKey;

    if (last.isEmpty || last == today || last == yesterday) {
      return;
    }
    if (_player.streak > 0) {
      _player = _player.copyWith(streak: 0);
    }
  }

  GameUnlockContext get unlockContext => GameUnlockContext(
        hasEinsteinRank: _meta.hasReachedEinsteinRank,
        lifetimeCounters: _meta.lifetimeCounters,
        dailyChallengesCompleted: _meta.lifetimeCounters['daily_claimed'] ?? 0,
      );

  Future<void> completeOnboarding() async {
    _player = _player.copyWith(onboardingComplete: true);
    await _persistPlayer();
  }

  Future<void> saveTodaySession(DailySessionModel session) async {
    _todaySession = session;
    await _storage.saveDailySession(session.dateKey, session.toJson());
    try {
      AppBackendService.instance.userSessionsCollection?.doc(session.dateKey).set(session.toJson());
    } catch (_) {}
  }

  Future<void> _persistPlayer() async {
    await _storage.savePlayerData(_player.toJson());
    try {
      AppBackendService.instance.userDoc?.set({'player': _player.toJson()}, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _persistMeta() async {
    await _storage.saveMetaData(_meta.toJson());
    try {
      AppBackendService.instance.userDoc?.set({'meta': _meta.toJson()}, SetOptions(merge: true));
    } catch (_) {}
  }

  bool get isTodaySessionComplete => _todaySession?.isComplete ?? false;

  bool canClaimShareReward() =>
      _meta.lastShareRewardDateKey != todayDateKey();

  bool get arenaUnlockDialogShown => _meta.arenaUnlockDialogShown;

  Future<void> markArenaUnlockDialogShown() async {
    if (_meta.arenaUnlockDialogShown) return;
    _meta = _meta.copyWith(arenaUnlockDialogShown: true);
    await _persistMeta();
  }

  PuzzleResultModel? getPuzzleResult(PuzzleType type) {
    final session = _todaySession;
    if (session == null) return null;
    for (final r in session.puzzleResults) {
      if (r.puzzleType == type) return r;
    }
    return null;
  }

  bool isPuzzleComplete(int index) {
    if (index < 0 || index >= PuzzleType.dailyOrder.length) return false;
    final type = PuzzleType.dailyOrder[index];
    return getPuzzleResult(type)?.isComplete ?? false;
  }

  bool isPuzzleUnlocked(int index) {
    if (index == 0) return true;
    return isPuzzleComplete(index - 1);
  }

  Future<String?> purchaseItem(String itemId) async {
    final item = StoreCatalog.byId(itemId);
    if (item == null) return 'Item not found';

    if (StoreCatalog.isArenaAvatar(itemId) &&
        item.currencyType != CurrencyType.arenaPoints) {
      return 'Arena avatars can only be purchased with Arena Points';
    }

    final error = _storeService.validatePurchase(item, _player, unlockContext);
    if (error != null) return error;

    var owned = List<String>.from(_player.ownedItems);
    var coins = _player.coins;
    var arenaPoints = _player.arenaPoints;
    var stock = Map<String, int>.from(_player.powerupInventory);

    if (item.currencyType == CurrencyType.coins) {
      coins -= item.cost;
    } else {
      arenaPoints -= item.cost;
    }

    var clueTokens = _player.clueTokens;
    var hasGeniusPass = _player.hasGeniusPass;

    if (item.category == StoreCategory.powerUp) {
      if (item.id == 'powerup_whoami_clue') {
        clueTokens += 1;
      } else if (item.id == 'powerup_whoami_clue_pack') {
        clueTokens += 3;
      } else if (item.id == 'powerup_whoami_clue_chest') {
        clueTokens += 10;
      } else if (item.id == 'powerup_genius_pass') {
        hasGeniusPass = true;
      } else {
        stock[item.id] = (stock[item.id] ?? 0) + 1;
      }
    } else if (!owned.contains(item.id)) {
      owned.add(item.id);
    }

    _player = _player.copyWith(
      coins: coins, 
      arenaPoints: arenaPoints, 
      ownedItems: owned, 
      powerupInventory: stock,
      clueTokens: clueTokens,
      hasGeniusPass: hasGeniusPass,
    );
    await _persistPlayer();
    return null;
  }

  Future<bool> consumeClueToken() async {
    if (_player.clueTokens > 0) {
      _player = _player.copyWith(clueTokens: _player.clueTokens - 1);
      await _persistPlayer();
      return true;
    }
    return false;
  }

  Future<bool> spendCoins(int amount) async {
    if (amount <= 0 || _player.coins < amount) return false;
    _player = _player.copyWith(coins: _player.coins - amount);
    await _persistPlayer();
    return true;
  }

  Future<int> addCoins(int amount) async {
    if (amount <= 0) return _player.coins;
    _player = _player.copyWith(coins: _player.coins + amount);
    await _persistPlayer();
    return _player.coins;
  }

  /// Grants coins / AP from an IAP bundle (after billing confirms purchase).
  Future<CurrencyGrantResult> grantCurrencyBundle(CurrencyBundle bundle) async {
    _player = _player.copyWith(
      coins: _player.coins + bundle.coins,
      arenaPoints: _player.arenaPoints + bundle.arenaPoints,
    );
    if (bundle.arenaPoints > 0) {
      _meta = _meta.copyWith(
        modeProgress: _meta.modeProgress.copyWith(
          arenaPoints: _player.arenaPoints,
        ),
      );
      await _persistMeta();
    }
    await _persistPlayer();
    return CurrencyGrantResult(
      coinsGranted: bundle.coins,
      arenaPointsGranted: bundle.arenaPoints,
    );
  }

  Future<String?> equipItem(String itemId) async {
    final item = StoreCatalog.byId(itemId);
    if (item == null) return 'Item not found';
    if (item.category == StoreCategory.powerUp) {
      return 'Cannot equip power-ups';
    }
    if (!_storeService.isOwned(item, _player)) return 'Not owned';

    _player = _player.copyWith(
      equippedTheme:
          item.category == StoreCategory.theme ? item.id : _player.equippedTheme,
      equippedFrame:
          item.category == StoreCategory.frame ? item.id : _player.equippedFrame,
      equippedTitle:
          item.category == StoreCategory.title ? item.id : _player.equippedTitle,
      equippedVictoryFlair:
          item.category == StoreCategory.victoryFlair ? item.id : _player.equippedVictoryFlair,
      equippedAvatar:
          item.category == StoreCategory.avatar ? item.id : _player.equippedAvatar,
    );
    await _persistPlayer();
    return null;
  }

  Future<int?> claimChallenge(String challengeId) async {
    final index = _meta.challenges.indexWhere((c) => c.id == challengeId);
    if (index < 0) return null;

    final c = _meta.challenges[index];
    if (!c.isComplete || c.isClaimed) return null;

    final updated = c.copyWith(isClaimed: true);
    final challenges = List<ChallengeModel>.from(_meta.challenges)
      ..[index] = updated;

    var counters = Map<String, int>.from(_meta.lifetimeCounters);
    if (c.type == ChallengeType.daily) {
      counters['daily_claimed'] = (counters['daily_claimed'] ?? 0) + 1;
    }

    _player = _player.copyWith(
      coins: _player.coins + c.rewardCoins,
      dailyChallengesCompletedTotal: _player.dailyChallengesCompletedTotal + (c.type == ChallengeType.daily ? 1 : 0),
    );
    _meta = _meta.copyWith(challenges: challenges, lifetimeCounters: counters);

    await _persistPlayer();
    await _persistMeta();
    return c.rewardCoins;
  }

  Future<int?> claimShareReward() async {
    if (!canClaimShareReward()) return null;
    const reward = 25;
    _player = _player.copyWith(coins: _player.coins + reward);
    _meta = _meta.copyWith(lastShareRewardDateKey: todayDateKey());
    await _persistPlayer();
    await _persistMeta();
    return reward;
  }

  void _recordBrainScore(int score, String dateKey) {
    final history = List<StatEntry>.from(_meta.brainScoreHistory)
      ..removeWhere((e) => e.dateKey == dateKey)
      ..add(StatEntry(dateKey: dateKey, brainScore: score));
    history.sort((a, b) => a.dateKey.compareTo(b.dateKey));

    final best = score > _meta.bestBrainScore ? score : _meta.bestBrainScore;
    _meta = _meta.copyWith(
      brainScoreHistory: history.length > 30
          ? history.sublist(history.length - 30)
          : history,
      bestBrainScore: best,
    );
  }

  Future<PuzzleCompleteResult> completePuzzle({
    required PuzzleType type,
    required int score,
    required double accuracy,
    required int timeTakenSeconds,
  }) async {
    final maxScore = PuzzleScores.maxScore(type);
    final hasStreak7 = _player.streak >= 7;

    final result = PuzzleResultModel(
      puzzleType: type,
      score: score.clamp(0, maxScore),
      accuracy: accuracy.clamp(0.0, 1.0),
      timeTakenSeconds: timeTakenSeconds,
      xpEarned: 0,
      isComplete: true,
    );

    // Update PlayerModel specific stats
    if (result.score == maxScore) {
      if (type == PuzzleType.memoryFlip) {
        _player = _player.copyWith(perfectMemoryFlipCount: _player.perfectMemoryFlipCount + 1);
      } else if (type == PuzzleType.patternIq) {
        _player = _player.copyWith(perfectPatternIQCount: _player.perfectPatternIQCount + 1);
      } else if (type == PuzzleType.wordSnap) {
        _player = _player.copyWith(perfectWordSnapCount: _player.perfectWordSnapCount + 1);
      } else if (type == PuzzleType.focusFind) {
        _player = _player.copyWith(perfectFocusCount: _player.perfectFocusCount + 1);
      }
    }

    var xpGain = XpService.calculatePuzzleXp(
      result: result,
      hasActiveStreak7: hasStreak7,
      maxScore: maxScore,
      playerLevel: _player.level,
    );

    final session = _todaySession ?? DailySessionModel(dateKey: todayDateKey());
    final updatedResults = List<PuzzleResultModel>.from(session.puzzleResults)
      ..removeWhere((r) => r.puzzleType == type)
      ..add(
        PuzzleResultModel(
          puzzleType: type,
          score: result.score,
          accuracy: result.accuracy,
          timeTakenSeconds: result.timeTakenSeconds,
          xpEarned: xpGain,
          isComplete: true,
        ),
      );

    updatedResults.sort(
      (a, b) => PuzzleType.dailyOrder
          .indexOf(a.puzzleType)
          .compareTo(PuzzleType.dailyOrder.indexOf(b.puzzleType)),
    );

    var updatedSession = session.copyWith(puzzleResults: updatedResults);

    var coinsEarned = 0;
    var sessionComplete = false;
    var brainScore = 0;

    final allDone = PuzzleType.dailyOrder.every(
      (t) => updatedResults.any((r) => r.puzzleType == t && r.isComplete),
    );

    if (allDone && !session.isComplete) {
      sessionComplete = true;
      xpGain += XpService.sessionCompleteBonus();

      brainScore = BrainScoreService.calculateBrainScore(
        session: updatedSession,
        player: _player,
      );
      final iqRank =
          BrainScoreService.iqRankForScore(brainScore).displayName;

      coinsEarned = BrainScoreService.coinsForDailySession(
        session: updatedSession,
        wasStreakExtended: false,
      );

      final today = todayDateKey();
      var streak = _player.streak;
      var longest = _player.longestStreak;
      var longestEver = _player.longestStreakEver;
      var oldStreak = streak;
      if (_player.lastPlayDateKey != today) {
        final yesterday = yesterdayDateKey();
        streak = _player.lastPlayDateKey == yesterday ? streak + 1 : 1;
        if (streak > longest) longest = streak;
        if (streak > longestEver) longestEver = streak;
      }

      var owned = List<String>.from(_player.ownedItems);
      var newCoins = _player.coins + coinsEarned;
      String newAvatar = _player.equippedAvatar;
      String newFrame = _player.equippedFrame;

      if (streak > oldStreak) {
        if (streak == 3) {
          newCoins += 50; // Bonus coins
        } else if (streak == 7) {
          // Grant exclusive avatar
          if (!owned.contains('avatar_7_day')) {
            owned.add('avatar_7_day');
            newAvatar = 'avatar_7_day';
          }
        } else if (streak == 30) {
          if (!owned.contains('frame_streak_30')) {
            owned.add('frame_streak_30');
            newFrame = 'frame_streak_30';
          }
        } else if (streak == 90) {
          if (!owned.contains('theme_streak_90')) {
            owned.add('theme_streak_90');
          }
        }
      }

      _player = _player.copyWith(
        coins: newCoins,
        streak: streak,
        longestStreak: longest,
        longestStreakEver: longestEver,
        lastPlayDateKey: today,
        ownedItems: owned,
        equippedAvatar: newAvatar,
        equippedFrame: newFrame,
      );

      updatedSession = updatedSession.copyWith(
        brainScore: brainScore,
        iqRank: iqRank,
        coinsEarned: coinsEarned,
        xpEarned: xpGain,
        isComplete: true,
      );

      _recordBrainScore(brainScore, today);

      // Fire notifications only once the daily session is marked complete.
      unawaited(NotificationService.instance.showDailyCompleted(
        brainScore: brainScore,
        coinsEarned: coinsEarned,
        xpEarned: xpGain,
        streak: streak,
      ));
      unawaited(NotificationService.instance.syncDailyReminder(
        isTodayComplete: true,
      ));

      final streakMilestone =
          streak > oldStreak ? [3, 7, 14, 30].contains(streak) : false;
      if (streakMilestone) {
        final rewardText = switch (streak) {
          3 => '3-day streak bonus!',
          7 => '7-day streak reward!',
          14 => '14-day streak mastery!',
          30 => '30-day streak achievement!',
          _ => 'Streak milestone reached!',
        };
        unawaited(NotificationService.instance.showStreakMilestone(
          milestoneDays: streak,
          rewardText: rewardText,
        ));
      }

      if (brainScore >= 850) {
        _meta = _meta.copyWith(hasReachedEinsteinRank: true);
        _player = _player.copyWith(hasReachedEinsteinRank: true);
      }
    }

    _meta = _challengeService.onPuzzleComplete(
      meta: _meta,
      player: _player,
      session: updatedSession,
      type: type,
      result: result,
    );

    _player = XpService.applyXp(_player, xpGain);
    _todaySession = updatedSession;
    await saveTodaySession(updatedSession);
    await _persistPlayer();
    await _persistMeta();

    return PuzzleCompleteResult(
      xpEarned: xpGain,
      coinsEarned: coinsEarned,
      sessionNowComplete: sessionComplete,
      brainScore: brainScore,
    );
  }

  Future<PracticePuzzleResult> completePracticePuzzle({
    required PuzzleType type,
    required int score,
  }) async {
    final key = type.name;
    final bests = Map<String, int>.from(_meta.modeProgress.practiceBests);
    final previous = bests[key] ?? 0;
    final clamped = score.clamp(0, PuzzleScores.maxScore(type));
    final isNewBest = clamped > previous;
    if (isNewBest) bests[key] = clamped;

    _meta = _meta.copyWith(
      modeProgress: _meta.modeProgress.copyWith(
        practiceBests: bests,
        totalPracticeSessions: _meta.modeProgress.totalPracticeSessions + 1,
      ),
    );
    
    final coins = 2 + Random().nextInt(4); // 2–5 coins per puzzle

    // Low XP — enough to reward repetition but keeps Daily Mode primary
    final maxScore = PuzzleScores.maxScore(type);
    final scoreRatio = maxScore > 0 ? clamped / maxScore : 0.0;
    
    var xpGain = 0;
    if (_player.level < 5) {
      xpGain = 150 + (scoreRatio * 100).round();
    } else {
      xpGain = 5 + (scoreRatio * 5).round();
    }

    if (_player.level >= 15 && scoreRatio < 1.0) {
      final wrongRatio = 1.0 - scoreRatio;
      int penalty = (wrongRatio * 150).round();
      xpGain -= penalty;
    }

    if (isNewBest) {
      xpGain += _player.level < 5 ? 50 : 5;
    }

    _player = _player.copyWith(coins: _player.coins + coins);
    _player = XpService.applyXp(_player, xpGain);

    _meta = _challengeService.evaluateLifetimeChallenges(_meta, _player);

    await _persistPlayer();
    await _persistMeta();

    return PracticePuzzleResult(
      score: clamped,
      isNewBest: isNewBest,
      previousBest: previous,
      xpEarned: xpGain,
    );
  }

  Future<BlitzSessionResult> completeBlitzSession(int score) async {
    final today = todayDateKey();
    final beatAllTime = score > _player.blitzAllTimeBest;
    final previousTodayBest = today == _player.blitzLastPlayedDate
        ? _player.blitzTodayBest
        : 0;
    final beatToday = !beatAllTime && score > previousTodayBest;

    var todayBest = _player.blitzTodayBest;
    if (today != _player.blitzLastPlayedDate) {
      todayBest = score;
    } else if (score > todayBest) {
      todayBest = score;
    }

    final allTimeBest =
        beatAllTime ? score : _player.blitzAllTimeBest;

    var coins = 15;
    var xp = 30;
    if (beatAllTime) {
      coins += 10;
      xp += 20;
    }

    _player = _player.copyWith(
      coins: _player.coins + coins,
      blitzAllTimeBest: allTimeBest,
      blitzTodayBest: todayBest,
      blitzLastScore: score,
      blitzTotalRuns: _player.blitzTotalRuns + 1,
      blitzLastPlayedDate: today,
    );
    _player = XpService.applyXp(_player, xp);

    if (score >= 140) {
      _player = _player.copyWith(
        mathBlitz140PlusCount: _player.mathBlitz140PlusCount + 1,
      );
    }

    final progress = _meta.modeProgress.copyWith(
      blitzHighScore: allTimeBest,
      totalBlitzSessions: _meta.modeProgress.totalBlitzSessions + 1,
    );
    _meta = _meta.copyWith(modeProgress: progress);
    _meta = _challengeService.evaluateLifetimeChallenges(_meta, _player);

    await _persistPlayer();
    await _persistMeta();

    final message = beatAllTime
        ? 'New Personal Best! Amazing!'
        : beatToday
            ? 'Best run today! Keep going!'
            : 'So close! Beat your best!';

    return BlitzSessionResult(
      score: score,
      beatAllTimeBest: beatAllTime,
      beatTodayBest: beatToday && !beatAllTime,
      coinsEarned: coins,
      xpEarned: xp,
      motivationalMessage: message,
    );
  }

  Future<ArenaMatchResult> completeArenaMatch({
    required int playerScore,
    int perfectRoundCount = 0,
  }) async {
    final baseAp = (playerScore / 25).round();
    final perfectBonus = perfectRoundCount * 10;
    final totalAp = baseAp + perfectBonus;

    final newBalance = (_player.arenaPoints + totalAp).clamp(0, 999999);
    final matchesLeft = (_player.arenaMatchesRemaining - 1).clamp(0, 3);

    _player = _player.copyWith(
      arenaPoints: newBalance,
      arenaWeeklyAP: _player.arenaWeeklyAP + totalAp,
      arenaAllTimeAP: _player.arenaAllTimeAP + totalAp,
      arenaWins: _player.arenaWins + 1,
      arenaMatchesRemaining: matchesLeft,
    );

    final coins = 25 + (playerScore / 50).round();
    var xp = 100 + (playerScore / 4).round();

    _player = _player.copyWith(coins: _player.coins + coins);
    _player = XpService.applyXp(_player, xp);

    final progress = _meta.modeProgress.copyWith(
      arenaPoints: newBalance,
      arenaWins: _player.arenaWins,
      arenaLosses: _player.arenaLosses,
      availableArenaMatches: matchesLeft,
    );
    _meta = _meta.copyWith(
      modeProgress: progress,
      clearActiveArenaMatch: true,
    );
    _meta = _challengeService.evaluateLifetimeChallenges(_meta, _player);

    await _persistPlayer();
    await _persistMeta();

    // Queue Firebase sync when online (placeholder service).
    unawaited(
      ArenaLeaderboardService.instance.syncPlayerStats(_player),
    );

    return ArenaMatchResult(
      playerScore: playerScore,
      arenaPointsDelta: totalAp,
      coinsEarned: coins,
      xpEarned: xp,
      perfectRoundBonus: perfectBonus,
      baseAp: baseAp,
    );
  }

}
