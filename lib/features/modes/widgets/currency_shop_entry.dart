import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/network_provider.dart';
import '../../../data/services/audio_service.dart';
import '../../../shared/widgets/network/turn_on_internet_dialog.dart';

/// Floating shop button — right edge of screen, aligned with brain score ring.
class FloatingCurrencyShopButton extends ConsumerWidget {
  const FloatingCurrencyShopButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isOnline) {
            showTurnOnInternetDialog(context, featureName: 'Coin Shop');
            return;
          }
          AudioService.instance.playButtonTap();
          context.push(AppRoutes.currencyShop);
        },
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.7),
                    AppColors.gold.withValues(alpha: 0.45),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(-2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOnline ? Icons.storefront : Icons.wifi_off_rounded,
                    color: isOnline ? Colors.white : Colors.amberAccent,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
