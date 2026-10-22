import '../../models/iap/iap_product.dart';
import '../../models/iap/purchase_result.dart';

/// Billing abstraction — swap [MockIapBillingService] for Google Play Billing later.
abstract class IapBillingService {
  Future<void> initialize();
  Future<List<IapProduct>> fetchProducts();
  Future<PurchaseResult> purchase(String productId);
  Future<List<PurchaseResult>> restorePurchases();
  void dispose();
}
