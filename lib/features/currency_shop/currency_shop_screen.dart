import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../data/iap/iap_catalog.dart';
import '../../data/models/iap/bundle_category.dart';
import '../../data/models/iap/currency_bundle.dart';
import '../../data/models/iap/purchase_result.dart';
import '../../data/providers/game_providers.dart';
import '../../data/providers/iap_providers.dart';
import '../../data/providers/network_provider.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/coin_manager.dart';
import '../../shared/widgets/coin_badge.dart';
import '../../shared/widgets/coin_icon.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/mindspark_loading_indicator.dart';
import '../../shared/widgets/network/no_internet_view.dart';
import '../../shared/widgets/network/turn_on_internet_dialog.dart';
import 'widgets/bundle_card.dart';

class CurrencyShopScreen extends ConsumerStatefulWidget {
  const CurrencyShopScreen({super.key});

  @override
  ConsumerState<CurrencyShopScreen> createState() => _CurrencyShopScreenState();
}

class _CurrencyShopScreenState extends ConsumerState<CurrencyShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String? _purchasingId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: IapCatalog.shopTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _purchase(CurrencyBundle bundle) async {
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      showTurnOnInternetDialog(context, featureName: 'Coin Shop');
      return;
    }
    if (_purchasingId != null) return;
    setState(() => _purchasingId = bundle.productId);
    AudioService.instance.playButtonTap();

    final billing = ref.read(iapBillingServiceProvider);
    final result = await billing.purchase(bundle.productId);

    if (!mounted) return;
    setState(() => _purchasingId = null);

    if (result.isSuccess && result.bundle != null) {
      // Coins/AP are credited safely and idempotently inside the billing service!
      await AudioService.instance.playSfx(Sfx.coin);
      if (!mounted) return;
      await _showSuccessDialog(
        result,
        result.bundle!.coins,
        result.bundle!.arenaPoints,
      );
    } else if (result.status == PurchaseStatus.cancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase cancelled.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Purchase failed. Please check internet connection and try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _restore() async {
    AudioService.instance.playButtonTap();
    final billing = ref.read(iapBillingServiceProvider);
    final restored = await billing.restorePurchases();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          restored.isEmpty
              ? 'No purchases to restore (currency packs are consumable).'
              : 'Restored ${restored.length} purchase(s).',
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(
    PurchaseResult result,
    int coins,
    int ap,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Purchase Complete!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.bundle?.name ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            if (coins > 0)
              Row(
                children: [
                  const CoinIcon(size: 20),
                  const SizedBox(width: 8),
                  Text('+$coins Coins', style: const TextStyle(color: AppColors.gold)),
                ],
              ),
            if (ap > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Image.asset(AppAssets.arenaPointsCurrency, width: 20, height: 20,
                      errorBuilder: (_, __, ___) =>
                          Image.asset(AppAssets.arenaPointsBadge, width: 20, height: 20)),
                  const SizedBox(width: 8),
                  Text('+$ap Arena Points', style: const TextStyle(color: AppColors.accent)),
                ],
              ),
            ],
            if (kUseMockIapBilling) ...[
              const SizedBox(height: 10),
              Text(
                'Mock purchase · ${result.transactionId ?? ''}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(gameStateProvider).save.player;
    final coinBalanceAsync = ref.watch(coinBalanceStreamProvider);
    final currentCoins = coinBalanceAsync.valueOrNull ?? player.coins;
    final productsAsync = ref.watch(iapProductsProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Currency Shop',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isOnline)
            TextButton(
              onPressed: _restore,
              child: const Text('Restore', style: TextStyle(color: Colors.white70)),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CoinBadge(coins: currentCoins),
          ),
        ],
        bottom: isOnline
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.08),
                      child: TabBar(
                        controller: _tabs,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: AppColors.gold,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        tabs: IapCatalog.shopTabs
                            .map((c) => Tab(text: c.displayName))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: isOnline
          ? Column(
              children: [
                _BalanceStrip(coins: currentCoins, arenaPoints: player.arenaPoints),
                Expanded(
                  child: productsAsync.when(
                    loading: () => const Center(
                child: MindSparkLoadingIndicator(size: 64),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 48, color: Colors.white38),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to connect to Google Play',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please check your internet connection. In-app purchases require access to Google Play Services.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(iapProductsProvider),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (products) {
                final priceMap = {
                  for (final p in products) p.bundle.productId: p.displayPrice,
                };
                final isOffline = products.isNotEmpty && products.every((p) => !p.isAvailable);

                return Column(
                  children: [
                    if (isOffline)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.wifi_off, size: 16, color: Colors.amberAccent),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Connecting to Google Play... Connect to internet to make purchases.',
                                style: TextStyle(color: Colors.amberAccent, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabs,
                        children: IapCatalog.shopTabs.map((category) {
                          final bundles = IapCatalog.byCategory(category);
                          if (bundles.isEmpty) {
                            return const Center(
                              child: Text('No offers right now',
                                  style: TextStyle(color: Colors.white54)),
                            );
                          }
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            children: [
                              if (category == BundleCategory.featured ||
                                  category == BundleCategory.limitedOffer)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    category == BundleCategory.limitedOffer
                                        ? 'Limited-time offers — grab them while they last!'
                                        : 'Hand-picked deals for serious brain trainers.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ...bundles.map(
                                (b) => BundleCard(
                                  bundle: b,
                                  displayPrice:
                                      priceMap[b.productId] ?? b.displayPrice,
                                  isPurchasing: _purchasingId == b.productId,
                                  onPurchase: () => _purchase(b),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      )
    : const NoInternetView(
        featureName: 'Coin Shop',
        customMessage: 'Coin purchases require an active internet connection to communicate with Google Play.',
      ),
    );
  }
}

class _BalanceStrip extends StatelessWidget {
  const _BalanceStrip({required this.coins, required this.arenaPoints});

  final int coins;
  final int arenaPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const CoinIcon(size: 22),
              const SizedBox(width: 8),
              Text('$coins', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(width: 1, height: 24, color: Colors.white24),
          Row(
            children: [
              Image.asset(
                AppAssets.arenaPointsCurrency,
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) =>
                    Image.asset(AppAssets.arenaPointsBadge, width: 22, height: 22),
              ),
              const SizedBox(width: 8),
              Text('$arenaPoints AP',
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
