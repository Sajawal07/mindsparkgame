/// Centralized feature flags for MindSpark.
abstract final class AppFeatures {
  /// Toggle to enable / disable In-App Purchases (Real-money Coin Shop).
  ///
  /// Currently `false` for initial Google Play Store launch.
  /// When Firebase Blaze and Google Play Billing merchant accounts are configured,
  /// switch this to `true` to re-enable the Currency Shop.
  static const bool enableInAppPurchases = false;
}
