import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/puzzle_scores.dart';
import '../../data/models/puzzle_type.dart';
import '../../data/providers/game_providers.dart';
import '../../shared/widgets/gradient_scaffold.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameStateProvider);
    final meta = game.save.meta;
    final history = meta.brainScoreHistory;
    final session = game.save.todaySession;

    return GradientScaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: history.isEmpty
          ? _EmptyStats()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryRow(
                  label: 'Best Brain Score',
                  value: '${meta.bestBrainScore}',
                ),
                _SummaryRow(
                  label: 'Current Streak',
                  value: '${game.save.player.streak} days',
                ),
                _SummaryRow(
                  label: 'Longest Streak',
                  value: '${game.save.player.longestStreak} days',
                ),
                const SizedBox(height: 20),
                Text(
                  'Brain Score (last ${history.length} days)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (v, _) => Text(
                              v.toInt().toString(),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              final i = v.toInt();
                              if (i < 0 || i >= history.length) {
                                return const SizedBox.shrink();
                              }
                              final d = history[i].dateKey;
                              return Text(
                                d.length >= 5 ? d.substring(5) : d,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 9,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < history.length; i++)
                              FlSpot(i.toDouble(), history[i].brainScore.toDouble()),
                          ],
                          isCurved: true,
                          color: AppColors.primaryLight,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: 1000,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Today\'s Puzzle Scores',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (session != null && session.puzzleResults.isNotEmpty)
                  ...session.puzzleResults.map((r) {
                    final max = PuzzleScores.maxScore(r.puzzleType);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(child: Text(r.puzzleType.displayName)),
                          Text('${r.score}/$max'),
                        ],
                      ),
                    );
                  })
                else
                  Text(
                    'Play today\'s puzzles to see breakdown.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.emptyStats,
              height: 120,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.bar_chart,
                size: 80,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Complete your first daily session to unlock stats.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
