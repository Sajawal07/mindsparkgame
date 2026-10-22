import 'bundle_category.dart';
import 'promo_tag.dart';

/// In-app purchase bundle — maps 1:1 to a Play Store / App Store product ID.
class CurrencyBundle {
  const CurrencyBundle({
    required this.productId,
    required this.name,
    required this.description,
    required this.category,
    required this.displayPrice,
    this.coins = 0,
    this.arenaPoints = 0,
    this.bonusPercent = 0,
    this.promoTag = PromoTag.none,
    this.sortOrder = 0,
    this.isSubscription = false,
  });

  /// Google Play / App Store product ID (replace with real IDs at launch).
  final String productId;
  final String name;
  final String description;
  final BundleCategory category;
  final String displayPrice;
  final int coins;
  final int arenaPoints;
  final int bonusPercent;
  final PromoTag promoTag;
  final int sortOrder;
  final bool isSubscription;

  bool get grantsCoins => coins > 0;
  bool get grantsArenaPoints => arenaPoints > 0;
  bool get isValuePack => grantsCoins && grantsArenaPoints;
}
