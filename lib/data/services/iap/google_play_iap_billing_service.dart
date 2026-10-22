import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;

import '../../iap/iap_catalog.dart';
import '../../models/iap/currency_bundle.dart';
import '../../models/iap/iap_product.dart';
import '../../models/iap/purchase_result.dart';
import '../coin_manager.dart';
import '../storage_service.dart';
import 'iap_billing_service.dart';

/// Official Google Play In-App Purchase implementation using [InAppPurchase].
/// Handles consumable one-time products, localized store pricing, and
/// persistent idempotent transaction processing to prevent double-crediting.
class GooglePlayIapBillingService implements IapBillingService {
  GooglePlayIapBillingService({
    iap.InAppPurchase? inAppPurchase,
    CoinManager? coinManager,
    Future<void> Function(CurrencyBundle bundle)? onBundlePurchased,
  })  : _inAppPurchase = inAppPurchase ?? iap.InAppPurchase.instance,
        _coinManager = coinManager,
        _onBundlePurchased = onBundlePurchased;

  final iap.InAppPurchase _inAppPurchase;
  CoinManager? _coinManager;
  final Future<void> Function(CurrencyBundle bundle)? _onBundlePurchased;

  StreamSubscription<List<iap.PurchaseDetails>>? _subscription;
  final Map<String, iap.ProductDetails> _productDetailsMap = {};
  final Map<String, Completer<PurchaseResult>> _pendingCompleters = {};
  bool _initialized = false;
  bool _isAvailable = false;

