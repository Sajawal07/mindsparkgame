import 'dart:math';

import 'weight_balance_config.dart';

/// One balance equation shown to the player.
class WeightEquation {
  WeightEquation({
    required this.left,
    this.rightEmojis = const {},
    this.rightNumber,
    required this.display,
  }) : assert(rightNumber != null || rightEmojis.isNotEmpty);

  /// Left pan: emoji → count.
  final Map<String, int> left;

  /// Right pan emoji counts (when not a numeric weight).
  final Map<String, int> rightEmojis;

  /// Right pan numeric weight.
  final int? rightNumber;

  final String display;

  bool get rightIsNumber => rightNumber != null;
}

/// A generated, uniquely solvable weight-balance puzzle.
class WeightBalancePuzzle {
  const WeightBalancePuzzle({
    required this.difficulty,
    required this.values,
    required this.equations,
    required this.askEmoji,
    required this.answer,
    this.choices,
    this.solverEquations,
  });

  final WeightBalanceDifficulty difficulty;
  final Map<String, int> values;
  final List<WeightEquation> equations;
  final String askEmoji;
  final int answer;

  /// Four MCQ options when non-null; otherwise use keypad.
  final List<int>? choices;

  /// Additive encodings used by the uniqueness solver when display lines use
  /// × / − notation that is not purely pan-additive.
  final List<WeightEquation>? solverEquations;

  bool get useKeypad => choices == null;

  List<WeightEquation> get equationsForSolver =>
      solverEquations ?? equations;
}

/// Substitution / domain-search solver for 2–4 unknowns.
abstract final class WeightBalanceSolver {
  /// Returns the unique integer weight for [askEmoji], or null if ambiguous.
  static int? solveUnique({
    required List<String> unknowns,
    required List<WeightEquation> equations,
    required String askEmoji,
    required Map<String, int> groundTruth,
  }) {
    for (final eq in equations) {
      final left = _sideWeight(eq.left, groundTruth);
      final right = eq.rightIsNumber
          ? eq.rightNumber!
          : _sideWeight(eq.rightEmojis, groundTruth);
      if (left != right) return null;
    }

    final domain = _domainFor(unknowns.length);
    final counts = <int, int>{};

    void search(int depth, Map<String, int> assign) {
      if (depth == unknowns.length) {
        if (_satisfies(equations, assign)) {
          final v = assign[askEmoji]!;
          counts[v] = (counts[v] ?? 0) + 1;
        }
        return;
      }
      final emoji = unknowns[depth];
      for (final w in domain) {
        assign[emoji] = w;
        search(depth + 1, assign);
      }
      assign.remove(emoji);
    }

    search(0, {});
    if (counts.length != 1) return null;
    final only = counts.keys.first;
    if (only != groundTruth[askEmoji]) return null;
    return only;
  }

  static List<int> _domainFor(int n) {
    final max = n <= 2 ? 20 : 12;
    return List<int>.generate(max, (i) => i + 1);
  }

  static bool _satisfies(
    List<WeightEquation> equations,
    Map<String, int> assign,
  ) {
    for (final eq in equations) {
      if (!_sideDefined(eq.left, assign)) return false;
      final left = _sideWeight(eq.left, assign);
      if (eq.rightIsNumber) {
        if (left != eq.rightNumber) return false;
      } else {
        if (!_sideDefined(eq.rightEmojis, assign)) return false;
        if (left != _sideWeight(eq.rightEmojis, assign)) return false;
      }
    }
    return true;
  }

  static bool _sideDefined(Map<String, int> side, Map<String, int> values) =>
      side.keys.every(values.containsKey);

  static int _sideWeight(Map<String, int> side, Map<String, int> values) {
    var sum = 0;
    for (final e in side.entries) {
      sum += values[e.key]! * e.value;
    }
    return sum;
  }
}

class WeightBalanceGenerator {
  WeightBalanceGenerator({Random? random}) : _rng = random ?? Random();

  final Random _rng;

  List<WeightBalancePuzzle> generateSession(
    List<WeightBalanceDifficulty> difficulties,
  ) =>
      [for (final d in difficulties) generate(d)];

