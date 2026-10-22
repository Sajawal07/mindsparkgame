import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PuzzleTimerBar extends StatelessWidget {
  const PuzzleTimerBar({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  final int remainingSeconds;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final progress =
        totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.timer, color: AppColors.accent, size: 20),
            Text(
              '${remainingSeconds}s',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.ringEmpty,
            color: remainingSeconds <= 5 ? AppColors.error : AppColors.accent,
          ),
        ),
      ],
    );
  }
}
