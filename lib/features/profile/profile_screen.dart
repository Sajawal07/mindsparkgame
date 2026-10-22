import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/store_item.dart';
import '../../data/providers/game_providers.dart';
import '../../data/services/app_backend_service.dart';
import '../../shared/widgets/coin_badge.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/player_avatar_view.dart';
import '../../shared/widgets/xp_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final player = ref.watch(gameStateProvider).save.player;

        final avatarItem = StoreCatalog.byId(player.equippedAvatar);
        final frameItem  = StoreCatalog.byId(player.equippedFrame);
        final titleItem  = StoreCatalog.byId(player.equippedTitle);

        // Account info
        final currentUser = FirebaseAuth.instance.currentUser;
        final isAnonymous = currentUser?.isAnonymous ?? false;
        final displayName = isAnonymous
            ? (player.name.isNotEmpty && player.name != 'Player' ? player.name : 'Guest Player')
            : (currentUser?.displayName ?? player.name);
        final googleEmail = currentUser?.email;

        return GradientScaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Profile',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 32),
            children: [
              // ── Avatar + Frame ───────────────────────────────────────────
              Center(
                // Always show in-game equipped avatar/frame, not Google photo.
                child: PlayerAvatarView(
                  avatarPath: avatarItem?.assetPath ?? '',
                  framePath: frameItem?.assetPath,
                  size: 112,
                  fallbackInitial: player.name.isNotEmpty ? player.name[0] : 'P',
                ),
              ),
              const SizedBox(height: 10),

              // ── Name ────────────────────────────────────────────────────
              Center(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isAnonymous) ...[
                const SizedBox(height: 6),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.40)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.amberAccent),
                        SizedBox(width: 4),
                        Text(
                          'Guest Account',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _LinkGoogleCard(
                  onLink: () async {
                    final result = await AppBackendService.instance.linkWithGoogle();
                    if (!context.mounted) return;
                    if (result.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message ?? 'Google account linked!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      ref.read(gameStateProvider).refresh();
                    } else if (result.status == LinkGoogleStatus.credentialAlreadyInUse) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1B2E),
                          title: const Text('Account Already In Use', style: TextStyle(color: Colors.white)),
                          content: Text(
                            result.message ?? 'This Google account is already linked to another player.',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else if (result.status != LinkGoogleStatus.cancelled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message ?? 'Failed to link Google account'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
              ] else if (googleEmail != null) ...[
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    googleEmail,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              // ── Title (if equipped) ─────────────────────────────────────
              if (titleItem != null) ...[
                const SizedBox(height: 8),
                Center(child: _ProfileTitleBadge(item: titleItem, level: player.level)),
              ],
              const SizedBox(height: 20),

              // ── XP + Coins ──────────────────────────────────────────────
              XpBar(level: player.level, progress: player.levelProgress),
              const SizedBox(height: 10),
              Align(
                  alignment: Alignment.centerRight,
                  child: CoinBadge(coins: player.coins)),
              const SizedBox(height: 20),

              // ── Stats card ──────────────────────────────────────────────
              GlassCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _StatRow(
                        label: 'Current streak',
                        value: '${player.streak} days'),
                    _Divider(),
                    _StatRow(
                        label: 'Longest streak',
                        value: '${player.longestStreak} days'),
                    _Divider(),
                    _StatRow(
                        label: 'Total XP', value: '${player.xp}'),
                    _Divider(),
                    _StatRow(
                        label: 'Arena Points',
                        value: '${player.arenaPoints} AP'),
                    _Divider(),
                    _StatRow(
                        label: 'Arena Wins',
                        value: '${player.arenaWins}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Action buttons ───────────────────────────────────────────
              _GlassNavButton(
                icon: Icons.bar_chart_outlined,
                label: 'View Stats',
                onPressed: () => context.push(AppRoutes.stats),
              ),
              const SizedBox(height: 10),
              _GlassNavButton(
                icon: Icons.settings_outlined,
                label: 'Audio & Settings',
                onPressed: () => context.push(AppRoutes.settings),
              ),
              const SizedBox(height: 10),
              _GlassNavButton(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onPressed: () => context.push(AppRoutes.privacyPolicy),
              ),
              const SizedBox(height: 10),
              _GlassNavButton(
                icon: Icons.leaderboard_outlined,
                label: 'Leaderboard',
                onPressed: () => context.push(AppRoutes.leaderboard),
              ),
              const SizedBox(height: 10),
              _GlassNavButton(
                icon: Icons.local_fire_department_outlined,
                label: 'Streak Rewards',
                onPressed: () => context.push(AppRoutes.streakRewards),
              ),
              const SizedBox(height: 24),

              // ── Disclaimer ───────────────────────────────────────────────
              Text(
                AppStrings.iqDisclaimer,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: Colors.white.withValues(alpha: 0.10), height: 1);
  }
}

class _GlassNavButton extends StatelessWidget {
  const _GlassNavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 12,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Equipped title on profile — badge image keeps aspect ratio; text centered on top.
class _ProfileTitleBadge extends StatelessWidget {
  const _ProfileTitleBadge({required this.item, required this.level});

  final StoreItem item;
  final int level;

  String _getLevelTitleText(int lvl) {
    switch (lvl) {
      case 1: return 'The Novice';
      case 2: return 'Curious Mind';
      case 3: return 'Aspiring Learner';
      case 4: return 'Steady Thinker';
      case 5: return 'Bright Spark';
      case 6: return 'Quick Solver';
      case 7: return 'Logic Builder';
      case 8: return 'Sharp Intellect';
      case 9: return 'Keen Observer';
      case 10: return 'Rising Scholar';
      case 11: return 'Brain Explorer';
      case 12: return 'Mind Gymnast';
      case 13: return 'Adept Thinker';
      case 14: return 'Cognitive Prodigy';
      case 15: return 'Master Strategist';
      case 16: return 'Advanced Mind';
      case 17: return 'Mental Athlete';
      case 18: return 'Wisdom Seeker';
      case 19: return 'Intellectual Star';
      case 20: return 'The Mastermind';
      case 21: return 'Elite Scholar';
      case 22: return 'Genius Intellect';
      case 23: return 'Visionary Thinker';
      case 24: return 'Brain Trust';
      case 25: return 'Grandmaster';
      case 26: return 'Cognitive Supreme';
      case 27: return 'Infinite Wisdom';
      case 28: return 'Legendary Thinker';
      case 29: return 'Omniscient Sage';
      case 30: return 'The Mind God';
      default: return 'Level $lvl Scholar';
    }
  }

  static const _badgeHeight = 54.0;
  static const _minBadgeWidth = 252.0;
  static const _maxBadgeWidth = 390.0;
  static const _textHorizontalPad = 40.0;
  static const _fallbackMinWidth = 252.0;

  @override
  Widget build(BuildContext context) {
    final hasAsset =
        item.assetPath != null && item.assetPath!.isNotEmpty;

    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: _minBadgeWidth,
          maxWidth: _maxBadgeWidth,
        ),
        child: SizedBox(
          height: _badgeHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (hasAsset)
                Center(
                  child: Image.asset(
                    item.assetPath!,
                    height: _badgeHeight,
                    fit: BoxFit.fitHeight,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: _fallbackMinWidth,
                      height: _badgeHeight,
                      child: _FallbackTitleBg(),
                    ),
                  ),
                )
              else
                const SizedBox(
                  width: _fallbackMinWidth,
                  height: _badgeHeight,
                  child: _FallbackTitleBg(),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _textHorizontalPad,
                ),
                child: Text(
                  _getLevelTitleText(level),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackTitleBg extends StatelessWidget {
  const _FallbackTitleBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.4)),
      ),
    );
  }
}

class _LinkGoogleCard extends StatefulWidget {
  const _LinkGoogleCard({required this.onLink});
  final Future<void> Function() onLink;

  @override
  State<_LinkGoogleCard> createState() => _LinkGoogleCardState();
}

class _LinkGoogleCardState extends State<_LinkGoogleCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_upload_outlined, color: AppColors.primaryLight, size: 20),
              SizedBox(width: 8),
              Text(
                'Protect Your Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Link a Google account to save your brain stats, streak, and coins across devices.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      try {
                        await widget.onLink();
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1F1F1F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: _isLoading
                  ? const SizedBox.shrink()
                  : const Icon(Icons.account_circle, size: 18, color: Color(0xFF4285F4)),
              label: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Text(
                      'Link Google Account',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
