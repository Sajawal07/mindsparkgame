class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.score,
    required this.dateKey,
  });

  final String name;
  final int score;
  final String dateKey;

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
        'dateKey': dateKey,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'] as String? ?? 'Player',
      score: json['score'] as int? ?? 0,
      dateKey: json['dateKey'] as String? ?? '',
    );
  }
}

class ModeProgressModel {
  const ModeProgressModel({
    this.practiceBests = const {},
    this.blitzHighScore = 0,
    this.arenaPoints = 100,
    this.arenaWins = 0,
    this.arenaLosses = 0,
    this.leaderboard = const [],
    this.totalPracticeSessions = 0,
    this.totalBlitzSessions = 0,
    this.availableArenaMatches = 3,
    this.lastArenaMatchGenTime = '',
  });

  final Map<String, int> practiceBests;
  final int blitzHighScore;
  final int arenaPoints;
  final int arenaWins;
  final int arenaLosses;
  final List<LeaderboardEntry> leaderboard;
  final int totalPracticeSessions;
  final int totalBlitzSessions;
  final int availableArenaMatches;
  final String lastArenaMatchGenTime;

  Map<String, dynamic> toJson() => {
        'practiceBests': practiceBests,
        'blitzHighScore': blitzHighScore,
        'arenaPoints': arenaPoints,
        'arenaWins': arenaWins,
        'arenaLosses': arenaLosses,
        'leaderboard': leaderboard.map((e) => e.toJson()).toList(),
        'totalPracticeSessions': totalPracticeSessions,
        'totalBlitzSessions': totalBlitzSessions,
        'availableArenaMatches': availableArenaMatches,
        'lastArenaMatchGenTime': lastArenaMatchGenTime,
      };

  factory ModeProgressModel.fromJson(Map<String, dynamic> json) {
    return ModeProgressModel(
      practiceBests: (json['practiceBests'] as Map<dynamic, dynamic>?)
              ?.map((k, v) => MapEntry(k as String, v as int)) ??
          {},
      blitzHighScore: json['blitzHighScore'] as int? ?? 0,
      arenaPoints: json['arenaPoints'] as int? ?? 100,
      arenaWins: json['arenaWins'] as int? ?? 0,
      arenaLosses: json['arenaLosses'] as int? ?? 0,
      leaderboard: (json['leaderboard'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPracticeSessions: json['totalPracticeSessions'] as int? ?? 0,
      totalBlitzSessions: json['totalBlitzSessions'] as int? ?? 0,
      availableArenaMatches: json['availableArenaMatches'] as int? ?? 3,
      lastArenaMatchGenTime: json['lastArenaMatchGenTime'] as String? ?? '',
    );
  }

  ModeProgressModel copyWith({
    Map<String, int>? practiceBests,
    int? blitzHighScore,
    int? arenaPoints,
    int? arenaWins,
    int? arenaLosses,
    List<LeaderboardEntry>? leaderboard,
    int? totalPracticeSessions,
    int? totalBlitzSessions,
    int? availableArenaMatches,
    String? lastArenaMatchGenTime,
  }) {
    return ModeProgressModel(
      practiceBests: practiceBests ?? this.practiceBests,
      blitzHighScore: blitzHighScore ?? this.blitzHighScore,
      arenaPoints: arenaPoints ?? this.arenaPoints,
      arenaWins: arenaWins ?? this.arenaWins,
      arenaLosses: arenaLosses ?? this.arenaLosses,
      leaderboard: leaderboard ?? this.leaderboard,
      totalPracticeSessions:
          totalPracticeSessions ?? this.totalPracticeSessions,
      totalBlitzSessions: totalBlitzSessions ?? this.totalBlitzSessions,
      availableArenaMatches:
          availableArenaMatches ?? this.availableArenaMatches,
      lastArenaMatchGenTime:
          lastArenaMatchGenTime ?? this.lastArenaMatchGenTime,
    );
  }
}
