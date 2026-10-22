import 'dart:math';

import 'puzzle_type.dart';

/// Arena duel configuration — always 4 rounds, one of each premium game.
abstract final class ArenaConfig {
  static const maxMatchesPerCycle = 3;
  static const cycleHours = 8;
  static const maxScorePerRound = 300;
  static const roundsPerMatch = 4;
  static const maxMatchScore = maxScorePerRound * roundsPerMatch; // 1200

  /// Canonical set — every match includes all four, order randomized.
  static const arenaRoundPool = [
    PuzzleType.colorBrain,
    PuzzleType.cupShuffle,
    PuzzleType.weightBalance,
    PuzzleType.pathFinder,
  ];

  static const rivalNames = [
    'MindMaster_92',
    'BrainStorm_PK',
    'QuizKing_2024',
    'NeuroNinja_7',
    'LogicLord_X',
    'SynapseSavant',
    'CortexChamp',
    'IQ_Icon_88',
    'ThinkTank_Pro',
    'NeuronKnight',
    'WitWizard_42',
    'PuzzlePulse',
    'BrainBolt_99',
    'MindMaze_MX',
    'GeniusGrid',
    'RapidRecall',
    'FocusFury_21',
    'SparkSavvy',
    'CleverCore',
    'AlphaAxiom',
  ];

  /// Shuffle the four games so match order varies.
  static List<PuzzleType> generateMatchOrder([Random? rng]) {
    final rounds = List<PuzzleType>.from(arenaRoundPool);
    rounds.shuffle(rng ?? Random());
    return rounds;
  }

  static String roundLabelForType(PuzzleType type) => switch (type) {
        PuzzleType.colorBrain => 'Color Brain',
        PuzzleType.cupShuffle => 'Cup Shuffle',
        PuzzleType.weightBalance => 'Weight Balance',
        PuzzleType.pathFinder => 'Path Finder',
        _ => type.displayName,
      };

  static String roundEmojiForType(PuzzleType type) => switch (type) {
        PuzzleType.colorBrain => '🎯',
        PuzzleType.cupShuffle => '🥤',
        PuzzleType.weightBalance => '⚖️',
        PuzzleType.pathFinder => '🌀',
        _ => '🎮',
      };

  static String roundLabel(int index, List<PuzzleType> order) {
    if (index < 0 || index >= order.length) return 'Round ${index + 1}';
    final type = order[index];
    return 'Round ${index + 1}: ${roundEmojiForType(type)} ${roundLabelForType(type)}';
  }

  static PuzzleType roundType(int index, List<PuzzleType> order) =>
      order[index.clamp(0, order.length - 1)];
}
