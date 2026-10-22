import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/game_unlock.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/player_model.dart';
import '../../data/models/store_item.dart';
import '../../data/providers/game_providers.dart';
import '../../data/services/audio_service.dart';
import '../../shared/widgets/brain_score_ring.dart';
import '../../shared/widgets/coin_badge.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/mindspark_loading_indicator.dart';
import '../../shared/widgets/player_avatar_view.dart';
import '../../shared/widgets/xp_bar.dart';

import 'widgets/currency_shop_entry.dart';
import 'widgets/level_up_dialog.dart';
import '../../core/constants/app_features.dart';
import '../../data/providers/network_provider.dart';
import '../../shared/widgets/network/turn_on_internet_dialog.dart';

/// Main hub — evolution of the original home screen with four game modes.
class ModeSelectScreen extends ConsumerStatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  ConsumerState<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends ConsumerState<ModeSelectScreen> {
  bool _levelUpScheduled = false;
  bool _showingLevelUpCheckIndicator = false;

  /// True only when Modes home is the top route (no result/practice/blitz overlay).
  bool get _isHomeRouteActive {
    if (!mounted) return false;
    final loc = GoRouter.of(context).state.matchedLocation;
    if (loc != AppRoutes.home) return false;
    final route = ModalRoute.of(context);
    return route == null ? true : route.isCurrent;
  }

