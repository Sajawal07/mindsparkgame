import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/store_item.dart';
import '../../data/providers/game_providers.dart';
import '../../data/providers/network_provider.dart';
import '../../data/services/store_service.dart';
import '../../shared/widgets/coin_icon.dart';
import '../../shared/widgets/coin_badge.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/network/no_internet_view.dart';
import '../../shared/widgets/store/store_item_image.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _tabLabels = ['Themes', 'Frames', 'Power-Ups', 'Titles', 'Avatars'];
  static const _tabCategories = [
    StoreCategory.theme,
    StoreCategory.frame,
    StoreCategory.powerUp,
    StoreCategory.title,
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
        title: const Text(
          'Store',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CoinBadge(coins: player.coins),
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
                        indicatorColor: AppColors.primary,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
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
                  .map((cat) => _ItemList(category: cat))
                  .toList(),
            )
          : const NoInternetView(
              featureName: 'Store',
              customMessage: 'The Store requires an active internet connection to load catalog items and process coin purchases.',
            ),
    );
  }
}

// ─── Item list ───────────────────────────────────────────────────────────────

class _ItemList extends ConsumerWidget {
  const _ItemList({required this.category});
  final StoreCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(gameStateProvider).save.player;
    final items =
        StoreService().getItemsByCategory(category, CurrencyType.coins, player);

    if (items.isEmpty) {
      return const Center(
        child: Text('No items available', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) => _StoreItemCard(item: items[index]),
    );
  }
}

// ─── Item card ────────────────────────────────────────────────────────────────

class _StoreItemCard extends ConsumerWidget {
  const _StoreItemCard({required this.item});
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
    final stock = player.powerupInventory[item.id] ?? 0;
    final atMaxStock = item.maxStock != null && stock >= item.maxStock!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            StoreItemThumbnail(item: item, size: 64),
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
                  if (item.category == StoreCategory.powerUp) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Stock: $stock / ${item.maxStock ?? '∞'}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: atMaxStock ? AppColors.error : AppColors.gold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Action ──────────────────────────────────────────────────
            _ActionButton(
              item: item,
              owned: owned && item.category != StoreCategory.powerUp,
              equipped: equipped,
              locked: lockReason != null,
              atMaxStock: atMaxStock,
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
          'Spend ${item.cost} coins?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Buy')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final err = await ref.read(gameStateProvider).purchaseItem(item.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? '✓ Purchased ${item.name}!'),
        backgroundColor: err == null ? AppColors.success : AppColors.error,
      ),
    );
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.locked,
    required this.atMaxStock,
    required this.onBuy,
    required this.onEquip,
  });

  final StoreItem item;
  final bool owned;
  final bool equipped;
  final bool locked;
  final bool atMaxStock;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    // Locked — can't do anything
    if (locked) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.lock_outline,
            color: Colors.white38, size: 22),
      );
    }

    // Power-up buy flow
    if (item.category == StoreCategory.powerUp) {
      return _BuyButton(
        cost: item.cost,
        disabled: atMaxStock,
        onTap: atMaxStock ? null : onBuy,
        label: atMaxStock ? 'Full' : 'Buy',
      );
    }

    // Free default items
    if (item.cost == 0) {
      if (equipped) return _EquippedChip();
      return _EquipButton(onTap: onEquip);
    }

    if (equipped) return _EquippedChip();
    if (owned)   return _EquipButton(onTap: onEquip);

    return _BuyButton(cost: item.cost, onTap: onBuy);
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({
    required this.cost,
    required this.onTap,
    this.disabled = false,
    this.label = 'Buy',
  });
  final int cost;
  final VoidCallback? onTap;
  final bool disabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
                ),
          color: disabled ? Colors.white12 : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!disabled) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CoinIcon(size: 14),
                  const SizedBox(width: 2),
                  Text('$cost',
                      style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 2),
            ],
            Text(
              label,
              style: TextStyle(
                color: disabled ? Colors.white38 : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipButton extends StatelessWidget {
  const _EquipButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
}

class _EquippedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
      ),
      child: const Text(
        '✓ On',
        style: TextStyle(
            color: AppColors.success,
            fontSize: 12,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
