import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/arena_config.dart';
import '../../data/models/game_mode.dart';
import '../../data/models/puzzle_session_config.dart';
import '../../data/providers/game_providers.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/brain_score_service.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/victory_flares/victory_flare.dart';
import '../puzzles/puzzle_flow.dart';

class ArenaRoundResultExtra {
  const ArenaRoundResultExtra({
    required this.roundIndex,
    required this.playerRoundScore,
    required this.playerTotal,
    required this.isFinalRound,
  });

  final int roundIndex;
  final int playerRoundScore;
  final int playerTotal;
  final bool isFinalRound;
}

class ArenaRoundResultScreen extends ConsumerStatefulWidget {
  const ArenaRoundResultScreen({super.key, required this.extra});

  final ArenaRoundResultExtra extra;

  @override
  ConsumerState<ArenaRoundResultScreen> createState() =>
      _ArenaRoundResultScreenState();
}

class _ArenaRoundResultScreenState extends ConsumerState<ArenaRoundResultScreen> {
  @override
  void initState() {
    super.initState();
    AudioService.instance.playSfx(Sfx.achievement);
  }

  Future<void> _continue() async {
    final extra = widget.extra;
    if (extra.isFinalRound) {
      final arenaResult = await ref.read(gameStateProvider).finishArenaMatch();
      if (!mounted) return;
      context.go(AppRoutes.arena, extra: arenaResult);
      return;
    }

    final match = ref.read(gameStateProvider).activeArenaMatch;
    if (match == null) {
      if (mounted) context.go(AppRoutes.arena);
      return;
    }
    final nextRound = extra.roundIndex + 1;
    final nextType = ArenaConfig.roundType(nextRound, match.roundOrder);
    ref.read(puzzleSessionProvider.notifier).state = PuzzleSessionConfig(
      mode: GameMode.arena,
      type: nextType,
      arenaRoundIndex: nextRound,
    );
    if (!mounted) return;
    context.pushReplacement(puzzleRouteForType(nextType));
  }

  @override
  Widget build(BuildContext context) {
    final extra = widget.extra;
    final match = ref.watch(gameStateProvider).activeArenaMatch;
    final order = match?.roundOrder ?? ArenaConfig.arenaRoundPool;
    final title = ArenaConfig.roundLabel(extra.roundIndex, order);
    final equippedFlair = ref.watch(gameStateProvider).save.player.equippedVictoryFlair;

    return Stack(
      children: [
        GradientScaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Round ${extra.roundIndex + 1} Complete',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                _ScoreCard(
                  label: 'Round Score',
                  score: extra.playerRoundScore,
                  highlight: true,
                ),
                const SizedBox(height: 24),
                Text(
                  'Match total: ${extra.playerTotal}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                Builder(
                  builder: (context) {
                    final rank = BrainScoreService.simulateIqForRound(
                      score: extra.playerRoundScore,
                      maxScore: ArenaConfig.maxScorePerRound,
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
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continue,
                    child: Text(extra.isFinalRound ? 'Finish Match' : 'Next Round'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: VictoryFlare.fromId(
              equippedFlair,
              autoStart: true,
              loop: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.score,
    required this.highlight,
  });

  final String label;
  final int score;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight
          ? AppColors.success.withValues(alpha: 0.2)
          : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '$score',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: highlight ? AppColors.gold : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
