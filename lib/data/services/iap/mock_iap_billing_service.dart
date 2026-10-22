import 'dart:math';

import '../../iap/iap_catalog.dart';
import '../../models/iap/iap_product.dart';
import '../../models/iap/purchase_result.dart';
import 'iap_billing_service.dart';

/// Development billing — simulates purchase flow until Play Billing is wired.
class MockIapBillingService implements IapBillingService {
  bool _initialized = false;
  final _random = Random();

  @override
  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _initialized = true;
  }

  @override
  Future<List<IapProduct>> fetchProducts() async {
    if (!_initialized) await initialize();
    return IapCatalog.all
        .map(
          (b) => IapProduct(
            bundle: b,
            displayPrice: b.displayPrice,
          ),
        )
        .toList();
  }

  @override
  Future<PurchaseResult> purchase(String productId) async {
    if (!_initialized) await initialize();
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final bundle = IapCatalog.byProductId(productId);
    if (bundle == null) {
      return PurchaseResult(
        status: PurchaseStatus.failed,
        productId: productId,
        message: 'Product not found',
      );
    }

    return PurchaseResult(
      status: PurchaseStatus.success,
      productId: productId,
      bundle: bundle,
      transactionId: 'mock_tx_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}',
      message: 'Purchase successful',
    );
  }

  @override
  Future<List<PurchaseResult>> restorePurchases() async {
    if (!_initialized) await initialize();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // Consumable currency packs are not restored on real stores; subscriptions would be.
    return const [];
  }

  @override
  void dispose() {}
}
