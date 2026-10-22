import 'dart:math';

import '../../../core/utils/level_config.dart';
import '../../../core/utils/practice_config.dart';

class PatternQuestion {
  const PatternQuestion({
    required this.sequence,
    required this.correctAnswer,
    required this.choices,
  });

  final List<String> sequence;
  final String correctAnswer;
  final List<String> choices;
}

class PatternQuestionGenerator {
  PatternQuestionGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;
  static const int questionsPerSession = 8;
  static const int practiceQuestionsPerSession = 10;

  List<PatternQuestion> generateSession({bool practice = false, int playerLevel = 1}) {
    if (practice) {
      return List.generate(practiceQuestionsPerSession, (_) {
        final tier = PracticeConfig.mixedTier(playerLevel);
        final scope = TierScope(tier);
        try {
          return _generateOne();
        } finally {
          scope.restore();
        }
      });
    }
    return List.generate(questionsPerSession, (_) => _generateOne());
  }

  PatternQuestion _generateOne() {
    if (LevelConfig.tier <= 2) {
      return _numberSequence();
    }
    if (LevelConfig.tier <= 4) {
      return _colorShapeSequence();
    }
    return _matrixStyleSequence();
  }

  PatternQuestion _numberSequence() {
    final start = _random.nextInt(5) + 1;
    final step = _random.nextInt(4) + 1;
    final seq = List.generate(4, (i) => '${start + step * i}');
    final answer = '${start + step * 4}';
    return _build(seq, answer);
  }

  PatternQuestion _colorShapeSequence() {
    const shapes = ['🔴', '🔵', '🟢', '🟡'];
    final start = _random.nextInt(shapes.length);
    final seq = List.generate(4, (i) => shapes[(start + i) % shapes.length]);
    final answer = shapes[(start + 4) % shapes.length];
    return _build(seq, answer);
  }

  PatternQuestion _matrixStyleSequence() {
    final a = _random.nextInt(9) + 1;
    final b = _random.nextInt(5) + 1;
    final seq = ['$a', '${a + b}', '${a + b * 2}', '${a + b * 3}'];
    final answer = '${a + b * 4}';
    return _build(seq, answer);
  }

  PatternQuestion _build(List<String> seq, String answer) {
    final count = LevelConfig.patternChoiceCount;
    final choices = <String>{answer};
    while (choices.length < count) {
      final n = int.tryParse(answer) ?? 0;
      choices.add('${n + _random.nextInt(6) + 1}');
    }
    final list = choices.toList()..shuffle(_random);
    return PatternQuestion(sequence: seq, correctAnswer: answer, choices: list);
  }
}
