import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/home_level_up.dart';
import '../../data/models/game_mode.dart';
import '../../data/models/puzzle_type.dart';
import '../../data/providers/game_providers.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/brain_score_service.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/victory_flares/victory_flare.dart';
import 'puzzle_result_extra.dart';

class PuzzleResultScreen extends ConsumerWidget {
  const PuzzleResultScreen({super.key, required this.extra});

  final PuzzleResultExtra extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPractice = extra.mode == GameMode.practice;
    final image = isPractice && extra.isNewBest
        ? AppAssets.practiceTrophy
        : AppAssets.dailyCompleteCelebration;
    final equippedFlair = ref.watch(gameStateProvider).save.player.equippedVictoryFlair;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _navigateBack(context, ref, extra);
      },
      child: Stack(
        children: [
          GradientScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _navigateBack(context, ref, extra),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                image,
                height: 100,
                errorBuilder: (_, __, ___) => Icon(
                  isPractice ? Icons.emoji_events : Icons.celebration,
                  size: 80,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isPractice
                    ? '${extra.type.displayName} — Practice'
                    : '${extra.type.displayName} Complete!',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${extra.score} / ${extra.maxScore}',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Text(
                '${extra.correctCount}/${extra.totalCount} correct · '
                '${(extra.accuracy * 100).round()}% accuracy',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (isPractice) ...[
                const SizedBox(height: 8),
                Text(
                  extra.isNewBest
                      ? 'New personal best!'
                      : 'Best: ${extra.previousBest}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: extra.isNewBest
                            ? AppColors.gold
                            : AppColors.textSecondary,
                      ),
                ),
                if (extra.xpEarned > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+${extra.xpEarned} XP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.success,
                        ),
                  ),
                ],
              ] else ...[
                if (extra.xpEarned > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+${extra.xpEarned} XP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.success,
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final rank = BrainScoreService.simulateIqForRound(
                      score: extra.score,
                      maxScore: extra.maxScore,
                    );
                    return Column(
                      children: [
                        Text(
                          rank.displayName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Estimated IQ: ${rank.iqEstimate}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rank.comparison,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateBack(context, ref, extra),
                  child: Text(
                    isPractice
                        ? 'Back to Practice'
                        : extra.mode == GameMode.blitz
                            ? 'Back to Blitz'
                            : extra.mode == GameMode.arena
                                ? 'Back to Arena'
                                : extra.sessionComplete
                                    ? 'View Brain Score'
                                    : 'Next Puzzle',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: MediaQuery.paddingOf(context).top + 160,
        child: IgnorePointer(
          child: VictoryFlare.fromId(
            equippedFlair,
            autoStart: true,
            loop: true,
            maxLoops: 3,
            intensity: 0.85,
          ),
        ),
      ),
    ],
  ),
);
}

  void _navigateBack(
    BuildContext context,
    WidgetRef ref,
    PuzzleResultExtra extra,
  ) {
    AudioService.instance.playButtonTap();
    if (extra.mode == GameMode.practice ||
        extra.mode == GameMode.blitz ||
        extra.mode == GameMode.arena) {
      if (context.canPop()) {
        context.pop();
        scheduleHomeLevelUpCheck(context, ref);
      } else {
        context.go(AppRoutes.home);
        ref.read(gameStateProvider).notifyHomeVisible();
      }
      return;
    }
    if (extra.sessionComplete) {
      context.go(AppRoutes.dailyResult);
    } else {
      context.go(AppRoutes.puzzles);
    }
  }
}
