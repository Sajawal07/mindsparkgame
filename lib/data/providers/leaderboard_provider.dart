import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/arena_leaderboard_entry.dart';
import '../services/arena_leaderboard_service.dart';
import 'game_providers.dart';

enum LeaderboardTab { weekly, allTime }

final leaderboardTabProvider =
    StateProvider<LeaderboardTab>((ref) => LeaderboardTab.weekly);

final weeklyLeaderboardProvider =
    FutureProvider.autoDispose<ArenaLeaderboardData>((ref) async {
  final player = ref.watch(gameStateProvider).save.player;
  return ArenaLeaderboardService.instance.fetchWeekly(player: player);
});

final allTimeLeaderboardProvider =
    FutureProvider.autoDispose<ArenaLeaderboardData>((ref) async {
  final player = ref.watch(gameStateProvider).save.player;
  return ArenaLeaderboardService.instance.fetchAllTime(player: player);
});
