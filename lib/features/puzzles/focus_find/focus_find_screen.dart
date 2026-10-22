import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/level_config.dart';
import '../../../core/utils/practice_config.dart';
import '../../../core/utils/puzzle_scores.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/models/puzzle_type.dart';
import '../../../data/providers/game_providers.dart';
import '../../../shared/utils/puzzle_feedback.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/mindspark_loading_indicator.dart';
import '../../../shared/widgets/puzzle_timer_bar.dart';
import '../puzzle_flow.dart';

class _GridItem {
  _GridItem({
    required this.icon,
    required this.color,
    required this.isOdd,
    this.size = 36,
  });

  final IconData icon;
  final Color color;
  final bool isOdd;
  final double size;
  bool found = false;
}

class FocusFindScreen extends ConsumerStatefulWidget {
  const FocusFindScreen({super.key});

  @override
  ConsumerState<FocusFindScreen> createState() => _FocusFindScreenState();
}

class _FocusFindScreenState extends ConsumerState<FocusFindScreen> {
  static const _dailyTimeLimit = 45;

  late List<_GridItem> _items;
  late int _cols;
  Timer? _timer;
  int _remaining = _dailyTimeLimit;
  int _score = 0;
  int _found = 0;
  int _totalOddsFound = 0;
  int _oddTotal = 0;
  bool _finished = false;
  bool _isPractice = false;

  // Practice multi-round
  int _roundIndex = 0;
  int _totalRounds = 1;
  late List<({int rows, int cols, int oddCount, int difficulty})> _roundSpecs;

