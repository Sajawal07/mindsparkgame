import 'package:flutter/material.dart';

/// A named color used by the Stroop (Color Brain) challenge.
class ColorOption {
  const ColorOption({required this.name, required this.color});

  final String name;
  final Color color;

  static const List<ColorOption> baseSet = [
    ColorOption(name: 'Red', color: Color(0xFFFF5252)),
    ColorOption(name: 'Blue', color: Color(0xFF448AFF)),
    ColorOption(name: 'Green', color: Color(0xFF69F0AE)),
    ColorOption(name: 'Yellow', color: Color(0xFFFFD740)),
    ColorOption(name: 'Orange', color: Color(0xFFFF9100)),
    ColorOption(name: 'Purple', color: Color(0xFFB388FF)),
    ColorOption(name: 'Pink', color: Color(0xFFFF80AB)),
    ColorOption(name: 'Cyan', color: Color(0xFF18FFFF)),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorOption && name == other.name && color == other.color;

  @override
  int get hashCode => Object.hash(name, color);
}
