import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/iap/bundle_category.dart';
import '../../../data/models/iap/currency_bundle.dart';
import '../../../data/models/iap/promo_tag.dart';
import '../../../shared/widgets/coin_icon.dart';
import '../../../shared/widgets/mindspark_loading_indicator.dart';

class BundleCard extends StatelessWidget {
  const BundleCard({
    super.key,
    required this.bundle,
    required this.displayPrice,
    required this.onPurchase,
    this.isPurchasing = false,
  });

  final CurrencyBundle bundle;
  final String displayPrice;
  final VoidCallback onPurchase;
  final bool isPurchasing;

  @override
  Widget build(BuildContext context) {
    final tag = bundle.promoTag.label;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientFor(bundle),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _BundleArt(bundle: bundle),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bundle.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bundle.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _RewardRow(bundle: bundle),
                      if (bundle.bonusPercent > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          '+${bundle.bonusPercent}% bonus value',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _BuyButton(
                  price: displayPrice,
                  onTap: onPurchase,
                  loading: isPurchasing,
                ),
              ],
            ),
          ),
          if (tag != null)
            Positioned(
              top: 0,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _tagColor(bundle.promoTag),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Color> _gradientFor(CurrencyBundle bundle) {
    if (bundle.grantsCoins && bundle.grantsArenaPoints) {
      return [
        const Color(0xFF4A148C),
        const Color(0xFF1A237E),
      ];
    }
    if (bundle.grantsArenaPoints) {
      return [
        const Color(0xFF3E2723),
        const Color(0xFFBF360C).withValues(alpha: 0.85),
      ];
    }
    return [
      const Color(0xFF1A1730),
      const Color(0xFF4527A0),
    ];
  }

  Color _tagColor(PromoTag tag) => switch (tag) {
        PromoTag.bestValue => AppColors.success,
        PromoTag.popular => AppColors.primary,
        PromoTag.featured => AppColors.gold,
        PromoTag.limitedTime => AppColors.error,
        PromoTag.bonus => const Color(0xFF7C4DFF),
        PromoTag.none => Colors.grey,
      };
}

class _BundleArt extends StatelessWidget {
  const _BundleArt({required this.bundle});

  final CurrencyBundle bundle;

  @override
  Widget build(BuildContext context) {
    final bool both = bundle.grantsCoins && bundle.grantsArenaPoints;

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (both) ...[
            const Positioned(
              left: 4,
              bottom: 4,
              child: CoinIcon(size: 72),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: Image.asset(
                AppAssets.arenaPointsCurrency,
                width: 72,
                height: 72,
                errorBuilder: (_, __, ___) => Image.asset(
                  AppAssets.arenaPointsBadge,
                  width: 72,
                  height: 72,
                ),
              ),
            ),
          ] else if (bundle.grantsCoins) ...[
            const Center(
              child: CoinIcon(size: 96),
            ),
          ] else if (bundle.grantsArenaPoints) ...[
            Center(
              child: Image.asset(
                AppAssets.arenaPointsCurrency,
                width: 96,
                height: 96,
                errorBuilder: (_, __, ___) => Image.asset(
                  AppAssets.arenaPointsBadge,
                  width: 96,
                  height: 96,
                ),
              ),
            ),
          ],
          
          if (bundle.category == BundleCategory.featured ||
              bundle.category == BundleCategory.limitedOffer)
            const Positioned(
              top: 4,
              left: 4,
              child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 24),
            ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.bundle});

  final CurrencyBundle bundle;

  @override
  Widget build(BuildContext context) {
    final parts = <Widget>[];
    if (bundle.coins > 0) {
      parts.add(_chip('${bundle.coins} Coins', AppColors.gold));
    }
    if (bundle.arenaPoints > 0) {
      if (parts.isNotEmpty) parts.add(const SizedBox(width: 6));
      parts.add(_chip('${bundle.arenaPoints} AP', AppColors.accent));
    }
    return Wrap(spacing: 6, runSpacing: 4, children: parts);
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({
    required this.price,
    required this.onTap,
    required this.loading,
  });

  final String price;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: MindSparkLoadingIndicator(size: 22),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Buy',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