  /// Called when user returns to home.
  /// Shows a short Mindspark indicator, then:
  /// - if level-up is pending => show LevelUpDialog
  /// - else => indicator ends immediately, user can access home
  void _runHomeLevelUpGate() {
    if (_levelUpScheduled || !_isHomeRouteActive) return;
    _levelUpScheduled = true;
    _showingLevelUpCheckIndicator = true;
    setState(() {});

    // Keep indicator visible long enough for at least one loader cycle.
    Future<void>.delayed(const Duration(milliseconds: 4000)).then((_) async {
      if (!mounted || !_isHomeRouteActive) {
        if (mounted) {
          setState(() => _showingLevelUpCheckIndicator = false);
          _levelUpScheduled = false;
        }
        return;
      }

      final level = ref.read(gameStateProvider).consumePendingLevelUp();
      if (level != null) {
        setState(() => _showingLevelUpCheckIndicator = false);
        await LevelUpDialog.show(context, level);
      } else {
        if (mounted) setState(() => _showingLevelUpCheckIndicator = false);
      }

      _levelUpScheduled = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(gameStateProvider).notifyHomeVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(
      gameStateProvider.select((g) => g.homeLevelUpCheckTick),
      (_, __) => _runHomeLevelUpGate(),
    );

    final player = ref.watch(gameStateProvider.select((g) => g.save.player));
    final session = ref.watch(gameStateProvider.select((g) => g.save.todaySession));
    final arenaMatches = ref.watch(
      gameStateProvider.select((g) => g.save.player.arenaMatchesRemaining),
    );
    final playedToday = session?.isComplete ?? false;
    final brainScore = session?.brainScore ?? 0;
    final isOnline = ref.watch(isOnlineProvider);

    return GradientScaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _HomeAvatarButton(player: player),
                        const SizedBox(width: 10),
                        Expanded(
                          child: XpBar(
                            level: player.level,
                            progress: player.levelProgress,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CoinBadge(coins: player.coins, compact: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: BrainScoreRing(
                        score: brainScore,
                        playedToday: playedToday,
                        size: 140,
                      ),
                    ),
                    if (AppFeatures.enableInAppPurchases)
                      const Positioned(
                        right: 4,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: FloatingCurrencyShopButton(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  children: [
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppAssets.streakFlame,
                            width: 28,
                            height: 28,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_fire_department,
                              color: AppColors.streakOrange,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('${player.streak} day streak'),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              if (!isOnline) {
                                showTurnOnInternetDialog(context, featureName: 'Rewards');
                                return;
                              }
                              context.push(AppRoutes.streakRewards);
                            },

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.25)),
                                  ),
                                  child: Text(
                                    'Rewards',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Choose Your Mode',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Train daily, practice freely, blitz for speed, or battle in the Arena.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (!isOnline)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, color: Colors.amberAccent, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Offline Mode — Practice Mode is active! Turn on internet for Daily, Blitz, Arena, Leaderboard & Store.',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _ModePortalCard(
                    title: 'Daily',
                    subtitle: !isOnline
                        ? 'Internet Required'
                        : (playedToday ? 'Completed' : '8 puzzles today'),
                    portalAsset: AppAssets.portalDaily,
                    iconAsset: AppAssets.iconDaily,
                    accent: AppColors.primary,
                    isOfflineLocked: !isOnline,
                    onTap: () {
                      if (!isOnline) {
                        showTurnOnInternetDialog(context, featureName: 'Daily Challenge');
                        return;
                      }
                      AudioService.instance.playPageChange();
                      context.go(AppRoutes.puzzles);
                    },
                  ),
                  _ModePortalCard(
                    title: 'Practice',
                    subtitle: !isOnline ? 'Play Offline · Earn XP' : 'No limits · earn XP',
                    portalAsset: AppAssets.portalPractice,
                    iconAsset: AppAssets.iconPractice,
                    accent: AppColors.success,
                    isOfflineAvailable: true,
                    onTap: () {
                      AudioService.instance.playPageChange();
                      context.push(AppRoutes.practice);
                    },
                  ),
                  _ModePortalCard(
                    title: 'Blitz',
                    subtitle: !isOnline
                        ? 'Internet Required'
                        : (player.level < GameUnlock.blitzLevel
                            ? 'Unlocks at Level ${GameUnlock.blitzLevel}'
                            : '60s · score multiplier'),
                    portalAsset: AppAssets.portalBlitz,
                    iconAsset: AppAssets.iconBlitz,
                    accent: AppColors.accent,
                    isLocked: player.level < GameUnlock.blitzLevel,
                    isOfflineLocked: !isOnline,
                    onTap: () {
                      if (!isOnline) {
                        showTurnOnInternetDialog(context, featureName: 'Blitz Mode');
                        return;
                      }
                      if (player.level < GameUnlock.blitzLevel) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Reach Level ${GameUnlock.blitzLevel} to unlock Blitz Mode!',
                            ),
                          ),
                        );
                        return;
                      }
                      AudioService.instance.playPageChange();
                      context.push(AppRoutes.blitz);
                    },
                  ),
                  _ModePortalCard(
                    title: 'Arena',
                    subtitle: !isOnline
                        ? 'Internet Required'
                        : (player.level < GameUnlock.arenaLevel
                            ? 'Unlocks at Level ${GameUnlock.arenaLevel}'
                            : '$arenaMatches/3 matches'),
                    portalAsset: AppAssets.portalArena,
                    iconAsset: AppAssets.iconArena,
                    accent: AppColors.gold,
                    isLocked: player.level < GameUnlock.arenaLevel,
                    isOfflineLocked: !isOnline,
                    onTap: () {
                      if (!isOnline) {
                        showTurnOnInternetDialog(context, featureName: 'Arena Mode');
                        return;
                      }
                      if (player.level < GameUnlock.arenaLevel) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Reach Level ${GameUnlock.arenaLevel} to unlock Arena Mode!',
                            ),
                          ),
                        );
                        return;
                      }
                      AudioService.instance.playPageChange();
                      context.push(AppRoutes.arena);
                    },
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _GlassHomeButton(
                        icon: Icons.leaderboard_outlined,
                        label: 'Leaderboard',
                        onTap: () {
                          if (!isOnline) {
                            showTurnOnInternetDialog(context, featureName: 'Leaderboard');
                            return;
                          }
                          context.push(AppRoutes.leaderboard);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GlassHomeButton(
                        icon: Icons.shield_outlined,
                        label: 'Arena Store',
                        onTap: () {
                          if (!isOnline) {
                            showTurnOnInternetDialog(context, featureName: 'Arena Store');
                            return;
                          }
                          context.push(AppRoutes.arenaStore);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
              ],
            ),
          ),
          if (_showingLevelUpCheckIndicator)
            Positioned.fill(
              child: AbsorbPointer(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: const Center(
                      child: MindSparkLoadingIndicator(size: 164),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModePortalCard extends StatelessWidget {
  const _ModePortalCard({
    required this.title,
    required this.subtitle,
    required this.portalAsset,
    required this.iconAsset,
    required this.accent,
    required this.onTap,
    this.isLocked = false,
    this.isOfflineLocked = false,
    this.isOfflineAvailable = false,
  });

  final String title;
  final String subtitle;
  final String portalAsset;
  final String iconAsset;
  final Color accent;
  final VoidCallback onTap;
  final bool isLocked;
  final bool isOfflineLocked;
  final bool isOfflineAvailable;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                portalAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceLight),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(iconAsset, width: 36, height: 36,
                      errorBuilder: (_, __, ___) => Icon(Icons.videogame_asset, color: accent)),
                  const Spacer(),
                  if (isOfflineLocked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi_off_rounded, size: 12, color: Colors.amberAccent),
                            SizedBox(width: 4),
                            Text(
                              'Offline',
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isOfflineAvailable)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.6)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline, size: 12, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'Offline Ready',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isLocked)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Icon(Icons.lock, color: Colors.white70, size: 28),
                    ),
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: (isLocked || isOfflineLocked) ? Colors.white70 : Colors.white,
                  )),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOfflineLocked ? Colors.amberAccent : (isLocked ? Colors.white54 : Colors.white70),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassHomeButton extends StatelessWidget {
  const _GlassHomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeAvatarButton extends StatelessWidget {
  const _HomeAvatarButton({required this.player});

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    final avatarItem = StoreCatalog.byId(player.equippedAvatar);
    final frameItem = StoreCatalog.byId(player.equippedFrame);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioService.instance.playButtonTap();
          context.go(AppRoutes.profile);
        },
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: PlayerAvatarView(
            avatarPath: avatarItem?.assetPath ?? '',
            framePath: frameItem?.assetPath,
            size: 40,
            fallbackInitial:
                player.name.isNotEmpty ? player.name[0] : 'P',
          ),
        ),
      ),
    );
  }
}
