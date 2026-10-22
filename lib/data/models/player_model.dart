import 'package:equatable/equatable.dart';

class PlayerModel extends Equatable {
  const PlayerModel({
    this.level = 1,
    this.xp = 0,
    this.coins = 0,
    this.arenaPoints = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.longestStreakEver = 0,
    this.name = 'Player',
    this.equippedTheme = 'default',
    this.equippedFrame = '',
    this.equippedTitle = '',
    this.equippedAvatar = '',
    this.equippedVictoryFlair = '',
    this.ownedItems = const [],
    this.powerupInventory = const {},
    this.onboardingComplete = false,
    this.lastPlayDateKey = '',
    this.hasReachedEinsteinRank = false,
    this.mathBlitz140PlusCount = 0,
    this.perfectMemoryFlipCount = 0,
    this.perfectPatternIQCount = 0,
    this.perfectWordSnapCount = 0,
    this.perfectFocusCount = 0,
    this.whoAmITotalGames = 0,
    this.whoAmIGamesWon = 0,
    this.whoAmITotalScore = 0,
    this.whoAmIBestScore = 0,
    this.clueTokens = 3,
    this.hasGeniusPass = false,
    this.dailyChallengesCompletedTotal = 0,
    this.arenaWins = 0,
    this.activePowerups = const {},
    // Blitz personal bests
    this.blitzAllTimeBest = 0,
    this.blitzTodayBest = 0,
    this.blitzLastScore = 0,
    this.blitzTotalRuns = 0,
    this.blitzLastPlayedDate = '',
    // Arena stats
    this.arenaWeeklyAP = 0,
    this.arenaAllTimeAP = 0,
    this.arenaLosses = 0,
    this.arenaMatchesRemaining = 3,
    this.arenaCycleRefreshTime = '',
    this.arenaWeeklyChampionBadge = false,
    this.weeklyChampionCount = 0,
    this.arenaWeeklyResetWeekKey = '',
  });

  final int level;
  final int xp;
  final int coins;
  final int arenaPoints;
  final int streak;
  final int longestStreak;
  final int longestStreakEver;
  final String name;
  final String equippedTheme;
  final String equippedFrame;
  final String equippedTitle;
  final String equippedAvatar;
  final String equippedVictoryFlair;
  final List<String> ownedItems;
  final Map<String, int> powerupInventory;
  final bool onboardingComplete;
  final String lastPlayDateKey;
  final bool hasReachedEinsteinRank;
  final int mathBlitz140PlusCount;
  final int perfectMemoryFlipCount;
  final int perfectPatternIQCount;
  final int perfectWordSnapCount;
  final int perfectFocusCount;
  final int whoAmITotalGames;
  final int whoAmIGamesWon;
  final int whoAmITotalScore;
  final int whoAmIBestScore;
  final int clueTokens;
  final bool hasGeniusPass;
  final int dailyChallengesCompletedTotal;
  final int arenaWins;
  final Map<String, DateTime> activePowerups;

  // Blitz
  final int blitzAllTimeBest;
  final int blitzTodayBest;
  final int blitzLastScore;
  final int blitzTotalRuns;
  final String blitzLastPlayedDate;

  // Arena
  final int arenaWeeklyAP;
  final int arenaAllTimeAP;
  final int arenaLosses;
  final int arenaMatchesRemaining;
  final String arenaCycleRefreshTime;
  final bool arenaWeeklyChampionBadge;
  final int weeklyChampionCount;
  final String arenaWeeklyResetWeekKey;

  static const int maxLevel = 30;

  /// XP thresholds from PRD (cumulative).
  static int xpRequiredForLevel(int level) {
    if (level == 1) return 200;
    if (level == 2) return 300;
    if (level == 3) return 500;
    if (level == 4) return 800;
    if (level == 5) return 1200;
    if (level <= 10) return 6000;
    if (level <= 15) return 14000;
    if (level <= 20) return 28000;
    if (level <= 25) return 50000;
    return 80000;
  }

  int get xpForNextLevel => xpRequiredForLevel(level);

