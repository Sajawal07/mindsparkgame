import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/arena_leaderboard_entry.dart';
import '../models/player_model.dart';

/// Firebase-backed Arena leaderboard service.
/// Syncs player stats to Firestore and reads global rankings.
class ArenaLeaderboardService {
  ArenaLeaderboardService._();
  static final instance = ArenaLeaderboardService._();

  static const _collection = 'arena_leaderboard';

  // ── Sync player stats to Firestore ──────────────────────────────────────────

  Future<void> syncPlayerStats(PlayerModel player) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance.collection(_collection).doc(uid).set({
        'username': player.name,
        'ap': player.arenaAllTimeAP,
        'weeklyAp': player.arenaWeeklyAP,
        'wins': player.arenaWins,
        'losses': player.arenaLosses,
        'avatarId': player.equippedAvatar,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Silently fail – offline or permission error.
    }
  }

  // ── Fetch weekly leaderboard ─────────────────────────────────────────────────

  Future<ArenaLeaderboardData> fetchWeekly({required PlayerModel player}) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_collection)
          .orderBy('weeklyAp', descending: true)
          .limit(50)
          .get();

      return _buildData(snap, player, weekly: true);
    } catch (_) {
      return _offlineData(player, weekly: true);
    }
  }

  // ── Fetch all-time leaderboard ───────────────────────────────────────────────

  Future<ArenaLeaderboardData> fetchAllTime({required PlayerModel player}) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_collection)
          .orderBy('ap', descending: true)
          .limit(50)
          .get();

      return _buildData(snap, player, weekly: false);
    } catch (_) {
      return _offlineData(player, weekly: false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  ArenaLeaderboardData _buildData(
    QuerySnapshot<Map<String, dynamic>> snap,
    PlayerModel player, {
    required bool weekly,
  }) {
    final docs = snap.docs;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final entries = <ArenaLeaderboardEntry>[];

    for (var i = 0; i < docs.length; i++) {
      final d = docs[i].data();
      final docId = docs[i].id;
      entries.add(ArenaLeaderboardEntry(
        rank: i + 1,
        username: d['username'] as String? ?? 'Unknown',
        ap: (weekly ? d['weeklyAp'] : d['ap']) as int? ?? 0,
        wins: d['wins'] as int? ?? 0,
        losses: d['losses'] as int? ?? 0,
        avatarId: d['avatarId'] as String? ?? '',
        isCurrentPlayer: docId == currentUid,
      ));
    }

    // Find player rank by UID-matched entry
    final playerIndex = entries.indexWhere((e) => e.isCurrentPlayer);
    final playerRank = playerIndex >= 0 ? playerIndex + 1 : entries.length + 1;
    final baseAp = weekly ? player.arenaWeeklyAP : player.arenaAllTimeAP;

    final playerEntry = ArenaLeaderboardEntry(
      rank: playerRank,
      username: player.name.isEmpty ? 'You' : player.name,
      ap: baseAp,
      wins: player.arenaWins,
      losses: player.arenaLosses,
      avatarId: player.equippedAvatar,
      isCurrentPlayer: true,
    );

    return ArenaLeaderboardData(
      entries: entries,
      playerEntry: playerEntry,
      isOffline: false,
      lastUpdated: DateTime.now(),
    );
  }

  ArenaLeaderboardData _offlineData(PlayerModel player, {required bool weekly}) {
    final ap = weekly ? player.arenaWeeklyAP : player.arenaAllTimeAP;
    return ArenaLeaderboardData(
      entries: const [],
      playerEntry: ArenaLeaderboardEntry(
        rank: 0,
        username: player.name,
        ap: ap,
        wins: player.arenaWins,
        losses: player.arenaLosses,
        avatarId: player.equippedAvatar,
        isCurrentPlayer: true,
      ),
      isOffline: true,
    );
  }
}
