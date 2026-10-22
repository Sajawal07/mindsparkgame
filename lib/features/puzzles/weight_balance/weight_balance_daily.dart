import 'dart:math';

import 'package:intl/intl.dart';

import '../../../data/services/storage_service.dart';
import 'weight_balance_config.dart';
import 'weight_balance_puzzle.dart';

/// Seeded daily challenge helper — one fixed hard puzzle per local day.
abstract final class WeightBalanceDaily {
  static const storageKey = 'weightBalanceDailyCompleted';

  static String dateKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    return DateFormat('yyyyMMdd').format(d);
  }

  static int seedForDate([DateTime? now]) => int.parse(dateKey(now));

  /// Deterministic hard puzzle for today (local midnight boundary).
  static WeightBalancePuzzle todaysPuzzle([DateTime? now]) {
    final rng = Random(seedForDate(now));
    return WeightBalanceGenerator(random: rng)
        .generate(WeightBalanceDifficulty.hard);
  }

  static bool isCompletedToday([DateTime? now]) {
    final saved =
        StorageService.instance.getSettingString(storageKey);
    return saved == dateKey(now);
  }

  static Future<void> markCompletedToday([DateTime? now]) {
    return StorageService.instance
        .setSettingString(storageKey, dateKey(now));
  }
}
