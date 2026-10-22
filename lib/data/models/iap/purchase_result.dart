import 'currency_bundle.dart';

enum PurchaseStatus {
  success,
  cancelled,
  failed,
  pending,
  restored,
}

class PurchaseResult {
  const PurchaseResult({
    required this.status,
    this.productId,
    this.bundle,
    this.message,
    this.transactionId,
  });

  final PurchaseStatus status;
  final String? productId;
  final CurrencyBundle? bundle;
  final String? message;
  final String? transactionId;

  bool get isSuccess =>
      status == PurchaseStatus.success || status == PurchaseStatus.restored;
}
