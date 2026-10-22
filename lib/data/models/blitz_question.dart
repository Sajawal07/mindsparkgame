import 'package:flutter/material.dart';

enum BlitzGameType {
  mathBlitz,
  wordSnap,
  patternIq,
  scienceSnap,
  focusFind,
}

extension BlitzGameTypeX on BlitzGameType {
  String get label => switch (this) {
        BlitzGameType.mathBlitz => 'Math Blitz',
        BlitzGameType.wordSnap => 'Word Snap',
        BlitzGameType.patternIq => 'Pattern IQ',
        BlitzGameType.scienceSnap => 'Science Snap',
        BlitzGameType.focusFind => 'Focus Find',
      };
}

/// Unified question model for the 60-second Blitz rotation.
class BlitzQuestion {
  const BlitzQuestion({
    required this.type,
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    this.sequence,
    this.gridIcons,
    this.gridColors,
    this.oddIndex,
  });

  final BlitzGameType type;
  final String prompt;
  final List<String> choices;
  final int correctIndex;
  final List<String>? sequence;
  final List<IconData>? gridIcons;
  final List<Color>? gridColors;
  final int? oddIndex;
}
