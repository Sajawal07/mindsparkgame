import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';

/// Main game coin currency icon from project assets.
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.mainCoinCurrency,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(
        Icons.monetization_on,
        color: AppColors.gold,
        size: size,
      ),
    );
  }
}
