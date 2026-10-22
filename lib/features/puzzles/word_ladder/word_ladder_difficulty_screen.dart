import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/word_ladder_data.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';

class WordLadderDifficultyScreen extends StatelessWidget {
  const WordLadderDifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Word Ladder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose difficulty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Climb the ladder one letter at a time. Tap words row by row, then reach the target at the top.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            _DifficultyCard(
              title: 'Easy',
              subtitle: '4 × 8 grid · 5-letter words',
              color: AppColors.success,
              onTap: () => _start(context, WordLadderDifficulty.easy),
            ),
            const SizedBox(height: 14),
            _DifficultyCard(
              title: 'Medium',
              subtitle: '5 × 12 grid · 5-letter words',
              color: AppColors.primaryLight,
              onTap: () => _start(context, WordLadderDifficulty.medium),
            ),
            const SizedBox(height: 14),
            _DifficultyCard(
              title: 'Hard',
              subtitle: '7 × 20 grid · 5-letter words',
              color: AppColors.streakOrange,
              onTap: () => _start(context, WordLadderDifficulty.hard),
            ),
          ],
        ),
      ),
    );
  }

  void _start(BuildContext context, WordLadderDifficulty difficulty) {
    context.push(AppRoutes.puzzleWordLadderPlay, extra: difficulty);
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Icon(Icons.grid_on_rounded, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
          ),
        ),
      ),
    );
  }
}
