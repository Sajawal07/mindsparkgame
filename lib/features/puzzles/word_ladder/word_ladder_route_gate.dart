import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/game_mode.dart';
import '../../../data/models/word_ladder_data.dart';
import '../../../data/providers/game_providers.dart';
import 'word_ladder_difficulty_screen.dart';
import 'word_ladder_screen.dart';

/// Practice shows difficulty picker; daily and other modes use level-based difficulty.
class WordLadderRouteGate extends ConsumerWidget {
  const WordLadderRouteGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(puzzleSessionProvider);
    if (session.mode == GameMode.practice) {
      return const WordLadderDifficultyScreen();
    }

    if (session.mode == GameMode.arena) {
      return const WordLadderScreen(difficulty: WordLadderDifficulty.hard);
    }

    // Daily: fixed difficulty odds (Hard 10%, Medium 35%, Easy 55%).
    final todayKey = ref.read(gameStateProvider).save.todaySession?.dateKey ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final seed =
        todayKey.codeUnits.fold<int>(0, (p, e) => (p * 31 + e) & 0x7fffffff);
    final rng = Random(seed);
    final roll = rng.nextInt(100); // 0..99

    final difficulty = switch (roll) {
      // 10%
      >= 90 => WordLadderDifficulty.hard,
      // next 35% (55..89)
      >= 55 => WordLadderDifficulty.medium,
      // remaining 55%
      _ => WordLadderDifficulty.easy,
    };

    return WordLadderScreen(difficulty: difficulty);
  }
}
