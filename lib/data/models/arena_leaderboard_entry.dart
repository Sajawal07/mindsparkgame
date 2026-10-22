class ArenaLeaderboardEntry {
  const ArenaLeaderboardEntry({
    required this.rank,
    required this.username,
    required this.ap,
    required this.wins,
    required this.losses,
    this.avatarId = '',
    this.isCurrentPlayer = false,
  });

  final int rank;
  final String username;
  final int ap;
  final int wins;
  final int losses;
  final String avatarId;
  final bool isCurrentPlayer;

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'username': username,
        'ap': ap,
        'wins': wins,
        'losses': losses,
        'avatarId': avatarId,
      };

  factory ArenaLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return ArenaLeaderboardEntry(
      rank: json['rank'] as int? ?? 0,
      username: json['username'] as String? ?? 'Player',
      ap: json['ap'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      avatarId: json['avatarId'] as String? ?? '',
    );
  }
}

class ArenaLeaderboardData {
  const ArenaLeaderboardData({
    required this.entries,
    this.playerEntry,
    required this.isOffline,
    this.lastUpdated,
  });

  final List<ArenaLeaderboardEntry> entries;
  final ArenaLeaderboardEntry? playerEntry;
  final bool isOffline;
  final DateTime? lastUpdated;
}
