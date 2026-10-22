import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/game_providers.dart';
import '../../shared/widgets/mindspark_loading_indicator.dart';

/// Shows branding while [GameState.load] runs. Navigation after load is
/// handled by [appRouterProvider] redirect (not manual context.go).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLoad());
  }

  Future<void> _startLoad() async {
    await ref.read(gameStateProvider).load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.splashLogo,
              width: 260,
              height: 260,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.psychology,
                size: 100,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.tagline,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            const MindSparkLoadingIndicator(size: 104),
          ],
        ),
      ),
    );
  }
}