  WeightBalancePuzzle generate(WeightBalanceDifficulty difficulty) {
    for (var attempt = 0; attempt < 80; attempt++) {
      final puzzle = switch (difficulty) {
        WeightBalanceDifficulty.easy => _easy(),
        WeightBalanceDifficulty.medium => _medium(),
        WeightBalanceDifficulty.hard => _hard(),
        WeightBalanceDifficulty.expert => _expert(),
      };
      if (puzzle != null) return puzzle;
    }
    return _fallback(difficulty);
  }

  WeightBalancePuzzle? _easy() {
    final symbols = _pickSymbols(2);
    final a = _rng.nextInt(8) + 2;
    final b = _rng.nextInt(8) + 2;
    final ea = symbols[0];
    final eb = symbols[1];
    final values = {ea: a, eb: b};

    final equations = [
      WeightEquation(
        left: {ea: 2},
        rightNumber: 2 * a,
        display: '$ea + $ea = ${2 * a}',
      ),
      WeightEquation(
        left: {ea: 1, eb: 1},
        rightNumber: a + b,
        display: '$ea + $eb = ${a + b}',
      ),
    ];

    return _finish(
      WeightBalanceDifficulty.easy,
      values,
      equations,
      _rng.nextBool() ? ea : eb,
    );
  }

  WeightBalancePuzzle? _medium() {
    final symbols = _pickSymbols(2);
    var a = _rng.nextInt(9) + 4; // 4–12
    var b = _rng.nextInt(6) + 2; // 2–7
    if (a <= b) a = b + 2;
    final ea = symbols[0];
    final eb = symbols[1];
    final values = {ea: a, eb: b};
    final sum = a + b;
    final diff = a - b;

    // Display: + and − pair.
    final display = [
      WeightEquation(
        left: {ea: 1, eb: 1},
        rightNumber: sum,
        display: '$ea + $eb = $sum',
      ),
      WeightEquation(
        left: {ea: 2},
        rightNumber: sum + diff,
        display: '$ea − $eb = $diff',
      ),
    ];

    // Solver: uniquely determines A,B via 2A = sum+diff, 2B = sum−diff.
    final solver = [
      WeightEquation(
        left: {ea: 2},
        rightNumber: sum + diff,
        display: '$ea + $ea = ${sum + diff}',
      ),
      WeightEquation(
        left: {eb: 2},
        rightNumber: sum - diff,
        display: '$eb + $eb = ${sum - diff}',
      ),
    ];

    return _finish(
      WeightBalanceDifficulty.medium,
      values,
      display,
      _rng.nextBool() ? ea : eb,
      solverEquations: solver,
    );
  }

  WeightBalancePuzzle? _hard() {
    final symbols = _pickSymbols(3);
    final a = _rng.nextInt(6) + 2; // 2–7
    final b = _rng.nextInt(5) + 2; // 2–6
    final c = _rng.nextInt(6) + 2; // 2–7
    final ea = symbols[0];
    final eb = symbols[1];
    final ec = symbols[2];
    final values = {ea: a, eb: b, ec: c};
    final prod = a * b;
    if (prod > 48) return null;

    // Additive encodings: b·A = A×B, 2·B, A+C.
    final solver = [
      WeightEquation(
        left: {ea: b},
        rightNumber: prod,
        display: '$ea × $eb = $prod',
      ),
      WeightEquation(
        left: {eb: 2},
        rightNumber: 2 * b,
        display: '$eb + $eb = ${2 * b}',
      ),
      WeightEquation(
        left: {ea: 1, ec: 1},
        rightNumber: a + c,
        display: '$ea + $ec = ${a + c}',
      ),
    ];

    final display = <WeightEquation>[
      WeightEquation(
        left: {ea: b},
        rightNumber: prod,
        display: '$ea × $eb = $prod',
      ),
      WeightEquation(
        left: {eb: 2},
        rightNumber: 2 * b,
        display: a % b == 0 && b > 1
            ? '$ea ÷ $eb = ${a ~/ b}'
            : '$eb + $eb = ${2 * b}',
      ),
      WeightEquation(
        left: {ea: 1, ec: 1},
        rightNumber: a + c,
        display: '$ea + $ec = ${a + c}',
      ),
    ];

    return _finish(
      WeightBalanceDifficulty.hard,
      values,
      display,
      symbols[_rng.nextInt(3)],
      solverEquations: solver,
    );
  }