  @override
  void initState() {
    super.initState();
    final level = ref.read(gameStateProvider).save.player.level;
    LevelConfig.setPlayerLevel(level);
    _isPractice =
        ref.read(puzzleSessionProvider).mode == GameMode.practice;
    PracticeConfig.setEnabled(_isPractice);

    if (_isPractice) {
      _totalRounds = PracticeConfig.focusRoundCount;
      _roundSpecs = PracticeConfig.focusRoundSpecs(_totalRounds);
      _remaining = 20 * _totalRounds;
    }

    _buildGrid();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) _endSession();
      });
    });
  }

  void _buildGrid() {
    final rows = _isPractice ? _roundSpecs[_roundIndex].rows : LevelConfig.focusRows;
    _cols = _isPractice ? _roundSpecs[_roundIndex].cols : LevelConfig.focusCols;
    final total = rows * _cols;
    final difficulty = _isPractice ? _roundSpecs[_roundIndex].difficulty : 2;
    _oddTotal = (_isPractice
            ? _roundSpecs[_roundIndex].oddCount
            : LevelConfig.focusOddCount)
        .clamp(1, total - 1);

    _found = 0;
    _items = _generateItems(total: total, oddCount: _oddTotal, difficulty: difficulty);
  }

  List<_GridItem> _generateItems({
    required int total,
    required int oddCount,
    required int difficulty,
  }) {
    final rng = Random();
    final normalPool = _iconPoolFor(difficulty, odd: false);
    final oddPool = _iconPoolFor(difficulty, odd: true);

    final normal = normalPool[rng.nextInt(normalPool.length)];
    final oddTemplate = oddPool[rng.nextInt(oddPool.length)];

    final items = <_GridItem>[];
    for (var i = 0; i < total - oddCount; i++) {
      items.add(_GridItem(
        icon: normal.icon,
        color: normal.color,
        isOdd: false,
        size: normal.size,
      ));
    }
    for (var i = 0; i < oddCount; i++) {
      // Slight variation per odd item on hard rounds
      final variant = difficulty >= 2 && i > 0
          ? oddPool[rng.nextInt(oddPool.length)]
          : oddTemplate;
      items.add(_GridItem(
        icon: variant.icon,
        color: variant.color,
        isOdd: true,
        size: variant.size,
      ));
    }
    items.shuffle(rng);
    return items;
  }

  List<({IconData icon, Color color, double size})> _iconPoolFor(
    int difficulty, {
    required bool odd,
  }) {
    if (difficulty == 0) {
      if (odd) {
        return [
          (icon: Icons.square, color: Colors.orange.shade400, size: 36.0),
          (icon: Icons.star, color: Colors.amber.shade400, size: 36.0),
        ];
      }
      return [
        (icon: Icons.circle, color: Colors.blue.shade300, size: 36.0),
        (icon: Icons.hexagon_outlined, color: Colors.teal.shade300, size: 36.0),
      ];
    }
    if (difficulty == 1) {
      if (odd) {
        return [
          (icon: Icons.change_history, color: Colors.blue.shade600, size: 34.0),
          (icon: Icons.play_arrow, color: Colors.indigo.shade400, size: 36.0),
        ];
      }
      return [
        (icon: Icons.circle, color: Colors.blue.shade400, size: 36.0),
        (icon: Icons.lens, color: Colors.lightBlue.shade300, size: 36.0),
      ];
    }
    // Hard — subtle differences
    if (odd) {
      return [
        (icon: Icons.star, color: const Color(0xFF5C6BC0), size: 32.0),
        (icon: Icons.star_border, color: const Color(0xFF7986CB), size: 36.0),
        (icon: Icons.fiber_manual_record, color: const Color(0xFF3949AB), size: 30.0),
      ];
    }
    return [
      (icon: Icons.star, color: const Color(0xFF42A5F5), size: 36.0),
      (icon: Icons.star_half, color: const Color(0xFF64B5F6), size: 36.0),
      (icon: Icons.blur_circular, color: const Color(0xFF90CAF9), size: 36.0),
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    PracticeConfig.setEnabled(false);
    super.dispose();
  }

  void _onTap(int index) {
    if (_finished) return;
    final item = _items[index];
    if (item.found) return;

    if (item.isOdd) {
      playAnswerFeedback(true);
      setState(() {
        item.found = true;
        _found++;
        _totalOddsFound++;
        _score += 100 + (_isPractice ? _roundIndex * 15 : 0);
      });
      if (_found >= _oddTotal) _onRoundComplete();
    } else {
      playAnswerFeedback(false);
      setState(() {
        _score = (_score - 20).clamp(0, 999);
      });
    }
  }

  void _onRoundComplete() {
    if (_isPractice && _roundIndex < _totalRounds - 1) {
      setState(() {
        _roundIndex++;
        _buildGrid();
      });
      return;
    }
    _endSession();
  }

  Future<void> _endSession() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    final timeLimit = _isPractice ? 20 * _totalRounds : _dailyTimeLimit;
    final timeTaken = timeLimit - _remaining.clamp(0, timeLimit);
    final totalOdds = _isPractice
        ? _roundSpecs.fold<int>(0, (s, r) => s + r.oddCount)
        : _oddTotal;

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.focusFind,
      score: _score.clamp(0, PuzzleScores.maxScore(PuzzleType.focusFind)),
      accuracy: totalOdds > 0 ? _totalOddsFound / totalOdds : 0,
      timeTakenSeconds: timeTaken > 0 ? timeTaken : 1,
      correctCount: _totalOddsFound,
      totalCount: totalOdds,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const GradientScaffold(
        body: Center(child: MindSparkLoadingIndicator(size: 84)),
      );
    }

    final timeLimit = _isPractice ? 20 * _totalRounds : _dailyTimeLimit;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(_isPractice ? 'Focus Find · Practice' : 'Focus Find'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PuzzleTimerBar(
              remainingSeconds: _remaining,
              totalSeconds: timeLimit,
            ),
            const SizedBox(height: 8),
            Text(
              _isPractice
                  ? 'Round ${_roundIndex + 1}/$_totalRounds · Find $_oddTotal odd · Found $_found · Score $_score'
                  : 'Find $_oddTotal odd · Found $_found · Score $_score',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (_isPractice) ...[
              const SizedBox(height: 4),
              Text(
                _roundSpecs[_roundIndex].difficulty == 2
                    ? 'Hard — look closely!'
                    : _roundSpecs[_roundIndex].difficulty == 1
                        ? 'Medium difficulty'
                        : 'Warm-up round',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _cols,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return GestureDetector(
                    onTap: () => _onTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: item.found
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: item.found
                            ? Border.all(color: AppColors.success, width: 2)
                            : null,
                      ),
                      child: Icon(item.icon, color: item.color, size: item.size),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
