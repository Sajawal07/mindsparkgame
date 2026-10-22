import '../models/iap/bundle_category.dart';
import '../models/iap/currency_bundle.dart';
import '../models/iap/promo_tag.dart';

/// All IAP bundles. Centralized product-to-coin mappings for Google Play consumable products.
abstract final class IapCatalog {
  static const String productIdPrefix = 'com.mindspark.iap';

  /// Centralized mapping of Google Play Product IDs to coin amounts.
  static const Map<String, int> coinPackages = {
    'coins_500': 500,
    'coins_1000': 1000,
    'coins_1500': 1500,
    'coins_2000': 2000,
    'coins_5000': 5000,
  };

  /// Returns the coins granted for a given product ID, or 0 if not a coin product.
  static int coinsForProduct(String productId) => coinPackages[productId] ?? 0;

  /// Returns whether a product ID is a consumable coin product.
  static bool isCoinPackage(String productId) => coinPackages.containsKey(productId);

  static const List<CurrencyBundle> all = [
    ...coinBundles,
    ...arenaPointBundles,
    ...valuePacks,
    ...featuredBundles,
  ];

  static const coinBundles = [
    CurrencyBundle(
      productId: 'coins_500',
      name: 'Starter Pouch (500 Coins)',
      description: 'Rs 199 • Quick boost for clues and hints',
      category: BundleCategory.coins,
      displayPrice: '\$0.79',
      coins: 500,
      bonusPercent: 0,
      sortOrder: 1,
    ),
    CurrencyBundle(
      productId: 'coins_1000',
      name: 'Solver Bag (1,000 Coins)',
      description: 'Rs 389 • Great for active puzzle solvers',
      category: BundleCategory.coins,
      displayPrice: '\$1.39',
      coins: 1000,
      bonusPercent: 10,
      promoTag: PromoTag.popular,
      sortOrder: 2,
    ),
    CurrencyBundle(
      productId: 'coins_1500',
      name: 'Mind Box (1,500 Coins)',
      description: 'Rs 590 • Solid supply for daily puzzles',
      category: BundleCategory.coins,
      displayPrice: '\$2.09',
      coins: 1500,
      bonusPercent: 20,
      sortOrder: 3,
    ),
    CurrencyBundle(
      productId: 'coins_2000',
      name: 'Brain Chest (2,000 Coins)',
      description: 'Rs 790 • Power-ups, themes & avatars',
      category: BundleCategory.coins,
      displayPrice: '\$2.79',
      coins: 2000,
      bonusPercent: 30,
      promoTag: PromoTag.bestValue,
      sortOrder: 4,
    ),
    CurrencyBundle(
      productId: 'coins_5000',
      name: 'Master Vault (5,000 Coins)',
      description: 'Rs 999 • Ultimate value for all cosmetics',
      category: BundleCategory.coins,
      displayPrice: '\$3.59',
      coins: 5000,
      bonusPercent: 50,
      promoTag: PromoTag.featured,
      sortOrder: 5,
    ),
  ];

  static const arenaPointBundles = [
    CurrencyBundle(
      productId: '$productIdPrefix.ap.small',
      name: 'Small AP Pack',
      description: 'Enter the Arena in style',
      category: BundleCategory.arenaPoints,
      displayPrice: '\$1.99',
      arenaPoints: 150,
      sortOrder: 10,
    ),
    CurrencyBundle(
      productId: '$productIdPrefix.ap.medium',
      name: 'Medium AP Pack',
      description: 'Unlock arena cosmetics faster',
      category: BundleCategory.arenaPoints,
      displayPrice: '\$4.99',
      arenaPoints: 450,
      bonusPercent: 15,
      promoTag: PromoTag.popular,
      sortOrder: 11,
    ),
    CurrencyBundle(
      productId: '$productIdPrefix.ap.large',
      name: 'Large AP Pack',
      description: 'Dominate the Arena store',
      category: BundleCategory.arenaPoints,
      displayPrice: '\$9.99',
      arenaPoints: 1100,
      bonusPercent: 30,
      promoTag: PromoTag.bestValue,
      sortOrder: 12,
    ),
    CurrencyBundle(
      productId: '$productIdPrefix.ap.champion',
      name: 'Champion Pack',
      description: 'Elite arena progression bundle',
      category: BundleCategory.arenaPoints,
      displayPrice: '\$14.99',
      arenaPoints: 2000,
      bonusPercent: 45,
      promoTag: PromoTag.featured,
      sortOrder: 13,
    ),
  ];

  static const valuePacks = [
    CurrencyBundle(
      productId: '$productIdPrefix.value.dual',
      name: 'Brain & Battle Pack',
      description: 'Coins + Arena Points combo',
      category: BundleCategory.valuePack,
      displayPrice: '\$7.99',
      coins: 4000,
      arenaPoints: 400,
      bonusPercent: 25,
      promoTag: PromoTag.bonus,
      sortOrder: 20,
    ),
    CurrencyBundle(
      productId: '$productIdPrefix.value.pro',
      name: 'Pro Trainer Pack',
      description: 'Everything you need to progress',
      category: BundleCategory.valuePack,
      displayPrice: '\$12.99',
      coins: 7000,
      arenaPoints: 750,
      bonusPercent: 40,
      promoTag: PromoTag.bestValue,
      sortOrder: 21,
    ),
  ];

  static const featuredBundles = [
    CurrencyBundle(
      productId: '$productIdPrefix.featured.welcome',
      name: 'Welcome Offer',
      description: 'One-time new player bundle',
      category: BundleCategory.limitedOffer,
      displayPrice: '\$3.99',
      coins: 2500,
      arenaPoints: 200,
      bonusPercent: 60,
      promoTag: PromoTag.limitedTime,
      sortOrder: 30,
    ),
    CurrencyBundle(
      productId: '$productIdPrefix.featured.mega',
      name: 'Mega Value Bundle',
      description: 'Featured seasonal offer',
      category: BundleCategory.featured,
      displayPrice: '\$24.99',
      coins: 25000,
      arenaPoints: 1500,
      bonusPercent: 55,
      promoTag: PromoTag.featured,
      sortOrder: 31,
    ),
  ];

  static CurrencyBundle? byProductId(String id) {
    for (final b in all) {
      if (b.productId == id) return b;
    }
    return null;
  }

  static List<CurrencyBundle> byCategory(BundleCategory category) {
    return all.where((b) => b.category == category).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  static List<BundleCategory> get shopTabs => [
        BundleCategory.featured,
        BundleCategory.coins,
        BundleCategory.arenaPoints,
        BundleCategory.valuePack,
        BundleCategory.limitedOffer,
      ];
}
