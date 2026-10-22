import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Compact difficulty pill shared across premium games.
class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({
    super.key,
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.45)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// Top HUD strip: level / score / timer placeholders for premium games.
class GameStatBar extends StatelessWidget {
  const GameStatBar({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children
          .map((w) => Expanded(child: Center(child: w)))
          .toList(),
    );
  }
}
