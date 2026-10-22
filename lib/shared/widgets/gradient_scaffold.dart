import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/game_providers.dart';

import '../../data/models/store_item.dart';
import '../../core/theme/app_theme_palette.dart';

class GradientScaffold extends ConsumerWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(themePaletteProvider);
    final player = ref.watch(gameStateProvider.select((g) => g.save.player));
    final themeId = AppThemePalette.themeIdFromEquipped(player.equippedTheme);
    final themeItem = StoreCatalog.byId(themeId);

    return Scaffold(
      extendBodyBehindAppBar: appBar != null,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: palette.backgroundGradient,
          image: themeItem?.assetPath != null
              ? DecorationImage(
                  image: AssetImage(themeItem!.assetPath!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.5),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: SafeArea(child: body),
      ),
    );
  }
}
