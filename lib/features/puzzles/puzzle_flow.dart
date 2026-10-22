import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/utils/puzzle_scores.dart';
import '../../data/models/arena_config.dart';
import '../../data/models/game_difficulty.dart';
import '../../data/models/game_mode.dart';
import '../../data/models/puzzle_session_config.dart';
import '../../data/models/puzzle_type.dart';
import '../../data/providers/game_providers.dart';
import '../../data/services/achievement_service.dart';
import '../../data/services/audio_service.dart';
import '../modes/arena_round_result_screen.dart';
import 'puzzle_result_extra.dart';

String puzzleRouteForType(PuzzleType type) => switch (type) {
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

void launchPuzzle(
  WidgetRef ref,
  BuildContext context, {
  required PuzzleType type,
  required GameMode mode,
  int? arenaRoundIndex,
  GameDifficulty? practiceDifficulty,
}) {
  ref.read(puzzleSessionProvider.notifier).state = PuzzleSessionConfig(
    mode: mode,
    type: type,
    arenaRoundIndex: arenaRoundIndex,
    practiceDifficulty: practiceDifficulty,
  );
  context.push(puzzleRouteForType(type));
}

Future<void> finishPuzzleAndShowResult({
  required BuildContext context,
  required WidgetRef ref,
  required PuzzleType type,
  required int score,
  required double accuracy,
  required int timeTakenSeconds,
  required int correctCount,
  required int totalCount,
  int? maxScoreOverride,
}) async {
  final session = ref.read(puzzleSessionProvider);
  final maxScore = maxScoreOverride ?? PuzzleScores.maxScore(type);
  final clampedScore = score.clamp(0, maxScore);

  AchievementService.emitGameComplete(
    type: type,
    score: clampedScore,
    accuracy: accuracy,
    perfect: clampedScore >= maxScore && accuracy >= 0.99,
  );

  if (session.mode == GameMode.practice) {
    final result = await ref.read(gameStateProvider).completePracticePuzzle(
          type: type,
          score: clampedScore,
        );
    await AudioService.instance.playSfx(Sfx.puzzleComplete);
    if (result.isNewBest) {
      await AudioService.instance.playSfx(Sfx.achievement);
    }
    if (!context.mounted) return;
    context.pushReplacement(
      AppRoutes.puzzleResult,
      extra: PuzzleResultExtra(
        mode: GameMode.practice,
        type: type,
        score: clampedScore,
        maxScore: maxScore,
        accuracy: accuracy,
        correctCount: correctCount,
        totalCount: totalCount,
        isNewBest: result.isNewBest,
        previousBest: result.previousBest,
        xpEarned: result.xpEarned,
      ),
    );
    return;
  }

  if (session.mode == GameMode.arena) {
    final match = ref.read(gameStateProvider).activeArenaMatch;
    if (match == null) {
      if (context.mounted) context.pop();
      return;
    }

    final roundIndex = session.arenaRoundIndex ?? match.round;
    final isPerfect = clampedScore >= ArenaConfig.maxScorePerRound;

    ref.read(gameStateProvider).addArenaRoundScore(
          playerRoundScore: clampedScore,
          maxRoundScore: ArenaConfig.maxScorePerRound,
          isPerfect: isPerfect,
        );

    await AudioService.instance.playSfx(Sfx.puzzleComplete);
    if (!context.mounted) return;

    final updatedMatch = ref.read(gameStateProvider).activeArenaMatch!;
    final isFinalRound = updatedMatch.round >= ArenaConfig.roundsPerMatch;

    context.pushReplacement(
      AppRoutes.arenaRoundResult,
      extra: ArenaRoundResultExtra(
        roundIndex: roundIndex,
        playerRoundScore: clampedScore,
        playerTotal: updatedMatch.playerTotal,
        isFinalRound: isFinalRound,
      ),
    );
    return;
  }

  final outcome = await ref.read(gameStateProvider).completePuzzle(
        type: type,
        score: clampedScore,
        accuracy: accuracy,
        timeTakenSeconds: timeTakenSeconds,
      );
  await AudioService.instance.playSfx(Sfx.puzzleComplete);
  if (outcome.coinsEarned > 0) {
    await AudioService.instance.playSfx(Sfx.coin);
  }
  if (outcome.sessionNowComplete) {
    await AudioService.instance.playSfx(Sfx.dailyComplete);
  }

  if (!context.mounted) return;
  context.pushReplacement(
    AppRoutes.puzzleResult,
    extra: PuzzleResultExtra(
      mode: GameMode.daily,
      type: type,
      score: clampedScore,
      maxScore: maxScore,
      accuracy: accuracy,
      correctCount: correctCount,
      totalCount: totalCount,
      xpEarned: outcome.xpEarned,
      sessionComplete: outcome.sessionNowComplete,
    ),
  );
}