  WeightBalancePuzzle? _expert() {
    final symbols = _pickSymbols(4);
    final weights = List.generate(4, (_) => _rng.nextInt(6) + 2);
    final values = {
      for (var i = 0; i < 4; i++) symbols[i]: weights[i],
    };
    final e0 = symbols[0];
    final e1 = symbols[1];
    final e2 = symbols[2];
    final e3 = symbols[3];
    final w0 = weights[0];
    final w1 = weights[1];
    final w2 = weights[2];
    final w3 = weights[3];

    final solver = [
      WeightEquation(
        left: {e0: 2},
        rightNumber: 2 * w0,
        display: '$e0 + $e0 = ${2 * w0}',
      ),
      WeightEquation(
        left: {e0: 1, e1: 1},
        rightNumber: w0 + w1,
        display: '$e0 + $e1 = ${w0 + w1}',
      ),
      WeightEquation(
        left: {e1: 1, e2: 1},
        rightNumber: w1 + w2,
        display: '$e1 + $e2 = ${w1 + w2}',
      ),
      WeightEquation(
        left: {e2: 1, e3: 1},
        rightNumber: w2 + w3,
        display: '$e2 + $e3 = ${w2 + w3}',
      ),
    ];

    final display = <WeightEquation>[
      solver[0],
      solver[1],
      if (w0 * w1 <= 42)
        WeightEquation(
          left: {e0: w1},
          rightNumber: w0 * w1,
          display: '$e0 × $e1 = ${w0 * w1}',
        )
      else
        solver[2],
      solver[3],
    ];

    return _finish(
      WeightBalanceDifficulty.expert,
      values,
      display,
      symbols[_rng.nextInt(4)],
      solverEquations: solver,
    );
  }

  WeightBalancePuzzle _fallback(WeightBalanceDifficulty d) {
    const ea = '🍎';
    const eb = '🍌';
    final values = {ea: 4, eb: 6};
    final eqs = [
      WeightEquation(
        left: const {ea: 2},
        rightNumber: 8,
        display: '🍎 + 🍎 = 8',
      ),
      WeightEquation(
        left: const {ea: 1, eb: 1},
        rightNumber: 10,
        display: '🍎 + 🍌 = 10',
      ),
    ];
    return WeightBalancePuzzle(
      difficulty: d,
      values: values,
      equations: eqs,
      askEmoji: eb,
      answer: 6,
      choices: _mcqChoices(6), // daily sample fallback; real daily uses generator
    );
  }

  WeightBalancePuzzle? _finish(
    WeightBalanceDifficulty difficulty,
    Map<String, int> values,
    List<WeightEquation> displayEquations,
    String askEmoji, {
    List<WeightEquation>? solverEquations,
  }) {
    final answer = values[askEmoji];
    if (answer == null) return null;

    final solved = WeightBalanceSolver.solveUnique(
      unknowns: values.keys.toList(),
      equations: solverEquations ?? displayEquations,
      askEmoji: askEmoji,
      groundTruth: values,
    );
    if (solved != answer) return null;

    return WeightBalancePuzzle(
      difficulty: difficulty,
      values: values,
      equations: displayEquations,
      askEmoji: askEmoji,
      answer: answer,
      choices: _mcqChoices(answer),
      solverEquations: solverEquations,
    );
  }

  List<int> _mcqChoices(int answer) {
    final set = <int>{answer};
    var guard = 0;
    while (set.length < 4 && guard < 40) {
      guard++;
      final delta = _rng.nextInt(6) + 1;
      final v = answer + (_rng.nextBool() ? delta : -delta);
      if (v >= 1 && v <= 30) set.add(v);
    }
    while (set.length < 4) {
      set.add(answer + set.length + 1);
    }
    final list = set.toList()..shuffle(_rng);
    return list;
  }

  List<String> _pickSymbols(int count) {
    final pool = List<String>.from(WeightBalanceConfig.emojis)..shuffle(_rng);
    return pool.take(count).toList();
  }
}
