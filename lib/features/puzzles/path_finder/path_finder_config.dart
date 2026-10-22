import 'package:flutter/material.dart';

/// Difficulty, scoring, and neon palette for Path Finder.
abstract final class PathFinderConfig {
  static const maxScore = 300;
  static const completionBase = 180;
  static const mistakePenalty = 25;
  static const maxMistakesBeforeZeroBonus = 6;

  /// Practice / level sizes: 5 → 8 → 12 → 15 (skip 20 on mobile).
  static const sizeEasy = 5;
  static const sizeMedium = 8;
  static const sizeHard = 12;
  static const sizeExpert = 15;

  /// Arena: one ~10×10 maze with a countdown.
  static const arenaGridSize = 10;
  static const arenaTimeSeconds = 50;

  /// Soft time budgets (seconds) used for stars & time bonus outside arena.
  static const timeBudgetEasy = 45;
  static const timeBudgetMedium = 60;
  static const timeBudgetHard = 90;
  static const timeBudgetExpert = 120;

  // ── Neon palette ──────────────────────────────────────────────────────────
  static const neonCyan = Color(0xFF00F5FF);
  static const neonMagenta = Color(0xFFFF2BD6);
  static const neonPurple = Color(0xFF7C4DFF);
  static const neonBgTop = Color(0xFF050816);
  static const neonBgBottom = Color(0xFF0A0520);
  static const wallFill = Color(0xFF12162B);
  static const pathFill = Color(0xFF1A2140);
  static const classicWall = Color(0xFF2A2A32);
  static const classicPath = Color(0xFFE8E4D8);
  static const classicAccent = Color(0xFF3D5A80);

  static int gridSizeForLevel(int level) {
    if (level >= 40) return sizeExpert;
    if (level >= 22) return sizeHard;
    if (level >= 10) return sizeMedium;
    return sizeEasy;
  }

  static int timeBudgetForSize(int size) {
    if (size >= sizeExpert) return timeBudgetExpert;
    if (size >= sizeHard) return timeBudgetHard;
    if (size >= sizeMedium) return timeBudgetMedium;
    return timeBudgetEasy;
  }

  /// Completion + time bonus − mistakes, clamped 0–300.
  static int computeScore({
    required bool completed,
    required int elapsedSeconds,
    required int timeLimitSeconds,
    required int mistakes,
  }) {
    if (!completed) {
      // Partial credit: small consolation based on progress is handled by caller
      // via [partialProgress]; here unfinished = mistakes-only floor.
      return (40 - mistakes * mistakePenalty).clamp(0, maxScore);
    }

    final remaining = (timeLimitSeconds - elapsedSeconds).clamp(0, timeLimitSeconds);
    final timeBonus = timeLimitSeconds <= 0
        ? 0
        : ((remaining / timeLimitSeconds) * 120).round();
    final penalty = mistakes * mistakePenalty;
    return (completionBase + timeBonus - penalty).clamp(0, maxScore);
  }

  /// Stars by speed thresholds (fraction of time budget used).
  static int starsFor({
    required bool completed,
    required int elapsedSeconds,
    required int timeLimitSeconds,
  }) {
    if (!completed) return 0;
    final limit = timeLimitSeconds <= 0 ? 1 : timeLimitSeconds;
    final ratio = elapsedSeconds / limit;
    if (ratio <= 0.45) return 3;
    if (ratio <= 0.75) return 2;
    return 1;
  }

  static String rankFor(int score) {
    if (score >= 260) return 'MASTER';
    if (score >= 210) return 'DIAMOND';
    if (score >= 160) return 'GOLD';
    if (score >= 110) return 'SILVER';
    return 'BRONZE';
  }
}
