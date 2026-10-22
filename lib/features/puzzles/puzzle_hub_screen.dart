import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/puzzle_session_config.dart';
import '../../data/models/puzzle_type.dart';
import '../../data/providers/game_providers.dart';
import '../../data/providers/network_provider.dart';
import '../../data/services/audio_service.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/network/no_internet_view.dart';
import '../modes/widgets/game_island_zigzag_layout.dart';

class PuzzleHubScreen extends ConsumerWidget {
  const PuzzleHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final save = ref.watch(gameStateProvider).save;
    final completed = PuzzleType.dailyOrder
        .asMap()
        .keys
        .where((i) => save.isPuzzleComplete(i))
        .length;
    final total = PuzzleType.dailyOrder.length;
    final allDone = save.isTodaySessionComplete;
    final progress = completed / total;
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final remaining = midnight.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.grid_view_outlined),
          onPressed: () {
            AudioService.instance.playPageChange();
            context.go(AppRoutes.home);
          },
        ),
        title: const Text('Daily Challenge'),
        actions: [
          if (allDone && isOnline)
            TextButton(
              onPressed: () => context.push(AppRoutes.dailyResult),
              child: const Text('Results'),
            ),
        ],
      ),
      body: !isOnline
          ? const NoInternetView(
              featureName: 'Daily Challenge',
              customMessage: 'Daily Challenge requires an active internet connection to synchronize puzzles and daily brain scores.',
              showPracticeOption: true,
            )
          : GameSelectionBody(
        topOverlay: _DailyProgressStrip(
          completed: completed,
          total: total,
          allDone: allDone,
          brainScore: save.todaySession?.brainScore ?? 0,
          progress: progress,
          hours: hours,
          minutes: minutes,
        ),
        itemBuilder: (context, index, islandSize) {
          final type = PuzzleType.dailyOrder[index];
          final complete = save.isPuzzleComplete(index);
          final unlocked = save.isPuzzleUnlocked(index);
          return GameIslandSlot(
            type: type,
            islandSize: islandSize,
            onTap: complete
                ? null
                : () {
                    AudioService.instance.playButtonTap();
                    if (!unlocked) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Complete the previous puzzle first.',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      return;
                    }
                    ref.read(puzzleSessionProvider.notifier).state =
                        PuzzleSessionConfig.daily;
                    context.push(_routeForType(type));
                  },
          );
        },
      ),
    );
  }

  String _routeForType(PuzzleType type) => switch (type) {
        PuzzleType.mathBlitz => AppRoutes.puzzleMath,
        PuzzleType.memoryFlip => AppRoutes.puzzleMemory,
        PuzzleType.patternIq => AppRoutes.puzzlePattern,
        PuzzleType.wordSnap => AppRoutes.puzzleWord,
        PuzzleType.focusFind => AppRoutes.puzzleFocus,
        PuzzleType.whoAmI => AppRoutes.puzzleWhoAmI,
        PuzzleType.scienceSnap => AppRoutes.puzzleScienceSnap,
        PuzzleType.wordLadder => AppRoutes.puzzleWordLadder,
        PuzzleType.colorBrain => AppRoutes.puzzleColorBrain,
        PuzzleType.cupShuffle => AppRoutes.puzzleCupShuffle,
        PuzzleType.weightBalance => AppRoutes.puzzleWeightBalance,
        PuzzleType.pathFinder => AppRoutes.puzzlePathFinder,
      };
}

class _DailyProgressStrip extends StatelessWidget {
  const _DailyProgressStrip({
    required this.completed,
    required this.total,
    required this.allDone,
    required this.brainScore,
    required this.progress,
    required this.hours,
    required this.minutes,
  });

  final int completed;
  final int total;
  final bool allDone;
  final int brainScore;
  final double progress;
  final int hours;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      allDone
                          ? 'All complete · Score $brainScore'
                          : '$completed / $total done',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: AppColors.ringEmpty,
                        color: allDone ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.schedule_rounded, size: 11, color: AppColors.accent),
              const SizedBox(width: 2),
              Text(
                '${hours}h ${minutes}m',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
