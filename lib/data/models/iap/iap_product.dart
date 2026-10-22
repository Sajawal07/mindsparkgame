import 'currency_bundle.dart';

/// Store-facing product metadata (price comes from billing in production).
class IapProduct {
  const IapProduct({
    required this.bundle,
    required this.displayPrice,
    this.isAvailable = true,
  });

  final CurrencyBundle bundle;
  final String displayPrice;
  final bool isAvailable;
}
