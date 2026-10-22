import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/audio_service.dart';

class LevelUpDialog extends StatefulWidget {
  const LevelUpDialog({super.key, required this.newLevel});

  final int newLevel;

  static Future<void> show(BuildContext context, int newLevel) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => LevelUpDialog(newLevel: newLevel),
    );
  }

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _barCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _barAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    // ── Scale-in pop animation ──
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleCtrl,
      curve: Curves.elasticOut,
    );

    // ── XP bar fill animation ──
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOut);

    // ── Pulsing glow for the level badge ──
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    // Play sound + start animations sequentially
    AudioService.instance.playSfx(Sfx.levelUp);
    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _barCtrl.forward();
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _barCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A3E), Color(0xFF0D0D1F)],
            ),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Illustration ──
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      AppAssets.levelUpIllustration,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.gold.withValues(alpha: 0.3),
                              AppColors.primary.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          size: 80,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    // Dark overlay at bottom for readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // ── LEVEL UP label ──
                    Text(
                      'LEVEL UP!',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppColors.gold,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 4),

                    // ── Level badge with glow pulse ──
                    AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (context, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(
                                    alpha: 0.3 + 0.35 * _glowAnim.value),
                                blurRadius: 20 + 20 * _glowAnim.value,
                                spreadRadius: 2 + 4 * _glowAnim.value,
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.gold, Color(0xFFB8860B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${widget.newLevel}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── XP bar filling from 0 → full ──
                    Text(
                      'Level ${widget.newLevel} unlocked!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedBuilder(
                        animation: _barAnim,
                        builder: (context, _) {
                          return LinearProgressIndicator(
                            value: _barAnim.value,
                            minHeight: 12,
                            backgroundColor:
                                AppColors.surface.withValues(alpha: 0.6),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.lerp(
                                AppColors.primary,
                                AppColors.gold,
                                _barAnim.value,
                              )!,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'XP bar reset — keep going!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),

                    const SizedBox(height: 24),

                    // ── Continue button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          AudioService.instance.playButtonTap();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'AWESOME!',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
