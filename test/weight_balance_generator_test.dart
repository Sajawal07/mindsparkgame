import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mindspark/features/puzzles/weight_balance/weight_balance_config.dart';
import 'package:mindspark/features/puzzles/weight_balance/weight_balance_puzzle.dart';

void main() {
  test('generator always yields uniquely solvable puzzles', () {
    final g = WeightBalanceGenerator(random: Random(42));
    for (final d in WeightBalanceDifficulty.values) {
      for (var i = 0; i < 30; i++) {
        final p = g.generate(d);
        final solved = WeightBalanceSolver.solveUnique(
          unknowns: p.values.keys.toList(),
          equations: p.equationsForSolver,
          askEmoji: p.askEmoji,
          groundTruth: p.values,
        );
        expect(solved, p.answer, reason: '$d #$i ${p.equations.map((e) => e.display)}');
        if (d.useKeypad) {
          expect(p.choices, isNull);
        } else {
          expect(p.choices, hasLength(4));
          expect(p.choices, contains(p.answer));
        }
      }
    }
  });

  test('seeded generator is deterministic', () {
    final a = WeightBalanceGenerator(random: Random(20260723))
        .generate(WeightBalanceDifficulty.hard);
    final b = WeightBalanceGenerator(random: Random(20260723))
        .generate(WeightBalanceDifficulty.hard);
    expect(a.answer, b.answer);
    expect(a.askEmoji, b.askEmoji);
    expect(a.equations.map((e) => e.display).toList(),
        b.equations.map((e) => e.display).toList());
  });
}
