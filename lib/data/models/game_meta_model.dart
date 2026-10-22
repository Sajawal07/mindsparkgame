import '../models/arena_match_snapshot.dart';
import 'challenge_model.dart';
import 'mode_progress_model.dart';

class StatEntry {
  const StatEntry({required this.dateKey, required this.brainScore});

  final String dateKey;
  final int brainScore;

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'brainScore': brainScore,
      };

  factory StatEntry.fromJson(Map<String, dynamic> json) {
    return StatEntry(
      dateKey: json['dateKey'] as String,
      brainScore: json['brainScore'] as int? ?? 0,
    );
  }
}

class GameMetaModel {
  const GameMetaModel({
    this.challenges = const [],
    this.brainScoreHistory = const [],
    this.lifetimeCounters = const {},
    this.lastShareRewardDateKey = '',
    this.dailyChallengeResetKey = '',
    this.weeklyChallengeResetKey = '',
    this.hasReachedEinsteinRank = false,
    this.bestBrainScore = 0,
    this.modeProgress = const ModeProgressModel(),
    this.activeArenaMatch,
    this.arenaUnlockDialogShown = false,
  });

  final List<ChallengeModel> challenges;
  final List<StatEntry> brainScoreHistory;
  final Map<String, int> lifetimeCounters;
  final String lastShareRewardDateKey;
  final String dailyChallengeResetKey;
  final String weeklyChallengeResetKey;
  final bool hasReachedEinsteinRank;
  final int bestBrainScore;
  final ModeProgressModel modeProgress;
  final ArenaMatchSnapshot? activeArenaMatch;
  final bool arenaUnlockDialogShown;

  Map<String, dynamic> toJson() => {
        'challenges': challenges.map((c) => c.toJson()).toList(),
        'brainScoreHistory': brainScoreHistory.map((e) => e.toJson()).toList(),
        'lifetimeCounters': lifetimeCounters,
        'lastShareRewardDateKey': lastShareRewardDateKey,
        'dailyChallengeResetKey': dailyChallengeResetKey,
        'weeklyChallengeResetKey': weeklyChallengeResetKey,
        'hasReachedEinsteinRank': hasReachedEinsteinRank,
        'bestBrainScore': bestBrainScore,
        'modeProgress': modeProgress.toJson(),
        'activeArenaMatch': activeArenaMatch?.toJson(),
        'arenaUnlockDialogShown': arenaUnlockDialogShown,
      };

  factory GameMetaModel.fromJson(Map<String, dynamic> json) {
    return GameMetaModel(
      challenges: (json['challenges'] as List<dynamic>?)
              ?.map((e) => ChallengeModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      brainScoreHistory: (json['brainScoreHistory'] as List<dynamic>?)
              ?.map((e) => StatEntry.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      lifetimeCounters: (json['lifetimeCounters'] as Map<dynamic, dynamic>?)
              ?.map((k, v) => MapEntry(k as String, v as int)) ??
          {},
      lastShareRewardDateKey:
          json['lastShareRewardDateKey'] as String? ?? '',
      dailyChallengeResetKey: json['dailyChallengeResetKey'] as String? ?? '',
      weeklyChallengeResetKey: json['weeklyChallengeResetKey'] as String? ?? '',
      hasReachedEinsteinRank:
          json['hasReachedEinsteinRank'] as bool? ?? false,
      bestBrainScore: json['bestBrainScore'] as int? ?? 0,
      modeProgress: json['modeProgress'] != null
          ? ModeProgressModel.fromJson(
              Map<String, dynamic>.from(json['modeProgress'] as Map),
            )
          : const ModeProgressModel(),
      activeArenaMatch: json['activeArenaMatch'] != null
          ? ArenaMatchSnapshot.fromJson(
              Map<String, dynamic>.from(json['activeArenaMatch'] as Map),
            )
          : null,
      arenaUnlockDialogShown: json['arenaUnlockDialogShown'] as bool? ?? false,
    );
  }

  GameMetaModel copyWith({
    List<ChallengeModel>? challenges,
    List<StatEntry>? brainScoreHistory,
    Map<String, int>? lifetimeCounters,
    String? lastShareRewardDateKey,
    String? dailyChallengeResetKey,
    String? weeklyChallengeResetKey,
    bool? hasReachedEinsteinRank,
    int? bestBrainScore,
    ModeProgressModel? modeProgress,
    ArenaMatchSnapshot? activeArenaMatch,
    bool clearActiveArenaMatch = false,
    bool? arenaUnlockDialogShown,
  }) {
    return GameMetaModel(
      challenges: challenges ?? this.challenges,
      brainScoreHistory: brainScoreHistory ?? this.brainScoreHistory,
      lifetimeCounters: lifetimeCounters ?? this.lifetimeCounters,
      lastShareRewardDateKey:
          lastShareRewardDateKey ?? this.lastShareRewardDateKey,
      dailyChallengeResetKey:
          dailyChallengeResetKey ?? this.dailyChallengeResetKey,
      weeklyChallengeResetKey:
          weeklyChallengeResetKey ?? this.weeklyChallengeResetKey,
      hasReachedEinsteinRank:
          hasReachedEinsteinRank ?? this.hasReachedEinsteinRank,
      bestBrainScore: bestBrainScore ?? this.bestBrainScore,
      modeProgress: modeProgress ?? this.modeProgress,
      activeArenaMatch: clearActiveArenaMatch
          ? null
          : activeArenaMatch ?? this.activeArenaMatch,
      arenaUnlockDialogShown: arenaUnlockDialogShown ?? this.arenaUnlockDialogShown,
    );
  }

  int counter(String key) => lifetimeCounters[key] ?? 0;
}
