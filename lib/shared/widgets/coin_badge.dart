import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'coin_icon.dart';

class CoinBadge extends StatelessWidget {
  const CoinBadge({
    super.key,
    required this.coins,
    this.compact = false,
  });

  final int coins;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const iconSize = 30.0;
    final hPad = compact ? 6.0 : 12.0;
    final vPad = compact ? 2.0 : 6.0;
    final fontSize = compact ? 12.0 : 16.0;
    final radius = compact ? 14.0 : 20.0;
    final gap = compact ? 3.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CoinIcon(size: iconSize),
          SizedBox(width: gap),
          Text(
            '$coins',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.gold,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
          ),
        ],
      ),
    );
  }
}
