import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/iq_rank.dart';
import '../../data/providers/game_providers.dart';
import '../../shared/widgets/gradient_scaffold.dart';

class ShareResultScreen extends ConsumerStatefulWidget {
  const ShareResultScreen({super.key});

  @override
  ConsumerState<ShareResultScreen> createState() => _ShareResultScreenState();
}

class _ShareResultScreenState extends ConsumerState<ShareResultScreen> {
  final _cardKey = GlobalKey();

  Future<void> _share() async {
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final pngBytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/mindspark_result_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'I scored on MindSpark! ${AppStrings.tagline}',
    );

    if (ref.read(gameStateProvider).save.canClaimShareReward()) {
      final coins = await ref.read(gameStateProvider).claimShareReward();
      if (mounted && coins != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('+$coins coins for sharing today!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameStateProvider).save.todaySession;
    if (session == null || !session.isComplete) {
      return GradientScaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.puzzles),
            child: const Text('Complete today\'s session first'),
          ),
        ),
      );
    }

    final rank = IqRank.fromBrainScore(session.brainScore);
    final dateStr = DateFormat('MMMM d, yyyy').format(DateTime.now());
    final canReward = ref.watch(gameStateProvider).save.canClaimShareReward();

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Share Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            RepaintBoundary(
              key: _cardKey,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage(AppAssets.shareCardBackground),
                    fit: BoxFit.cover,
                  ),
                  color: AppColors.surface,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Image.asset(
                      AppAssets.splashLogo,
                      height: 48,
                      errorBuilder: (_, __, ___) => Text(
                        AppStrings.appName,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.tagline,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${session.brainScore}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 64,
                            color: AppColors.primaryLight,
                          ),
                    ),
                    const Text('Brain Score'),
                    const SizedBox(height: 12),
                    Text(
                      rank.displayName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(rank.comparison, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text(dateStr),
                    const SizedBox(height: 8),
                    const Text(
                      'Train your brain daily with MindSpark',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.share),
                label: const Text('Share to Social'),
              ),
            ),
            if (canReward)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Earn 25 coins (once per day)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              AppStrings.iqDisclaimer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
