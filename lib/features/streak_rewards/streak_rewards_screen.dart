import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/game_providers.dart';
import '../../data/services/audio_service.dart';
import '../../shared/widgets/gradient_scaffold.dart';

class _StreakMilestone {
  const _StreakMilestone({
    required this.days,
    required this.reward,
    required this.coins,
  });

  final int days;
  final String reward;
  final int coins;
}

const _milestones = [
  _StreakMilestone(days: 3, reward: 'Spark Starter', coins: 50),
  _StreakMilestone(days: 7, reward: 'Week Warrior', coins: 150),
  _StreakMilestone(days: 14, reward: 'Fortnight Focus', coins: 300),
  _StreakMilestone(days: 30, reward: 'Month Mind', coins: 750),
];

class StreakRewardsScreen extends ConsumerWidget {
  const StreakRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(gameStateProvider).save.player.streak;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Streak Rewards'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Image.asset(
              AppAssets.streakFlame,
              height: 80,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.local_fire_department,
                size: 64,
                color: AppColors.streakOrange,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$streak day streak',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your daily challenge alive to unlock milestone rewards.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ..._milestones.map((m) {
            final unlocked = streak >= m.days;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: unlocked
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surface,
              child: ListTile(
                leading: Icon(
                  unlocked ? Icons.check_circle : Icons.lock_outline,
                  color: unlocked ? AppColors.success : AppColors.textSecondary,
                ),
                title: Text('${m.days} days — ${m.reward}'),
                subtitle: Text('+${m.coins} coins'),
                trailing: unlocked
                    ? TextButton(
                        onPressed: () async {
                          await AudioService.instance.playSfx(Sfx.streakReward);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reward tracked! ${m.coins} coins on your next daily claim.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Claim'),
                      )
                    : Text('${m.days - streak} days left'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
