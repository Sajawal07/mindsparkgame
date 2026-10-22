import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/store_item.dart';
import '../victory_flares/victory_flare.dart';
import 'store_item_preview.dart';

/// Thumbnail for store list rows. Tapping opens a full preview (view only).
class StoreItemThumbnail extends StatelessWidget {
  const StoreItemThumbnail({
    super.key,
    required this.item,
    this.size = 64,
    this.accentColor,
  });

  final StoreItem item;
  final double size;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final path = StoreItemAssets.resolvePath(item);
    final isFlare = item.category == StoreCategory.victoryFlair || item.id.startsWith('flair_');
    final canPreview = path != null || item.category == StoreCategory.theme || isFlare;

    final Widget contentWidget;
    if (isFlare) {
      contentWidget = VictoryFlare.thumbnailFromId(item.id);
    } else if (path != null) {
      contentWidget = Image.asset(
        path,
        width: size,
        height: size,
        fit: StoreItemAssets.fitFor(item.category, preview: false),
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _FallbackIcon(
          category: item.category,
          size: size,
          accentColor: accentColor,
        ),
      );
    } else if (item.category == StoreCategory.theme) {
      contentWidget = _DefaultThemeThumb(size: size);
    } else {
      contentWidget = _FallbackIcon(
        category: item.category,
        size: size,
        accentColor: accentColor,
      );
    }

    final thumb = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: StoreItemAssets.thumbBackground(item.category),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: contentWidget,
    );

    if (!canPreview) return thumb;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showStoreItemPreview(context, item),
        borderRadius: BorderRadius.circular(12),
        child: thumb,
      ),
    );
  }
}

class _DefaultThemeThumb extends StatelessWidget {
  const _DefaultThemeThumb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1730), Color(0xFF7C4DFF)],
        ),
      ),
      child: Icon(Icons.palette, color: Colors.white70, size: size * 0.45),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({
    required this.category,
    required this.size,
    this.accentColor,
  });

  final StoreCategory category;
  final double size;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final icon = switch (category) {
      StoreCategory.avatar => Icons.face_outlined,
      StoreCategory.frame => Icons.crop_square,
      StoreCategory.theme => Icons.palette_outlined,
      StoreCategory.powerUp => Icons.bolt_outlined,
      StoreCategory.title => Icons.military_tech_outlined,
      StoreCategory.victoryFlair => Icons.celebration_outlined,
    };

    return Container(
      width: size,
      height: size,
      color: Colors.white.withValues(alpha: 0.08),
      child: Icon(icon, color: accentColor ?? AppColors.primaryLight, size: size * 0.45),
    );
  }
}

abstract final class StoreItemAssets {
  static String? resolvePath(StoreItem item) => item.assetPath;

  static BoxFit fitFor(StoreCategory category, {required bool preview}) {
    return switch (category) {
      StoreCategory.theme => preview ? BoxFit.contain : BoxFit.cover,
      _ => BoxFit.contain,
    };
  }

  static Color thumbBackground(StoreCategory category) {
    return switch (category) {
      StoreCategory.theme => Colors.black.withValues(alpha: 0.2),
      StoreCategory.frame ||
      StoreCategory.avatar ||
      StoreCategory.title ||
      StoreCategory.victoryFlair =>
        const Color(0xFF2A2640),
      StoreCategory.powerUp => const Color(0xFF1E1B2E),
    };
  }

  static String? pathForPreview(StoreItem item) {
    return resolvePath(item);
  }
}
