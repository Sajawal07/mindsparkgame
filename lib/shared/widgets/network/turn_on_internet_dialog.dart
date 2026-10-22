import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/audio_service.dart';
import '../../../data/services/network_service.dart';

/// Shows a dialog prompting the user to turn on internet to access an online feature.
Future<bool> showTurnOnInternetDialog(
  BuildContext context, {
  String? featureName,
  String? customMessage,
}) async {
  AudioService.instance.playSfx(Sfx.softTap);

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _TurnOnInternetDialog(
      featureName: featureName,
      customMessage: customMessage,
    ),
  );

  return result ?? false;
}

/// Helper for quick SnackBar notification if dialog is not preferred.
void showTurnOnInternetSnackBar(BuildContext context, {String? featureName}) {
  final name = featureName != null ? ' to access $featureName' : '';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.amberAccent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Please turn on internet$name.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C2248),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.amberAccent, width: 1),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
}

class _TurnOnInternetDialog extends StatefulWidget {
  const _TurnOnInternetDialog({
    this.featureName,
    this.customMessage,
  });

  final String? featureName;
  final String? customMessage;

  @override
  State<_TurnOnInternetDialog> createState() => _TurnOnInternetDialogState();
}

class _TurnOnInternetDialogState extends State<_TurnOnInternetDialog> {
  bool _isChecking = false;

  String _getFeatureExplanation() {
    if (widget.customMessage != null) return widget.customMessage!;
    final name = widget.featureName?.toLowerCase() ?? '';
    if (name.contains('arena')) {
      return 'Arena Mode requires an active internet connection to update your battle ranking and leaderboard.';
    } else if (name.contains('leaderboard')) {
      return 'Leaderboard requires an internet connection to fetch real-time global player rankings.';
    } else if (name.contains('store') || name.contains('shop')) {
      return 'Stores require an active internet connection to browse items and process coin purchases.';
    } else if (name.contains('daily') || name.contains('challenge')) {
      return 'Daily Challenge requires internet to download today\'s puzzles and record your daily brain score.';
    } else if (name.contains('blitz')) {
      return 'Blitz Mode requires internet to record your high score and competitive multipliers.';
    }
    return 'This feature requires an active internet connection.\n\nOnly Practice Mode is available while offline.';
  }

  Future<void> _checkConnection() async {
    setState(() => _isChecking = true);
    final isOnline = await NetworkService.instance.checkInternet();
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (isOnline) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connected to the internet!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still offline. Please check your Wi-Fi or mobile data.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1633).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.12),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.amberAccent,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                const Text(
                  'Turn On Internet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  _getFeatureExplanation(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Offline Notice Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Practice Mode works 100% offline!',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // Retry Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isChecking ? null : _checkConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isChecking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          _isChecking ? 'Checking...' : 'Try Again',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Practice Mode Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          context.push(AppRoutes.practice);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Play Practice',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Cancel Text Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
