import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/home_level_up.dart';
import '../../data/models/arena_config.dart';
import '../../data/models/game_difficulty.dart';
import '../../data/models/game_mode.dart';
import '../../data/models/puzzle_type.dart';
import '../../data/services/audio_service.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../puzzles/puzzle_flow.dart';
import 'widgets/game_island_zigzag_layout.dart';

class PracticeModeScreen extends ConsumerWidget {
  const PracticeModeScreen({super.key});

  void _showDifficultyDialog(
      BuildContext context, WidgetRef ref, PuzzleType type) {
    AudioService.instance.playButtonTap();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1B38),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Practice Difficulty',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type.displayName,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _DifficultyOptionTile(
                label: 'Easy',
                description: 'Relaxed pacing & simpler setup',
                color: Colors.greenAccent,
                icon: Icons.sentiment_satisfied_alt_rounded,
                onTap: () {
                  AudioService.instance.playButtonTap();
                  Navigator.pop(ctx);
                  launchPuzzle(
                    ref,
                    context,
                    type: type,
                    mode: GameMode.practice,
                    practiceDifficulty: GameDifficulty.easy,
                  );
                },
              ),
              const SizedBox(height: 10),
              _DifficultyOptionTile(
                label: 'Medium',
                description: 'Balanced challenge & standard speed',
                color: Colors.amberAccent,
                icon: Icons.equalizer_rounded,
                onTap: () {
                  AudioService.instance.playButtonTap();
                  Navigator.pop(ctx);
                  launchPuzzle(
                    ref,
                    context,
                    type: type,
                    mode: GameMode.practice,
                    practiceDifficulty: GameDifficulty.medium,
                  );
                },
              ),
              const SizedBox(height: 10),
              _DifficultyOptionTile(
                label: 'Hard',
                description: 'Fast pacing & complex puzzles',
                color: Colors.redAccent,
                icon: Icons.local_fire_department_rounded,
                onTap: () {
                  AudioService.instance.playButtonTap();
                  Navigator.pop(ctx);
                  launchPuzzle(
                    ref,
                    context,
                    type: type,
                    mode: GameMode.practice,
                    practiceDifficulty: GameDifficulty.hard,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService.instance.playButtonTap();
            context.pop();
            scheduleHomeLevelUpCheck(context, ref);
          },
        ),
        title: const Text('Practice Mode'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arena Premium',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: PuzzleType.arenaGames.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final type = PuzzleType.arenaGames[i];
                      return ActionChip(
                        avatar: Text(ArenaConfig.roundEmojiForType(type)),
                        label: Text(type.displayName),
                        backgroundColor:
                            AppColors.surface.withValues(alpha: 0.9),
                        labelStyle: const TextStyle(color: Colors.white),
                        onPressed: () =>
                            _showDifficultyDialog(context, ref, type),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GameSelectionBody(
              itemBuilder: (context, index, islandSize) {
                final type = PuzzleType.dailyOrder[index];
                return GameIslandSlot(
                  type: type,
                  islandSize: islandSize,
                  onTap: () => _showDifficultyDialog(context, ref, type),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyOptionTile extends StatelessWidget {
  const _DifficultyOptionTile({
    required this.label,
    required this.description,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String description;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