  void setCoinManager(CoinManager manager) {
    _coinManager = manager;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (_isAvailable) {
        _subscription = _inAppPurchase.purchaseStream.listen(
          _handlePurchaseUpdates,
          onDone: () => _subscription?.cancel(),
          onError: (error) {
            debugPrint('GooglePlayIAP purchaseStream error: $error');
          },
        );
      }
    } catch (e) {
      debugPrint('GooglePlayIAP initialization error: $e');
      _isAvailable = false;
    }
    _initialized = true;
  }

  @override
  Future<List<IapProduct>> fetchProducts() async {
    if (!_initialized) await initialize();

    final allProductIds = IapCatalog.all.map((b) => b.productId).toSet();

    if (!_isAvailable) {
      // Offline or Google Play Billing not available on device
      return IapCatalog.all
          .map((b) => IapProduct(
                bundle: b,
                displayPrice: b.displayPrice,
                isAvailable: false,
              ))
          .toList();
    }

    try {
      final response =
          await _inAppPurchase.queryProductDetails(allProductIds);

      if (response.error != null) {
        debugPrint('GooglePlayIAP queryProductDetails error: ${response.error}');
      }

      for (final detail in response.productDetails) {
        _productDetailsMap[detail.id] = detail;
      }

      return IapCatalog.all.map((b) {
        final detail = _productDetailsMap[b.productId];
        return IapProduct(
          bundle: b,
          // Never hardcode: use real localized price from Google Play if available
          displayPrice: detail?.price ?? b.displayPrice,
          isAvailable: detail != null,
        );
      }).toList();
    } catch (e) {
      debugPrint('GooglePlayIAP fetchProducts error: $e');
      return IapCatalog.all
          .map((b) => IapProduct(
                bundle: b,
                displayPrice: b.displayPrice,
                isAvailable: false,
              ))
          .toList();
    }
  }

  @override
  Future<PurchaseResult> purchase(String productId) async {
    if (!_initialized) await initialize();

    if (!_isAvailable) {
      return PurchaseResult(
        status: PurchaseStatus.failed,
        productId: productId,
        message: 'Google Play Billing is unavailable. Please check your network.',
      );
    }

    final productDetails = _productDetailsMap[productId];
    if (productDetails == null) {
      // Attempt to fetch once more if not in cache
      final response = await _inAppPurchase.queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        return PurchaseResult(
          status: PurchaseStatus.failed,
          productId: productId,
          message: 'Product unavailable on Google Play Console ($productId).',
        );
      }
      _productDetailsMap[productId] = response.productDetails.first;
    }

    final details = _productDetailsMap[productId]!;
    final purchaseParam = iap.PurchaseParam(productDetails: details);

    // Cancel any existing pending completer for this product
    _pendingCompleters[productId]?.complete(
      const PurchaseResult(
        status: PurchaseStatus.cancelled,
        message: 'Superseded by new purchase attempt',
      ),
    );

    final completer = Completer<PurchaseResult>();
    _pendingCompleters[productId] = completer;

    try {
      // Consumable purchase: repeatable, not a subscription
      final initiated = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false, // We consume after safely crediting coins
      );

      if (!initiated) {
        _pendingCompleters.remove(productId);
        return PurchaseResult(
          status: PurchaseStatus.failed,
          productId: productId,
          message: 'Could not initiate purchase with Google Play.',
        );
      }
    } catch (e) {
      _pendingCompleters.remove(productId);
      return PurchaseResult(
        status: PurchaseStatus.failed,
        productId: productId,
        message: 'Error initiating purchase: $e',
      );
    }

    // Safety timeout after 90 seconds
    return completer.future.timeout(
      const Duration(seconds: 90),
      onTimeout: () {
        _pendingCompleters.remove(productId);
        return PurchaseResult(
          status: PurchaseStatus.cancelled,
          productId: productId,
          message: 'Purchase timed out.',
        );
      },
    );
  }

  @override
  Future<List<PurchaseResult>> restorePurchases() async {
    if (!_initialized) await initialize();
    if (!_isAvailable) return const [];
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('GooglePlayIAP restorePurchases error: $e');
    }
    return const [];
  }

  Future<void> _handlePurchaseUpdates(List<iap.PurchaseDetails> purchases) async {
    for (final purchaseDetails in purchases) {
      final productId = purchaseDetails.productID;

      switch (purchaseDetails.status) {
        case iap.PurchaseStatus.pending:
          debugPrint('GooglePlayIAP: purchase pending for $productId');
          break;

        case iap.PurchaseStatus.error:
          debugPrint('GooglePlayIAP: purchase error: ${purchaseDetails.error}');
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
          _resolveCompleter(
            productId,
            PurchaseResult(
              status: PurchaseStatus.failed,
              productId: productId,
              message: purchaseDetails.error?.message ?? 'Purchase failed',
            ),
          );
          break;

        case iap.PurchaseStatus.canceled:
          debugPrint('GooglePlayIAP: purchase cancelled by user for $productId');
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
          _resolveCompleter(
            productId,
            PurchaseResult(
              status: PurchaseStatus.cancelled,
              productId: productId,
              message: 'Purchase was cancelled',
            ),
          );
          break;

        case iap.PurchaseStatus.purchased:
        case iap.PurchaseStatus.restored:
          await _processSafePurchase(purchaseDetails);
          break;
      }
    }
  }

  /// Validates transaction idempotency, awards coins, and consumes the purchase.
  Future<void> _processSafePurchase(iap.PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final bundle = IapCatalog.byProductId(productId);

    // Identify unique transaction token / order ID
    final transactionId = (purchaseDetails.purchaseID != null &&
            purchaseDetails.purchaseID!.trim().isNotEmpty)
        ? purchaseDetails.purchaseID!.trim()
        : purchaseDetails.verificationData.serverVerificationData.trim();

    // ── IDEMPOTENCY CHECK (PREVENT DOUBLE CREDITING) ────────────────────────
    final alreadyProcessed =
        StorageService.instance.isPurchaseProcessed(transactionId);

    if (alreadyProcessed) {
      debugPrint('GooglePlayIAP: Transaction $transactionId already processed. Skipping duplicate grant.');
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
      _resolveCompleter(
        productId,
        PurchaseResult(
          status: PurchaseStatus.success,
          productId: productId,
          bundle: bundle,
          transactionId: transactionId,
          message: 'Purchase already credited.',
        ),
      );
      return;
    }

    // ── MARK TRANSACTION PROCESSED ─────────────────────────────────────────
    await StorageService.instance.markPurchaseProcessed(transactionId);

    // ── CREDIT COINS SAFELY ON-DEVICE ───────────────────────────────────────
    final coinAmount = IapCatalog.coinsForProduct(productId);
    if (coinAmount > 0 && _coinManager != null) {
      await _coinManager!.addCoins(coinAmount);
    } else if (bundle != null) {
      if (_onBundlePurchased != null) {
        await _onBundlePurchased(bundle);
      } else if (bundle.coins > 0 && _coinManager != null) {
        await _coinManager!.addCoins(bundle.coins);
      }
    }

    // ── CONSUME PURCHASE SO IT CAN BE BOUGHT AGAIN ─────────────────────────
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }

    _resolveCompleter(
      productId,
      PurchaseResult(
        status: PurchaseStatus.success,
        productId: productId,
        bundle: bundle,
        transactionId: transactionId,
        message: 'Purchase successful',
      ),
    );
  }

  void _resolveCompleter(String productId, PurchaseResult result) {
    final completer = _pendingCompleters.remove(productId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    for (final completer in _pendingCompleters.values) {
      if (!completer.isCompleted) {
        completer.complete(
          const PurchaseResult(
            status: PurchaseStatus.cancelled,
            message: 'Billing service disposed',
          ),
        );
      }
    }
    _pendingCompleters.clear();
  }
}
