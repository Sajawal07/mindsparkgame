import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/daily_session_model.dart';
import '../../data/models/iq_rank.dart';
import '../../data/models/puzzle_type.dart';
import '../../data/providers/game_providers.dart';
import '../../shared/widgets/coin_icon.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/victory_flares/victory_flare.dart';

class DailyResultScreen extends ConsumerWidget {
  const DailyResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameStateProvider).save.todaySession;
    if (session == null || !session.isComplete) {
      return GradientScaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.puzzles),
            child: const Text('Back to Puzzles'),
          ),
        ),
      );
    }

    final rank = IqRank.fromBrainScore(session.brainScore);
    final player = ref.watch(gameStateProvider).save.player;

    return Stack(
      children: [
        GradientScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Image.asset(
              rank.illustrationAsset,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.psychology,
                size: 100,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Brain Score',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${session.brainScore}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 56,
                    color: AppColors.primaryLight,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              rank.displayName,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text(
              'IQ estimate: ${rank.iqEstimate}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              rank.comparison,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _BreakdownCard(session: session),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RewardChip(
                  leading: const CoinIcon(size: 18),
                  label: '+${session.coinsEarned} coins',
                  color: AppColors.gold,
                ),
                _RewardChip(
                  icon: Icons.star,
                  label: '+${session.xpEarned} XP',
                  color: AppColors.primaryLight,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Streak: ${player.streak} days',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.share),
                icon: const Icon(Icons.share),
                label: const Text('Share Result'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Back to Home'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.iqDisclaimer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
    Positioned.fill(
      child: IgnorePointer(
        child: VictoryFlare.fromId(
          player.equippedVictoryFlair,
          autoStart: true,
          loop: true,
        ),
      ),
    ),
  ],
);
}
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.session});

  final DailySessionModel session;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Puzzle Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...session.puzzleResults.map((r) {
              final type = r.puzzleType;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(type.displayName),
                    Text('${r.score} pts'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    this.icon,
    this.leading,
    required this.label,
    required this.color,
  }) : assert(icon != null || leading != null);

  final IconData? icon;
  final Widget? leading;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: leading ?? Icon(icon, color: color, size: 20),
      label: Text(label),
      backgroundColor: AppColors.surfaceLight,
    );
  }
}
