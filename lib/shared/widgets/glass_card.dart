import 'dart:ui';
import 'package:flutter/material.dart';

/// A lightweight glassmorphism container that works across all app themes.
///
/// Renders a blurred, semi-transparent panel with a subtle border —
/// keeping text and icons readable over any gradient background.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.blur = 12,
    this.opacity = 0.18,
    this.borderOpacity = 0.25,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  /// Override the glass tint color. Defaults to white.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Colors.white;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: tint.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: tint.withValues(alpha: borderOpacity),
              width: 1,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// A glassmorphism button wrapper — gives any button a glassy pill/rect shape.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = 12,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassCard(
        padding: padding,
        borderRadius: borderRadius,
        opacity: 0.20,
        borderOpacity: 0.30,
        child: child,
      ),
    );
  }
}
