import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/haptics_service.dart';

/// 3-star rating row used by all premium games.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.stars,
    this.size = 36,
  });

  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? AppColors.gold : Colors.white24,
            size: size,
          ),
        );
      }),
    );
  }
}

/// Shared premium result screen — IQ/score, coins, XP, Play Again / Next.
class GameResultScreen extends StatefulWidget {
  const GameResultScreen({
    super.key,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.stars,
    required this.coinsEarned,
    required this.xpEarned,
    this.subtitle,
    this.rankLabel,
    this.won = true,
    this.accentColor,
    this.onPlayAgain,
    this.onNext,
    this.nextLabel = 'Continue',
    this.stats = const [],
  });

  final String title;
  final int score;
  final int maxScore;
  final int stars;
  final int coinsEarned;
  final int xpEarned;
  final String? subtitle;
  final String? rankLabel;
  final bool won;
  final Color? accentColor;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onNext;
  final String nextLabel;
  final List<(String, String)> stats;

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.won) {
      _confetti.forward();
      AudioService.instance.playSfx(Sfx.puzzleComplete);
      HapticsService.levelUp();
    } else {
      AudioService.instance.playSfx(Sfx.wrong);
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0B1220),
              accent.withValues(alpha: 0.25),
              const Color(0xFF05070D),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (widget.won)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _confetti,
                    builder: (context, _) => CustomPaint(
                      painter: _ConfettiPainter(
                        progress: _confetti.value,
                        color: accent,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      widget.won ? 'Victory!' : 'Session Over',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: widget.won ? AppColors.gold : Colors.white70,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(color: Colors.white60),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    StarRating(stars: widget.stars),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.score} / ${widget.maxScore}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    if (widget.rankLabel != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.rankLabel!,
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RewardChip(
                          icon: Icons.monetization_on,
                          label: '+${widget.coinsEarned}',
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 16),
                        _RewardChip(
                          icon: Icons.bolt,
                          label: '+${widget.xpEarned} XP',
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                    if (widget.stats.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: widget.stats
                            .map(
                              (s) => Chip(
                                backgroundColor: Colors.white10,
                                label: Text(
                                  '${s.$1}: ${s.$2}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const Spacer(),
                    if (widget.onPlayAgain != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: widget.onPlayAgain,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: accent),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Play Again'),
                        ),
                      ),
                    if (widget.onNext != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(widget.nextLabel),
                        ),
                      ),
                    ],
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

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 28; i++) {
      final t = (progress + i * 0.03) % 1.0;
      final x = (i * 47 % size.width.toInt()).toDouble();
      final y = size.height * 0.15 + t * size.height * 0.7;
      paint.color = (i.isEven ? color : AppColors.gold)
          .withValues(alpha: (1 - t) * 0.85);
      canvas.drawCircle(Offset(x, y), 3 + (i % 3).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
