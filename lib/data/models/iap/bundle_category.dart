enum BundleCategory {
  coins,
  arenaPoints,
  valuePack,
  featured,
  limitedOffer,
}

extension BundleCategoryX on BundleCategory {
  String get displayName => switch (this) {
        BundleCategory.coins => 'Coin Packs',
        BundleCategory.arenaPoints => 'Arena Points',
        BundleCategory.valuePack => 'Value Packs',
        BundleCategory.featured => 'Featured',
        BundleCategory.limitedOffer => 'Limited Offers',
      };
}
