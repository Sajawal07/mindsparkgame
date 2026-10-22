import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/utils/level_config.dart';
import '../../features/puzzles/math_blitz/math_question_generator.dart';
import '../../features/puzzles/pattern_iq/pattern_question_generator.dart';
import '../models/blitz_question.dart';
import '../models/science_fact.dart';

class BlitzQuestionEngine {
  BlitzQuestionEngine({Random? random}) : _random = random ?? Random();

  final Random _random;
  final _mathGen = MathQuestionGenerator();
  final _patternGen = PatternQuestionGenerator();

  static const _wordPool = [
    'brain', 'spark', 'logic', 'focus', 'quick', 'train', 'cloud', 'light',
    'plant', 'apple', 'grape', 'house', 'chair', 'bread', 'ocean', 'winter',
    'music', 'garden', 'silver', 'energy', 'planet', 'forest', 'mindful',
  ];

  BlitzGameType pickRandomGame() {
    const types = BlitzGameType.values;
    return types[_random.nextInt(types.length)];
  }

  BlitzQuestion generate({BlitzGameType? type}) {
    final game = type ?? pickRandomGame();
    return switch (game) {
      BlitzGameType.mathBlitz => _mathQuestion(),
      BlitzGameType.wordSnap => _wordSnapQuestion(),
      BlitzGameType.patternIq => _patternQuestion(),
      BlitzGameType.scienceSnap => _scienceQuestion(),
      BlitzGameType.focusFind => _focusFindQuestion(),
    };
  }

  BlitzQuestion _mathQuestion() {
    final q = _mathGen.generateQuestion();
    final correctIdx = q.choices.indexOf(q.correctAnswer);
    return BlitzQuestion(
      type: BlitzGameType.mathBlitz,
      prompt: q.prompt,
      choices: q.choices.map((c) => '$c').toList(),
      correctIndex: correctIdx >= 0 ? correctIdx : 0,
    );
  }

  BlitzQuestion _wordSnapQuestion() {
    final word = _wordPool[_random.nextInt(_wordPool.length)];
    final scrambled = word.split('')..shuffle(_random);
    final decoys = <String>{};
    while (decoys.length < 3) {
      final w = _wordPool[_random.nextInt(_wordPool.length)];
      if (w != word) decoys.add(w.toUpperCase());
    }
    final choices = [word.toUpperCase(), ...decoys]..shuffle(_random);
    return BlitzQuestion(
      type: BlitzGameType.wordSnap,
      prompt: scrambled.join(' ').toUpperCase(),
      choices: choices,
      correctIndex: choices.indexOf(word.toUpperCase()),
    );
  }

  BlitzQuestion _patternQuestion() {
    final q = _patternGen.generateSession(playerLevel: LevelConfig.playerLevel).first;
    final correctIdx = q.choices.indexOf(q.correctAnswer);
    return BlitzQuestion(
      type: BlitzGameType.patternIq,
      prompt: 'What comes next?',
      choices: q.choices,
      correctIndex: correctIdx >= 0 ? correctIdx : 0,
      sequence: q.sequence,
    );
  }

  BlitzQuestion _scienceQuestion() {
    final fact = ScienceFactData.facts[_random.nextInt(ScienceFactData.facts.length)];
    final choices = ['True', 'False'];
    return BlitzQuestion(
      type: BlitzGameType.scienceSnap,
      prompt: fact.statement,
      choices: choices,
      correctIndex: fact.isTrue ? 0 : 1,
    );
  }

  BlitzQuestion _focusFindQuestion() {
    const icons = [
      Icons.star,
      Icons.favorite,
      Icons.bolt,
      Icons.cloud,
      Icons.eco,
    ];
    const colors = [
      Colors.amber,
      Colors.red,
      Colors.blue,
      Colors.grey,
      Colors.green,
    ];
    final cols = 3 + _random.nextInt(2);
    final count = cols * cols;
    final oddIdx = _random.nextInt(count);
    final baseIcon = icons[_random.nextInt(icons.length)];
    final baseColor = colors[_random.nextInt(colors.length)];
    final oddIcon = icons.firstWhere((i) => i != baseIcon, orElse: () => Icons.diamond);
    final oddColor = colors.firstWhere((c) => c != baseColor, orElse: () => Colors.purple);

    final gridIcons = List<IconData>.generate(
      count,
      (i) => i == oddIdx ? oddIcon : baseIcon,
    );
    final gridColors = List<Color>.generate(
      count,
      (i) => i == oddIdx ? oddColor : baseColor,
    );

    return BlitzQuestion(
      type: BlitzGameType.focusFind,
      prompt: 'Tap the odd one out',
      choices: List.generate(count, (i) => '$i'),
      correctIndex: oddIdx,
      gridIcons: gridIcons,
      gridColors: gridColors,
      oddIndex: oddIdx,
    );
  }

  static int multiplierForStreak(int streak) {
    if (streak >= 15) return 5;
    if (streak >= 10) return 3;
    if (streak >= 5) return 2;
    return 1;
  }
}
