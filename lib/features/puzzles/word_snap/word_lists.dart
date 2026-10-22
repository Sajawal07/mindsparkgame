import 'dart:math';

import '../../../core/utils/level_config.dart';
import '../../../core/utils/practice_config.dart';

abstract final class WordLists {
  static const _easy = [
    'cat', 'dog', 'sun', 'red', 'fish', 'bird', 'tree', 'moon', 'hat', 'run',
  ];
  static const _medium = [
    'apple', 'bread', 'chair', 'cloud', 'grape', 'house', 'light', 'plant',
    'brain', 'spark', 'quick', 'logic', 'focus', 'train',
  ];
  static const _hard = [
    'planet', 'forest', 'energy', 'silver', 'garden', 'winter', 'ocean', 'music',
    'abstract', 'chemical', 'elegant', 'fragment', 'generous', 'mindful',
  ];
  static const _expert = [
    'algorithm', 'brilliant', 'cognitive', 'dimension', 'equilibrium',
    'hypothesis', 'philosophy', 'metaphorical', 'consciousness', 'extraordinary',
  ];

  static final _rng = Random();

  static List<String> wordsForSession({int count = 6, bool practice = false}) {
    if (practice) {
      return _practiceWords(count: PracticeConfig.wordSessionCount());
    }

    final pool = switch (LevelConfig.tier) {
      1 => _easy,
      2 => _medium,
      3 => _hard,
      4 => _hard,
      5 => _expert,
      _ => _expert,
    };
    final minLen = LevelConfig.wordMinLength;
    final maxLen = LevelConfig.wordMaxLength;
    final filtered =
        pool.where((w) => w.length >= minLen && w.length <= maxLen).toList();
    filtered.shuffle(_rng);
    return filtered.take(count).toList();
  }

  /// Mix short/long and easy/hard words every practice session.
  static List<String> _practiceWords({required int count}) {
    final picked = <String>[];

    void addFrom(List<String> pool, int min) {
      final shuffled = List<String>.from(pool)..shuffle(_rng);
      var added = 0;
      for (final w in shuffled) {
        if (picked.contains(w)) continue;
        picked.add(w);
        if (++added >= min) break;
      }
    }

    addFrom(_easy, 2);
    addFrom(_medium, 2);
    addFrom(_hard, 2);
    if (count > 6) addFrom(_expert, count - picked.length);

    final all = [..._easy, ..._medium, ..._hard, ..._expert];
    while (picked.length < count) {
      final w = all[_rng.nextInt(all.length)];
      if (!picked.contains(w)) picked.add(w);
    }
    picked.shuffle(_rng);
    return picked.take(count).toList();
  }
}