  double get levelProgress {
    final required = xpForNextLevel;
    if (required <= 0) return 1;
    return (xp / required).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'xp': xp,
        'coins': coins,
        'arenaPoints': arenaPoints,
        'streak': streak,
        'longestStreak': longestStreak,
        'longestStreakEver': longestStreakEver,
        'name': name,
        'equippedTheme': equippedTheme,
        'equippedFrame': equippedFrame,
        'equippedTitle': equippedTitle,
        'equippedAvatar': equippedAvatar,
        'equippedVictoryFlair': equippedVictoryFlair,
        'ownedItems': ownedItems,
        'powerupInventory': powerupInventory,
        'onboardingComplete': onboardingComplete,
        'lastPlayDateKey': lastPlayDateKey,
        'hasReachedEinsteinRank': hasReachedEinsteinRank,
        'mathBlitz140PlusCount': mathBlitz140PlusCount,
        'perfectMemoryFlipCount': perfectMemoryFlipCount,
        'perfectPatternIQCount': perfectPatternIQCount,
        'perfectWordSnapCount': perfectWordSnapCount,
        'perfectFocusCount': perfectFocusCount,
        'whoAmITotalGames': whoAmITotalGames,
        'whoAmIGamesWon': whoAmIGamesWon,
        'whoAmITotalScore': whoAmITotalScore,
        'whoAmIBestScore': whoAmIBestScore,
        'clueTokens': clueTokens,
        'hasGeniusPass': hasGeniusPass,
        'dailyChallengesCompletedTotal': dailyChallengesCompletedTotal,
        'arenaWins': arenaWins,
        'activePowerups': activePowerups.map((k, v) => MapEntry(k, v.toIso8601String())),
        'blitzAllTimeBest': blitzAllTimeBest,
        'blitzTodayBest': blitzTodayBest,
        'blitzLastScore': blitzLastScore,
        'blitzTotalRuns': blitzTotalRuns,
        'blitzLastPlayedDate': blitzLastPlayedDate,
        'arenaWeeklyAP': arenaWeeklyAP,
        'arenaAllTimeAP': arenaAllTimeAP,
        'arenaLosses': arenaLosses,
        'arenaMatchesRemaining': arenaMatchesRemaining,
        'arenaCycleRefreshTime': arenaCycleRefreshTime,
        'arenaWeeklyChampionBadge': arenaWeeklyChampionBadge,
        'weeklyChampionCount': weeklyChampionCount,
        'arenaWeeklyResetWeekKey': arenaWeeklyResetWeekKey,
      };

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    final stock = json['powerUpStock'] ?? json['powerupInventory'];

