/// Promotional badge shown on bundle cards.
enum PromoTag {
  none,
  popular,
  bestValue,
  featured,
  limitedTime,
  bonus,
}

extension PromoTagX on PromoTag {
  String? get label => switch (this) {
        PromoTag.none => null,
        PromoTag.popular => 'POPULAR',
        PromoTag.bestValue => 'BEST VALUE',
        PromoTag.featured => 'FEATURED',
        PromoTag.limitedTime => 'LIMITED',
        PromoTag.bonus => 'BONUS',
      };
}
