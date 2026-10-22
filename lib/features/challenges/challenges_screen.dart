import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/challenge_model.dart';
import '../../data/providers/game_providers.dart';
import '../../shared/widgets/coin_badge.dart';
import '../../shared/widgets/coin_icon.dart';
import '../../shared/widgets/gradient_scaffold.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameStateProvider);
    final challenges = game.save.meta.challenges;
    final daily = challenges.where((c) => c.type == ChallengeType.daily);
    final weekly = challenges.where((c) => c.type == ChallengeType.weekly);
    final lifetime = challenges.where((c) => c.type == ChallengeType.lifetime);

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CoinBadge(coins: game.save.player.coins),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(title: 'Daily', challenges: daily.toList(), ref: ref),
          const SizedBox(height: 20),
          _Section(title: 'Weekly', challenges: weekly.toList(), ref: ref),
          const SizedBox(height: 20),
          _Section(title: 'Lifetime', challenges: lifetime.toList(), ref: ref),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.challenges,
    required this.ref,
  });

  final String title;
  final List<ChallengeModel> challenges;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        ...challenges.map((c) => _ChallengeTile(challenge: c, ref: ref)),
      ],
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({required this.challenge, required this.ref});

  final ChallengeModel challenge;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final progress = challenge.target > 0
        ? challenge.progress / challenge.target
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const CoinIcon(size: 16),
                Text(' ${challenge.rewardCoins}'),
              ],
            ),
            const SizedBox(height: 4),
            Text(challenge.description),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.ringEmpty,
              color: challenge.isComplete ? AppColors.success : AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              '${challenge.progress} / ${challenge.target}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (challenge.isComplete && !challenge.isClaimed) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final coins = await ref
                        .read(gameStateProvider)
                        .claimChallenge(challenge.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          coins != null
                              ? 'Claimed $coins coins!'
                              : 'Could not claim',
                        ),
                      ),
                    );
                  },
                  child: const Text('Claim Reward'),
                ),
              ),
            ],
            if (challenge.isClaimed)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    SizedBox(width: 4),
                    Text('Claimed'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