    return PlayerModel(
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      arenaPoints: json['arenaPoints'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      longestStreakEver: json['longestStreakEver'] as int? ??
          (json['longestStreak'] as int? ?? 0),
      name: json['name'] as String? ?? 'Player',
      equippedTheme: json['equippedTheme'] as String? ?? 'default',
      equippedFrame: json['equippedFrame'] as String? ?? '',
      equippedTitle: json['equippedTitle'] as String? ?? '',
      equippedAvatar: json['equippedAvatar'] as String? ?? '',
      equippedVictoryFlair: json['equippedVictoryFlair'] as String? ?? '',
      ownedItems: (json['ownedItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      powerupInventory: (stock as Map<dynamic, dynamic>?)
              ?.map((k, v) => MapEntry(k as String, v as int)) ??
          {},
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      lastPlayDateKey: json['lastPlayDateKey'] as String? ?? '',
      hasReachedEinsteinRank: json['hasReachedEinsteinRank'] as bool? ?? false,
      mathBlitz140PlusCount: json['mathBlitz140PlusCount'] as int? ?? 0,
      perfectMemoryFlipCount: json['perfectMemoryFlipCount'] as int? ?? 0,
      perfectPatternIQCount: json['perfectPatternIQCount'] as int? ?? 0,
      perfectWordSnapCount: json['perfectWordSnapCount'] as int? ?? 0,
      perfectFocusCount: json['perfectFocusCount'] as int? ?? 0,
      whoAmITotalGames: json['whoAmITotalGames'] as int? ?? 0,
      whoAmIGamesWon: json['whoAmIGamesWon'] as int? ?? 0,
      whoAmITotalScore: json['whoAmITotalScore'] as int? ?? 0,
      whoAmIBestScore: json['whoAmIBestScore'] as int? ?? 0,
      clueTokens: json['clueTokens'] as int? ?? 3,
      hasGeniusPass: json['hasGeniusPass'] as bool? ?? false,
      dailyChallengesCompletedTotal:
          json['dailyChallengesCompletedTotal'] as int? ?? 0,
      arenaWins: json['arenaWins'] as int? ?? 0,
      activePowerups: (json['activePowerups'] as Map<dynamic, dynamic>?)
              ?.map((k, v) => MapEntry(k as String, DateTime.parse(v as String))) ??
          {},
      blitzAllTimeBest: json['blitzAllTimeBest'] as int? ?? 0,
      blitzTodayBest: json['blitzTodayBest'] as int? ?? 0,
      blitzLastScore: json['blitzLastScore'] as int? ?? 0,
      blitzTotalRuns: json['blitzTotalRuns'] as int? ?? 0,
      blitzLastPlayedDate: json['blitzLastPlayedDate'] as String? ?? '',
      arenaWeeklyAP: json['arenaWeeklyAP'] as int? ?? 0,
      arenaAllTimeAP: json['arenaAllTimeAP'] as int? ?? 0,
      arenaLosses: json['arenaLosses'] as int? ?? 0,
      arenaMatchesRemaining: json['arenaMatchesRemaining'] as int? ?? 3,
      arenaCycleRefreshTime: json['arenaCycleRefreshTime'] as String? ?? '',
      arenaWeeklyChampionBadge:
          json['arenaWeeklyChampionBadge'] as bool? ?? false,
      weeklyChampionCount: json['weeklyChampionCount'] as int? ?? 0,
      arenaWeeklyResetWeekKey: json['arenaWeeklyResetWeekKey'] as String? ?? '',
    );
  }

  PlayerModel copyWith({
    int? level,
    int? xp,
    int? coins,
    int? arenaPoints,
    int? streak,
    int? longestStreak,
    int? longestStreakEver,
    String? name,
    String? equippedTheme,
    String? equippedFrame,
    String? equippedTitle,
    String? equippedAvatar,
    String? equippedVictoryFlair,
    List<String>? ownedItems,
    Map<String, int>? powerupInventory,
    bool? onboardingComplete,
    String? lastPlayDateKey,
    bool? hasReachedEinsteinRank,
    int? mathBlitz140PlusCount,
    int? perfectMemoryFlipCount,
    int? perfectPatternIQCount,
    int? perfectWordSnapCount,
    int? perfectFocusCount,
    int? whoAmITotalGames,
    int? whoAmIGamesWon,
    int? whoAmITotalScore,
    int? whoAmIBestScore,
    int? clueTokens,
    bool? hasGeniusPass,
    int? dailyChallengesCompletedTotal,
    int? arenaWins,
    Map<String, DateTime>? activePowerups,
    int? blitzAllTimeBest,
    int? blitzTodayBest,
    int? blitzLastScore,
    int? blitzTotalRuns,
    String? blitzLastPlayedDate,
    int? arenaWeeklyAP,
    int? arenaAllTimeAP,
    int? arenaLosses,
    int? arenaMatchesRemaining,
    String? arenaCycleRefreshTime,
    bool? arenaWeeklyChampionBadge,
    int? weeklyChampionCount,
    String? arenaWeeklyResetWeekKey,
  }) {
    return PlayerModel(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      arenaPoints: arenaPoints ?? this.arenaPoints,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      longestStreakEver: longestStreakEver ?? this.longestStreakEver,
      name: name ?? this.name,
      equippedTheme: equippedTheme ?? this.equippedTheme,
      equippedFrame: equippedFrame ?? this.equippedFrame,
      equippedTitle: equippedTitle ?? this.equippedTitle,
      equippedAvatar: equippedAvatar ?? this.equippedAvatar,
      equippedVictoryFlair: equippedVictoryFlair ?? this.equippedVictoryFlair,
      ownedItems: ownedItems ?? this.ownedItems,
      powerupInventory: powerupInventory ?? this.powerupInventory,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      lastPlayDateKey: lastPlayDateKey ?? this.lastPlayDateKey,
      hasReachedEinsteinRank:
          hasReachedEinsteinRank ?? this.hasReachedEinsteinRank,
      mathBlitz140PlusCount:
          mathBlitz140PlusCount ?? this.mathBlitz140PlusCount,
      perfectMemoryFlipCount:
          perfectMemoryFlipCount ?? this.perfectMemoryFlipCount,
      perfectPatternIQCount:
          perfectPatternIQCount ?? this.perfectPatternIQCount,
      perfectWordSnapCount: perfectWordSnapCount ?? this.perfectWordSnapCount,
      perfectFocusCount: perfectFocusCount ?? this.perfectFocusCount,
      whoAmITotalGames: whoAmITotalGames ?? this.whoAmITotalGames,
      whoAmIGamesWon: whoAmIGamesWon ?? this.whoAmIGamesWon,
      whoAmITotalScore: whoAmITotalScore ?? this.whoAmITotalScore,
      whoAmIBestScore: whoAmIBestScore ?? this.whoAmIBestScore,
      clueTokens: clueTokens ?? this.clueTokens,
      hasGeniusPass: hasGeniusPass ?? this.hasGeniusPass,
      dailyChallengesCompletedTotal: dailyChallengesCompletedTotal ??
          this.dailyChallengesCompletedTotal,
      arenaWins: arenaWins ?? this.arenaWins,
      activePowerups: activePowerups ?? this.activePowerups,
      blitzAllTimeBest: blitzAllTimeBest ?? this.blitzAllTimeBest,
      blitzTodayBest: blitzTodayBest ?? this.blitzTodayBest,
      blitzLastScore: blitzLastScore ?? this.blitzLastScore,
      blitzTotalRuns: blitzTotalRuns ?? this.blitzTotalRuns,
      blitzLastPlayedDate: blitzLastPlayedDate ?? this.blitzLastPlayedDate,
      arenaWeeklyAP: arenaWeeklyAP ?? this.arenaWeeklyAP,
      arenaAllTimeAP: arenaAllTimeAP ?? this.arenaAllTimeAP,
      arenaLosses: arenaLosses ?? this.arenaLosses,
      arenaMatchesRemaining:
          arenaMatchesRemaining ?? this.arenaMatchesRemaining,
      arenaCycleRefreshTime:
          arenaCycleRefreshTime ?? this.arenaCycleRefreshTime,
      arenaWeeklyChampionBadge:
          arenaWeeklyChampionBadge ?? this.arenaWeeklyChampionBadge,
      weeklyChampionCount: weeklyChampionCount ?? this.weeklyChampionCount,
      arenaWeeklyResetWeekKey:
          arenaWeeklyResetWeekKey ?? this.arenaWeeklyResetWeekKey,
    );
  }

  @override
  List<Object?> get props => [
        level,
        xp,
        coins,
        arenaPoints,
        streak,
        longestStreak,
        longestStreakEver,
        name,
        equippedTheme,
        equippedFrame,
        equippedTitle,
        equippedAvatar,
        equippedVictoryFlair,
        ownedItems,
        powerupInventory,
        onboardingComplete,
        lastPlayDateKey,
        hasReachedEinsteinRank,
        mathBlitz140PlusCount,
        perfectMemoryFlipCount,
        perfectPatternIQCount,
        perfectWordSnapCount,
        perfectFocusCount,
        whoAmITotalGames,
        whoAmIGamesWon,
        whoAmITotalScore,
        whoAmIBestScore,
        clueTokens,
        hasGeniusPass,
        dailyChallengesCompletedTotal,
        arenaWins,
        activePowerups,
        blitzAllTimeBest,
        blitzTodayBest,
        blitzLastScore,
        blitzTotalRuns,
        blitzLastPlayedDate,
        arenaWeeklyAP,
        arenaAllTimeAP,
        arenaLosses,
        arenaMatchesRemaining,
        arenaCycleRefreshTime,
        arenaWeeklyChampionBadge,
        weeklyChampionCount,
        arenaWeeklyResetWeekKey,
      ];
}
