import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class XpBar extends StatelessWidget {
  const XpBar({
    super.key,
    required this.level,
    required this.progress,
  });

  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Lv $level',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.ringEmpty,
              color: AppColors.primaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
