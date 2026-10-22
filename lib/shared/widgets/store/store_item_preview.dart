import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/store_item.dart';
import '../victory_flares/victory_flare.dart';
import 'store_item_image.dart';

/// Full-screen-style preview modal. View only — no purchase or equip.
Future<void> showStoreItemPreview(BuildContext context, StoreItem item) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close preview',
    barrierColor: Colors.black.withValues(alpha: 0.88),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, _, __) {
      return Center(
        child: _StoreItemPreviewSheet(item: item),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curve),
          child: child,
        ),
      );
    },
  );
}

class _StoreItemPreviewSheet extends StatelessWidget {
  const _StoreItemPreviewSheet({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    final path = StoreItemAssets.pathForPreview(item);
    final maxW = MediaQuery.sizeOf(context).width * 0.92;
    final maxH = MediaQuery.sizeOf(context).height * 0.72;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      item.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: _PreviewImage(
                        item: item,
                        assetPath: path,
                        maxWidth: maxW - 32,
                        maxHeight: maxH - 140,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap outside to close',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({
    required this.item,
    required this.assetPath,
    required this.maxWidth,
    required this.maxHeight,
  });

  final StoreItem item;
  final String? assetPath;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    if (item.category == StoreCategory.victoryFlair || item.id.startsWith('flair_')) {
      final type = VictoryFlareType.fromId(item.id) ?? VictoryFlareType.trainingBoost;
      return Container(
        width: maxWidth,
        height: maxHeight,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: VictoryFlare(
          type: type,
          loop: true,
          autoStart: true,
          intensity: 1.0,
        ),
      );
    }

    final transparentBg = item.category == StoreCategory.frame ||
        item.category == StoreCategory.avatar ||
        item.category == StoreCategory.title;

    if (assetPath == null) {
      return SizedBox(
        width: maxWidth,
        height: 200,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
      );
    }

    return Container(
      width: maxWidth,
      height: maxHeight,
      decoration: BoxDecoration(
        color: transparentBg
            ? Colors.transparent
            : Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InteractiveViewer(
        minScale: 0.8,
        maxScale: 3,
        child: Center(
          child: Image.asset(
            assetPath!,
            fit: StoreItemAssets.fitFor(item.category, preview: true),
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: AppColors.error,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
