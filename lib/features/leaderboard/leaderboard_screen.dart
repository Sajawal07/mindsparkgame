import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/game_unlock.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/arena_leaderboard_entry.dart';
import '../../data/providers/game_providers.dart';
import '../../data/providers/leaderboard_provider.dart';
import '../../data/providers/network_provider.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/network/no_internet_view.dart';

/// Global Arena leaderboard – shows rankings or a level-gate message.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(leaderboardTabProvider.notifier).state =
            _tabController.index == 0 ? LeaderboardTab.weekly : LeaderboardTab.allTime;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(gameStateProvider.select((g) => g.save.player));
    final isOnline = ref.watch(isOnlineProvider);
    final isUnlocked = player.level >= GameUnlock.arenaLevel;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Arena Leaderboard'),
        bottom: (isOnline && isUnlocked)
            ? TabBar(
                controller: _tabController,
                indicatorColor: AppColors.gold,
                labelColor: AppColors.gold,
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(text: 'Weekly Kings'),
                  Tab(text: 'All Time Legends'),
                ],
              )
            : null,
      ),
      body: !isOnline
          ? const NoInternetView(
              featureName: 'Leaderboard',
              customMessage: 'The Leaderboard requires an active internet connection to fetch real-time rankings.',
            )
          : (isUnlocked
              ? TabBarView(
                  controller: _tabController,
                  children: const [
                    _LeaderboardTab(weekly: true),
                    _LeaderboardTab(weekly: false),
                  ],
                )
              : _LockedView(playerLevel: player.level)),
    );
  }
}

// ── Locked state ─────────────────────────────────────────────────────────────

class _LockedView extends StatelessWidget {
  const _LockedView({required this.playerLevel});
  final int playerLevel;

  @override
  Widget build(BuildContext context) {
    final levelsNeeded = GameUnlock.arenaLevel - playerLevel;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                ),
                Image.asset(
                  AppAssets.arenaPointsBadge,
                  width: 60,
                  height: 60,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.leaderboard_outlined,
                    size: 60,
                    color: AppColors.gold,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.lock, color: Colors.white54, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Leaderboard Locked',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Reach Level ${GameUnlock.arenaLevel} to unlock Arena Mode\nand access the Global Leaderboard.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: AppColors.gold.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
              ),
              child: Text(
                '$levelsNeeded more level${levelsNeeded == 1 ? '' : 's'} to go!',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Weekly Kings · All Time Legends\nGlobal rankings updated in real-time.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Leaderboard tab ───────────────────────────────────────────────────────────

class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab({required this.weekly});
  final bool weekly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = weekly
        ? ref.watch(weeklyLeaderboardProvider)
        : ref.watch(allTimeLeaderboardProvider);

    return dataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Could not load rankings.\n$e',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70)),
      ),
      data: (data) => _LeaderboardList(data: data, weekly: weekly),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({required this.data, required this.weekly});
  final ArenaLeaderboardData data;
  final bool weekly;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries;
    final player = data.playerEntry;

    if (data.isOffline) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white38, size: 48),
              const SizedBox(height: 16),
              Text(
                'You\'re offline',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Connect to the internet to see global rankings.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              if (player != null) ...[
                const SizedBox(height: 24),
                _PlayerPositionCard(entry: player, weekly: weekly),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (player != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _PlayerPositionCard(entry: player, weekly: weekly),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, i) => _LeaderboardTile(entry: entries[i]),
          ),
        ),
      ],
    );
  }
}

/// Player's own position card (pinned at top)
class _PlayerPositionCard extends StatelessWidget {
  const _PlayerPositionCard({required this.entry, required this.weekly});
  final ArenaLeaderboardEntry entry;
  final bool weekly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.2),
            ),
            alignment: Alignment.center,
            child: Text(
              entry.rank > 0 ? '#${entry.rank}' : '—',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.person, color: AppColors.gold, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.ap} AP',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              Text(
                'Matches: ${entry.wins}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single leaderboard entry tile
class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry});
  final ArenaLeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;
    final rankColor = entry.rank == 1
        ? AppColors.gold
        : entry.rank == 2
            ? const Color(0xFFC0C0C0)
            : entry.rank == 3
                ? const Color(0xFFCD7F32)
                : Colors.white54;
    final rankIcon = entry.rank == 1
        ? '🥇'
        : entry.rank == 2
            ? '🥈'
            : entry.rank == 3
                ? '🥉'
                : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: entry.isCurrentPlayer
            ? AppColors.gold.withValues(alpha: 0.12)
            : isTop3
                ? rankColor.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: entry.isCurrentPlayer
              ? AppColors.gold.withValues(alpha: 0.4)
              : isTop3
                  ? rankColor.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.08),
          width: entry.isCurrentPlayer ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: rankIcon != null
                ? Text(rankIcon, style: const TextStyle(fontSize: 20))
                : Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      color: rankColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.username,
              style: TextStyle(
                color: entry.isCurrentPlayer ? AppColors.gold : Colors.white,
                fontWeight: entry.isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.ap} AP',
                style: TextStyle(
                  color: isTop3 ? rankColor : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                'Matches: ${entry.wins}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
