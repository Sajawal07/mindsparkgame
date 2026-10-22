import '../lib/data/models/word_ladder_data.dart';

void main() {
  for (final d in WordLadderDifficulty.values) {
    final list = WordLadderPuzzleCatalog.forDifficulty(d);
    print('${d.name}: ${list.length} puzzles');
    for (var i = 0; i < list.length; i++) {
      final p = list[i];
      final broken = WordLadderPuzzleCatalog.brokenStepIndex(p.correctPath);
      if (broken != null) {
        print('  FAIL #${i + 1} ${p.startWord}->${p.targetWord} step $broken');
      } else if (p.correctPath.length != d.rows) {
        print('  FAIL #${i + 1} length ${p.correctPath.length} != ${d.rows}');
      } else {
        print('  OK #${i + 1} ${p.startWord}->${p.targetWord}');
      }
    }
  }
}
