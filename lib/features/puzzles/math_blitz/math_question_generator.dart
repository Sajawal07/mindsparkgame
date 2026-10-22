import 'dart:math';

import '../../../core/utils/level_config.dart';
import '../../../core/utils/practice_config.dart';
import 'math_question.dart';

class MathQuestionGenerator {
  MathQuestionGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;
  static const int questionsPerSession = 10;
  static const int practiceQuestionsPerSession = 12;

  List<MathQuestion> generateSession({bool practice = false, int playerLevel = 1}) {
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

  MathQuestion generateQuestion() => _generateOne();

  MathQuestion _generateOne() {
    if (LevelConfig.mathUseAlgebra) {
      return _algebraQuestion();
    }
    if (LevelConfig.tier >= 4) {
      return _multiStepQuestion();
    }
    return _basicQuestion();
  }

  MathQuestion _basicQuestion() {
    final cap = LevelConfig.mathNumberMax;
    final a = _random.nextInt(cap) + 1;
    final b = _random.nextInt(cap) + 1;
    final useMul = LevelConfig.mathUseMultiply && _random.nextBool();
    final useDiv = LevelConfig.mathUseDivide && !useMul && _random.nextBool();

    if (useMul) {
      return _build('$a × $b', a * b);
    }
    if (useDiv && b != 0 && a % b == 0) {
      return _build('${a * b} ÷ $b', a);
    }

    if (_random.nextBool()) {
      return _build('$a + $b', a + b);
    }
    final hi = max(a, b);
    final lo = min(a, b);
    return _build('$hi - $lo', hi - lo);
  }

  MathQuestion _multiStepQuestion() {
    final a = _random.nextInt(20) + 1;
    final b = _random.nextInt(10) + 1;
    final c = _random.nextInt(10) + 1;
    return _build('$a + $b × $c', a + b * c);
  }

  MathQuestion _algebraQuestion() {
    final x = _random.nextInt(20) + 1;
    final b = _random.nextInt(15) + 1;
    return _build('x + $b = ${x + b}', x);
  }

  MathQuestion _build(String prompt, int answer) {
    final choices = <int>{answer};
    while (choices.length < 4) {
      final delta = _random.nextInt(10) + 1;
      choices.add(answer + (_random.nextBool() ? delta : -delta));
    }
    final list = choices.toList()..shuffle(_random);
    return MathQuestion(prompt: prompt, correctAnswer: answer, choices: list);
  }
}
