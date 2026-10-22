import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/network_service.dart';

/// Full-page or embedded placeholder widget displayed when an online-only
/// screen is accessed while the device is offline.
class NoInternetView extends ConsumerStatefulWidget {
  const NoInternetView({
    super.key,
    required this.featureName,
    this.customMessage,
    this.showPracticeOption = true,
    this.onRetry,
  });

  final String featureName;
  final String? customMessage;
  final bool showPracticeOption;
  final Future<void> Function()? onRetry;

  @override
  ConsumerState<NoInternetView> createState() => _NoInternetViewState();
}

class _NoInternetViewState extends ConsumerState<NoInternetView> {
  bool _isChecking = false;

  String get _description {
    if (widget.customMessage != null) return widget.customMessage!;
    final name = widget.featureName.toLowerCase();
    if (name.contains('arena store') || name.contains('store') || name.contains('shop')) {
      return '${widget.featureName} requires an active internet connection to load catalog items and process purchases.';
    } else if (name.contains('leaderboard')) {
      return 'Leaderboard requires an active internet connection to fetch real-time global player rankings.';
    } else if (name.contains('daily')) {
      return 'Daily Challenge requires internet to download today\'s puzzles and update your streak score.';
    } else if (name.contains('arena')) {
      return 'Arena Mode requires an active internet connection to participate in ranked matches.';
    } else if (name.contains('blitz')) {
      return 'Blitz Mode requires internet to submit high scores and sync leaderboards.';
    }
    return '${widget.featureName} requires an active internet connection.';
  }

  Future<void> _handleRetry() async {
    setState(() => _isChecking = true);
    if (widget.onRetry != null) {
      await widget.onRetry!();
    } else {
      await NetworkService.instance.checkInternet();
    }
    if (!mounted) return;
    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with soft amber glow
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withValues(alpha: 0.15),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.12),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: Colors.amberAccent,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Turn On Internet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              _description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Offline reminder card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Practice Mode is available offline anytime!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Retry Button
            SizedBox(
              width: 220,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _isChecking ? null : _handleRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                icon: _isChecking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  _isChecking ? 'Checking...' : 'Retry Connection',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),

            if (widget.showPracticeOption) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: 220,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.practice);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: BorderSide(
                      color: AppColors.success.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.sports_esports_outlined, size: 18),
                  label: const Text(
                    'Play Practice Mode',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
