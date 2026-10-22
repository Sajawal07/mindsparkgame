import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/store_item.dart';
import '../../data/providers/game_providers.dart';
import '../../data/providers/network_provider.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/store_service.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/network/no_internet_view.dart';
import '../../shared/widgets/store/store_item_image.dart';

class ArenaStoreScreen extends ConsumerStatefulWidget {
  const ArenaStoreScreen({super.key});

  @override
  ConsumerState<ArenaStoreScreen> createState() => _ArenaStoreScreenState();
}

class _ArenaStoreScreenState extends ConsumerState<ArenaStoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _tabLabels = ['Themes', 'Frames', 'Titles', 'Flairs', 'Avatars'];
  static const _tabCategories = [
    StoreCategory.theme,
    StoreCategory.frame,
    StoreCategory.title,
    StoreCategory.victoryFlair,
    StoreCategory.avatar,
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(gameStateProvider).save.player;
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
          'Arena Store',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Text(
                  '${player.arenaPoints}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 5),
                Image.asset(
                  AppAssets.arenaPointsBadge,
                  width: 22,
                  height: 22,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.shield, color: AppColors.gold, size: 22),
                ),
              ],
            ),
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
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        unselectedLabelStyle:
                            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: isOnline
          ? TabBarView(
              controller: _tabs,
              children: _tabCategories
                  .map((cat) => _ArenaItemList(category: cat))
                  .toList(),
            )
          : const NoInternetView(
              featureName: 'Arena Store',
              customMessage: 'The Arena Store requires an active internet connection to load arena items and synchronize your points.',
            ),
    );
  }
}

// ─── Item list ────────────────────────────────────────────────────────────────

class _ArenaItemList extends ConsumerWidget {
  const _ArenaItemList({required this.category});
  final StoreCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(gameStateProvider).save.player;
    final items =
        StoreService().getItemsByCategory(category, CurrencyType.arenaPoints, player);

    if (items.isEmpty) {
      return const Center(
        child: Text('No items available', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _ArenaStoreItemCard(item: items[index]),
    );
  }
}

// ─── Item card ────────────────────────────────────────────────────────────────

class _ArenaStoreItemCard extends ConsumerWidget {
  const _ArenaStoreItemCard({required this.item});
  final StoreItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player =
        ref.watch(gameStateProvider.select((g) => g.save.player));
    final unlockContext = ref.read(gameStateProvider).save.unlockContext;
    final svc = StoreService();

    final lockReason = svc.canUnlock(item, player, unlockContext);
    final owned = svc.isOwned(item, player);
    final equipped = svc.isEquipped(item, player);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            StoreItemThumbnail(
              item: item,
              size: 64,
              accentColor: AppColors.gold,
            ),
            const SizedBox(width: 12),

            // ── Info ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  if (lockReason != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 11, color: AppColors.error),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            lockReason,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Action ──────────────────────────────────────────────────
            _ArenaActionButton(
              item: item,
              owned: owned,
              equipped: equipped,
              locked: lockReason != null,
              onBuy: () => _confirmPurchase(context, ref),
              onEquip: () => _equip(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmPurchase(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1730),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Buy ${item.name}?',
            style: const TextStyle(color: Colors.white)),
        content: Text(
          'Spend ${item.cost} AP?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Buy', style: TextStyle(color: Colors.black))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    AudioService.instance.playButtonTap();
    final err = await ref.read(gameStateProvider).purchaseItem(item.id);
    if (!context.mounted) return;

    if (err == null) {
      await AudioService.instance.playSfx(Sfx.coin);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Purchased ${item.name}!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _equip(BuildContext context, WidgetRef ref) async {
    final err = await ref.read(gameStateProvider).equipItem(item.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? '✓ Equipped ${item.name}'),
        backgroundColor: err == null ? AppColors.success : AppColors.error,
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ArenaActionButton extends StatelessWidget {
  const _ArenaActionButton({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.locked,
    required this.onBuy,
    required this.onEquip,
  });

  final StoreItem item;
  final bool owned;
  final bool equipped;
  final bool locked;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    if (locked) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.lock_outline, color: Colors.white38, size: 22),
      );
    }
    if (equipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        child: const Text(
          '✓ On',
          style: TextStyle(
              color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      );
    }
    if (owned) {
      return GestureDetector(
        onTap: onEquip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white30),
          ),
          child: const Text(
            'Equip',
            style: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onBuy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield, color: Colors.white, size: 11),
                const SizedBox(width: 2),
                Text(
                  '${item.cost}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Buy',
              style: TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
