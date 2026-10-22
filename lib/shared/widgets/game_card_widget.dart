import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'glass_card.dart';

class GameCardWidget extends StatelessWidget {
  const GameCardWidget({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.surface,
    this.padding = const EdgeInsets.all(16.0),
    this.height,
    this.width,
  });

  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      color: backgroundColor,
      opacity: 0.4,
      borderOpacity: 0.5,
      child: SizedBox(
        height: height,
        width: width,
        child: child,
      ),
    );
  }
}
