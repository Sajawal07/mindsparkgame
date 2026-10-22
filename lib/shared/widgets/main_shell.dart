import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers/game_providers.dart';
import '../../data/services/audio_service.dart';

import '../../data/providers/network_provider.dart';
import 'network/turn_on_internet_dialog.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    // Hide bottom nav on Daily so game islands use the same viewport as Practice.
    final showBottomNav = navigationShell.currentIndex != 1;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: showBottomNav
          ? NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                // Index 1 = Daily, Index 3 = Store: require internet
                if (!isOnline && index == 1) {
                  showTurnOnInternetDialog(context, featureName: 'Daily Challenge');
                  return;
                }
                if (!isOnline && index == 3) {
                  showTurnOnInternetDialog(context, featureName: 'Store');
                  return;
                }
                if (index != navigationShell.currentIndex) {
                  AudioService.instance.playPageChange();
                }
                navigationShell.goBranch(index);
                if (index == 0) {
                  ref.read(gameStateProvider).notifyHomeVisible();
                }
              },
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primary.withValues(alpha: 0.3),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view),
                  label: 'Modes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.extension_outlined),
                  selectedIcon: Icon(Icons.extension),
                  label: 'Daily',
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: 'Challenges',
                ),
                NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: 'Store',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}
