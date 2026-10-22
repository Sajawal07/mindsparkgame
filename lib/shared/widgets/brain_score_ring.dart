import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class BrainScoreRing extends StatelessWidget {
  const BrainScoreRing({
    super.key,
    required this.score,
    required this.playedToday,
    this.size = 180,
  });

  final int score;
  final bool playedToday;
  final double size;

  @override
  Widget build(BuildContext context) {
    final progress = playedToday ? (score / 1000).clamp(0.0, 1.0) : 0.0;
    final ringColor = playedToday ? AppColors.ringFilled : AppColors.ringEmpty;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: AppColors.ringEmpty,
              color: ringColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                playedToday ? '$score' : '—',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                'Brain Score',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
