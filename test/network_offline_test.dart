import 'package:flutter_test/flutter_test.dart';
import 'package:mindspark/data/iap/iap_catalog.dart';
import 'package:mindspark/data/services/network_service.dart';

void main() {
  group('NetworkService & Offline Gating Tests', () {
    final network = NetworkService.instance;

    tearDown(() {
      network.setTestOnlineOverride(null);
    });

    test('Test online override sets isOnline and notifies listeners', () async {
      network.setTestOnlineOverride(false);
      expect(network.isOnline, isFalse);

      final events = <bool>[];
      final sub = network.onConnectivityChanged.listen(events.add);

      network.setTestOnlineOverride(true);
      expect(network.isOnline, isTrue);

      network.setTestOnlineOverride(false);
      expect(network.isOnline, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();

      expect(events, contains(true));
      expect(events, contains(false));
    });

    test('IapCatalog coin tiers conform to PKR price specification', () {
      // 500 coins -> Rs 199 (~$0.79)
      expect(IapCatalog.coinsForProduct('coins_500'), 500);
      final p500 = IapCatalog.byProductId('coins_500');
      expect(p500, isNotNull);
      expect(p500!.displayPrice, contains('0.79'));
      expect(p500.description, contains('199'));

      // 1000 coins -> Rs 389 (~$1.39)
      expect(IapCatalog.coinsForProduct('coins_1000'), 1000);
      final p1000 = IapCatalog.byProductId('coins_1000');
      expect(p1000, isNotNull);
      expect(p1000!.displayPrice, contains('1.39'));
      expect(p1000.description, contains('389'));

      // 1500 coins -> Rs 590 (~$2.09)
      expect(IapCatalog.coinsForProduct('coins_1500'), 1500);
      final p1500 = IapCatalog.byProductId('coins_1500');
      expect(p1500, isNotNull);
      expect(p1500!.displayPrice, contains('2.09'));
      expect(p1500.description, contains('590'));

      // 2000 coins -> Rs 790 (~$2.79)
      expect(IapCatalog.coinsForProduct('coins_2000'), 2000);
      final p2000 = IapCatalog.byProductId('coins_2000');
      expect(p2000, isNotNull);
      expect(p2000!.displayPrice, contains('2.79'));
      expect(p2000.description, contains('790'));

      // 5000 coins -> Rs 999 (~$3.59)
      expect(IapCatalog.coinsForProduct('coins_5000'), 5000);
      final p5000 = IapCatalog.byProductId('coins_5000');
      expect(p5000, isNotNull);
      expect(p5000!.displayPrice, contains('3.59'));
      expect(p5000.description, contains('999'));

      // Old 100 and 2500 should no longer exist
      expect(IapCatalog.isCoinPackage('coins_100'), isFalse);
      expect(IapCatalog.isCoinPackage('coins_2500'), isFalse);
    });
  });
}
