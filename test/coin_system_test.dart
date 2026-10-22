import 'package:flutter_test/flutter_test.dart';
import 'package:mindspark/data/iap/iap_catalog.dart';
import 'package:mindspark/data/repositories/coin_repository.dart';
import 'package:mindspark/data/services/coin_manager.dart';

/// Fake storage service for testing without actual Hive platform binaries
class FakeStorageService {
  final Map<String, dynamic> data = {};

  Map<String, dynamic>? getPlayerData() => data['player'] != null
      ? Map<String, dynamic>.from(data['player'] as Map)
      : null;

  Future<void> savePlayerData(Map<String, dynamic> pData) async {
    data['player'] = Map<String, dynamic>.from(pData);
  }

  final Set<String> processedPurchases = {};

  bool isPurchaseProcessed(String id) => processedPurchases.contains(id);

  Future<void> markPurchaseProcessed(String id) async {
    processedPurchases.add(id);
  }
}

/// Fake in-memory CoinRepository for isolated CoinManager testing
class InMemoryCoinRepository implements CoinRepository {
  int _balance;
  InMemoryCoinRepository([this._balance = 0]);

  @override
  Future<int> getBalance() async => _balance;

  @override
  Future<int> addCoins(int amount) async {
    if (amount > 0) _balance += amount;
    return _balance;
  }

  @override
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0 || _balance < amount) return false;
    _balance -= amount;
    return true;
  }

  @override
  Future<bool> hasEnoughCoins(int amount) async {
    if (amount <= 0) return true;
    return _balance >= amount;
  }

  @override
  Stream<int> watchBalance() async* {
    yield _balance;
  }

  @override
  void dispose() {}
}

void main() {
  group('Coin Architecture & CoinManager Tests', () {
    late CoinRepository repo;
    late CoinManager manager;

    setUp(() {
      repo = InMemoryCoinRepository(0);
      manager = CoinManager(repo);
    });

    test('13. Initial coin balance is 0', () async {
      final balance = await manager.getBalance();
      expect(balance, 0);
    });

    test('14-15. Buy 100 coins -> balance increases by exactly 100', () async {
      final newBalance = await manager.addCoins(100);
      expect(newBalance, 100);
      expect(await manager.getBalance(), 100);
    });

    test('16-17. Buy 100 coins again -> balance increases again to 200', () async {
      await manager.addCoins(100);
      final newBalance = await manager.addCoins(100);
      expect(newBalance, 200);
      expect(await manager.getBalance(), 200);
    });

    test('18. Buy 500 coins -> balance increases by 500', () async {
      await manager.addCoins(100); // 100
      final newBalance = await manager.addCoins(500); // 600
      expect(newBalance, 600);
      expect(await manager.getBalance(), 600);
    });

    test('Spend coins when balance is sufficient', () async {
      await manager.addCoins(300);
      final success = await manager.spendCoins(100);
      expect(success, isTrue);
      expect(await manager.getBalance(), 200);
    });

    test('Spend coins fails when balance is insufficient', () async {
      await manager.addCoins(50);
      final success = await manager.spendCoins(100);
      expect(success, isFalse);
      expect(await manager.getBalance(), 50); // Unchanged
    });

    test('hasEnoughCoins checks correctness', () async {
      await manager.addCoins(250);
      expect(await manager.hasEnoughCoins(100), isTrue);
      expect(await manager.hasEnoughCoins(250), isTrue);
      expect(await manager.hasEnoughCoins(251), isFalse);
    });
  });

  group('IapCatalog Product Mapping Tests', () {
    test('Coin packages mapping is centralized', () {
      expect(IapCatalog.coinsForProduct('coins_500'), 500);
      expect(IapCatalog.coinsForProduct('coins_1000'), 1000);
      expect(IapCatalog.coinsForProduct('coins_1500'), 1500);
      expect(IapCatalog.coinsForProduct('coins_2000'), 2000);
      expect(IapCatalog.coinsForProduct('coins_5000'), 5000);
      expect(IapCatalog.isCoinPackage('coins_500'), isTrue);
      expect(IapCatalog.isCoinPackage('coins_1000'), isTrue);
      expect(IapCatalog.isCoinPackage('coins_1500'), isTrue);
      expect(IapCatalog.isCoinPackage('coins_2000'), isTrue);
      expect(IapCatalog.isCoinPackage('coins_5000'), isTrue);
      expect(IapCatalog.isCoinPackage('coins_100'), isFalse);
      expect(IapCatalog.isCoinPackage('invalid_product'), isFalse);
    });
  });

  group('Idempotency & Double Crediting Prevention Tests', () {
    test('24. Confirm same purchase transaction is never credited twice', () async {
      final fakeStorage = FakeStorageService();
      final coinRepo = InMemoryCoinRepository(0);
      final coinManager = CoinManager(coinRepo);

      const testTransactionId = 'GPA.1234-5678-9012-34567';
      const productId = 'coins_500';
      final coinAmount = IapCatalog.coinsForProduct(productId);

      // Helper simulating the billing service safe process
      Future<bool> processPurchase(String txId) async {
        if (fakeStorage.isPurchaseProcessed(txId)) {
          return false; // Prevent double crediting!
        }
        await fakeStorage.markPurchaseProcessed(txId);
        await coinManager.addCoins(coinAmount);
        return true;
      }

      // First time purchase arrives
      final firstResult = await processPurchase(testTransactionId);
      expect(firstResult, isTrue);
      expect(await coinManager.getBalance(), 500);

      // Replay of the exact same transaction ID (app restart, stream replay, screen restart)
      final secondResult = await processPurchase(testTransactionId);
      expect(secondResult, isFalse); // Blocked!
      expect(await coinManager.getBalance(), 500); // Balance remains 500, never 1000!

      // Third attempt
      final thirdResult = await processPurchase(testTransactionId);
      expect(thirdResult, isFalse);
      expect(await coinManager.getBalance(), 500);
    });
  });
}
