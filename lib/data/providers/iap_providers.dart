import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/iap/iap_product.dart';
import '../services/coin_manager.dart';
import '../services/iap/google_play_iap_billing_service.dart';
import '../services/iap/iap_billing_service.dart';
import '../services/iap/mock_iap_billing_service.dart';
import 'game_providers.dart';

/// Set to `true` if you wish to run with mock billing instead of real Google Play Store.
const bool kUseMockIapBilling = false;

final iapBillingServiceProvider = Provider<IapBillingService>((ref) {
  if (kUseMockIapBilling) {
    return MockIapBillingService();
  }

  final coinManager = ref.watch(coinManagerProvider);
  final gameState = ref.watch(gameStateProvider);

  final service = GooglePlayIapBillingService(
    coinManager: coinManager,
    onBundlePurchased: (bundle) async {
      await gameState.grantCurrencyBundle(bundle);
    },
  );

  ref.onDispose(service.dispose);
  return service;
});

final iapProductsProvider = FutureProvider<List<IapProduct>>((ref) async {
  final billing = ref.watch(iapBillingServiceProvider);
  await billing.initialize();
  return billing.fetchProducts();
});
