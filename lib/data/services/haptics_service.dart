import 'package:flutter/services.dart';

/// Centralized haptics — no extra package required.
abstract final class HapticsService {
  static Future<void> correct() => HapticFeedback.lightImpact();

  static Future<void> levelUp() => HapticFeedback.mediumImpact();

  static Future<void> wrong() => HapticFeedback.vibrate();

  static Future<void> tap() => HapticFeedback.selectionClick();
}
