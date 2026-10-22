import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GameTimerWidget extends StatelessWidget {
  const GameTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.size = 60.0,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final double size;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    
    Color progressColor = AppColors.success;
    if (progress < 0.3) {
      progressColor = AppColors.error;
    } else if (progress < 0.6) {
      progressColor = AppColors.gold;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.ringEmpty,
            color: progressColor,
            strokeWidth: 6,
          ),
          Center(
            child: Text(
              '$remainingSeconds',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
