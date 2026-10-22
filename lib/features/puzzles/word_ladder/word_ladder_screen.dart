import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/puzzle_scores.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/models/puzzle_type.dart';
import '../../../data/models/word_ladder_data.dart';
import '../../../data/providers/game_providers.dart';
import '../../../shared/utils/puzzle_feedback.dart';
import '../../../shared/widgets/game_timer_widget.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/mindspark_loading_indicator.dart';
import '../puzzle_flow.dart';

class WordLadderScreen extends ConsumerStatefulWidget {
  const WordLadderScreen({super.key, required this.difficulty});

  final WordLadderDifficulty difficulty;

  @override
  ConsumerState<WordLadderScreen> createState() => _WordLadderScreenState();
}

class _WordLadderScreenState extends ConsumerState<WordLadderScreen> {
  static const int _practiceAndArenaPuzzlesPerSession = 5;
  static const int _dailySessionSeconds = 300;
  static const int _arenaSessionSeconds = 120;
  static const int _hintIqPenalty = 50;
  static const int _failTimePenaltySeconds = 3;

  late final List<WordLadderGridPuzzle> _templates;
  late WordLadderPlayablePuzzle _puzzle;
  late final int _puzzlesPerSession;

  Timer? _timer;
  late final int _sessionSeconds;
  late int _remainingSeconds;
  late final bool _isArena;
  int _puzzleIndex = 0;
  int _iqScore = 0;
  int _puzzleIqBase = 0;
  bool _finished = false;
  bool _currentPuzzleSolved = false;
  int _hintsRemaining = 3;
  int _failedAttempts = 0;

  /// Row 0 = bottom (start). One selected word per row, or null.
  late List<String?> _selections;
  int _activeRowIndex = 1;
  String? _hintGlowWord;
  int? _brokenStepIndex;
  String? _feedbackMessage;
  bool _showingFeedback = false;
  int _puzzleElapsedSeconds = 0;
  Timer? _puzzleTimer;

  @override
  void initState() {
    super.initState();
    final mode = ref.read(puzzleSessionProvider).mode;
    _isArena = mode == GameMode.arena;
    final isDaily = mode == GameMode.daily;
    _puzzlesPerSession =
        isDaily ? 1 : _practiceAndArenaPuzzlesPerSession;
    _sessionSeconds =
        _isArena ? _arenaSessionSeconds : _dailySessionSeconds;
    _remainingSeconds = _sessionSeconds;
    final pool = List<WordLadderGridPuzzle>.from(
      WordLadderPuzzleCatalog.forDifficulty(widget.difficulty),
    )..shuffle();
    _templates = <WordLadderGridPuzzle>[];
    while (_templates.length < _puzzlesPerSession && pool.isNotEmpty) {
      _templates.add(pool[_templates.length % pool.length]);
    }
    _loadPuzzle();
    _startSessionTimer();
  }

  void _loadPuzzle() {
    _puzzle = _templates[_puzzleIndex % _templates.length].buildPlayable();
    _selections = List<String?>.filled(_puzzle.rowCount, null);
    _activeRowIndex = 0;
    _hintGlowWord = null;
    _brokenStepIndex = null;
    _feedbackMessage = null;
    _hintsRemaining = 3;
    _puzzleElapsedSeconds = 0;
    _currentPuzzleSolved = false;
    _puzzleIqBase = (PuzzleScores.maxScore(PuzzleType.wordLadder) / _puzzlesPerSession)
        .round();
    _puzzleTimer?.cancel();
    _puzzleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished || _showingFeedback) return;
      setState(() => _puzzleElapsedSeconds++);
    });
  }

  void _startSessionTimer() {
    _timer?.cancel();
    _remainingSeconds = _sessionSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) _endGame();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _puzzleTimer?.cancel();
    super.dispose();
  }

  List<String> get _chain =>
      _selections.whereType<String>().toList();

  void _onCellTap(int rowIndex, String word) {
    if (_finished || _showingFeedback) return;

    final topRow = _puzzle.rowCount - 1;
    final selected = _selections[rowIndex];

    // Deselect: tap same word again in a selected row.
    if (selected != null && selected == word) {
      setState(() {
        for (var r = rowIndex; r < _puzzle.rowCount; r++) {
          _selections[r] = null;
        }
        _activeRowIndex = rowIndex;
        _hintGlowWord = null;
        _brokenStepIndex = null;
        _feedbackMessage = null;
      });
      return;
    }

    if (rowIndex != _activeRowIndex) return;

    setState(() {
      _selections[rowIndex] = word;
      _hintGlowWord = null;
      _brokenStepIndex = null;
      _feedbackMessage = null;

      if (rowIndex == topRow) {
        _validateChainAtTarget();
      } else {
        _activeRowIndex = rowIndex + 1;
      }
    });
  }

  Future<void> _validateChainAtTarget() async {
    final chain = _chain;
    final target = _puzzle.targetWord;

    if (chain.isEmpty || chain.last != target) {
      _registerFailedChain(chain);
      return;
    }

    final broken = WordLadderPuzzleCatalog.brokenStepIndex(chain);
    if (broken != null) {
      _registerFailedChain(chain, broken);
      return;
    }

    playAnswerFeedback(true);
    var puzzlePoints = _puzzleIqBase;
    if (_puzzleElapsedSeconds < 60) {
      puzzlePoints += 50;
    } else if (_puzzleElapsedSeconds < 120) {
      puzzlePoints += 25;
    }
    puzzlePoints -= _failedAttempts * 10;
    puzzlePoints -= (3 - _hintsRemaining) * _hintIqPenalty;
    puzzlePoints = puzzlePoints.clamp(20, _puzzleIqBase + 80);

    setState(() => _iqScore += puzzlePoints);
    _currentPuzzleSolved = true;

    _puzzleTimer?.cancel();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted || _finished) return;

    if (_puzzleIndex >= _puzzlesPerSession - 1) {
      _endGame();
    } else {
      setState(() {
        _puzzleIndex++;
        _failedAttempts = 0;
        _loadPuzzle();
      });
    }
  }

  void _registerFailedChain(List<String> chain, [int? brokenStep]) {
    final step = brokenStep ??
        WordLadderPuzzleCatalog.brokenStepIndex(chain) ??
        1;
    final a = chain[step - 1];
    final b = step < chain.length ? chain[step] : _puzzle.targetWord;

    playAnswerFeedback(false);
    final topRow = _puzzle.rowCount - 1;
    setState(() {
      _failedAttempts++;
      _brokenStepIndex = step;
      _remainingSeconds = max(0, _remainingSeconds - _failTimePenaltySeconds);
      _feedbackMessage =
          'Your sequence broke at step $step. $a → $b are not 1 letter apart.';
      _showingFeedback = true;
      // Clear target pick so player can backtrack and fix the chain.
      if (_selections[topRow] != null) {
        _selections[topRow] = null;
      }
      _activeRowIndex = min(step, topRow).clamp(0, topRow);
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _showingFeedback = false;
        _feedbackMessage = null;
        _brokenStepIndex = null;
      });
    });
  }

  void _useHint() {
    if (_hintsRemaining <= 0 || _finished || _showingFeedback) return;
    if (_chain.isEmpty) return;

    final lastWord = _chain.last;
    final hint = _puzzle.hintWordAfter(lastWord);
    if (hint == null) return;

    setState(() {
      _hintsRemaining--;
      _hintGlowWord = hint;
    });
  }

  Future<void> _endGame() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    _puzzleTimer?.cancel();

    final timeTaken = _sessionSeconds - _remainingSeconds.clamp(0, _sessionSeconds);
    final correctPuzzles = _currentPuzzleSolved ? _puzzleIndex + 1 : _puzzleIndex;

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.wordLadder,
      score: _iqScore.clamp(0, PuzzleScores.maxScore(PuzzleType.wordLadder)),
      accuracy: _puzzlesPerSession > 0
          ? correctPuzzles / _puzzlesPerSession
          : 0,
      timeTakenSeconds: timeTaken > 0 ? timeTaken : 1,
      correctCount: correctPuzzles,
      totalCount: _puzzlesPerSession,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const GradientScaffold(
        body: Center(child: MindSparkLoadingIndicator(size: 84)),
      );
    }

    final topRow = _puzzle.rowCount - 1;
    final isPractice =
        ref.watch(puzzleSessionProvider).mode == GameMode.practice;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Word Ladder'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'IQ: $_iqScore',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPractice
                      ? 'Puzzle ${_puzzleIndex + 1}/$_puzzlesPerSession · ${widget.difficulty.label}'
                      : 'Puzzle ${_puzzleIndex + 1}/$_puzzlesPerSession',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                GameTimerWidget(
                  remainingSeconds: _remainingSeconds,
                  totalSeconds: _sessionSeconds,
                  size: 48,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EndpointChip(
                  label: _puzzle.startWord,
                  color: AppColors.primary,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.asset(
                    'assets/images/word_ladder/WORDLADDER_ARROW.png',
                    width: 28,
                    height: 28,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  ),
                ),
                _EndpointChip(
                  label: _puzzle.targetWord,
                  color: AppColors.accent,
                ),
              ],
            ),
            if (_feedbackMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _feedbackMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 4),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      for (var displayRow = topRow; displayRow >= 0; displayRow--)
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, rowConstraints) {
                              final rowHeight = rowConstraints.maxHeight;
                              final fontSize = max(8.0, rowHeight * 0.32);
                              final radius = min(6.0, rowHeight * 0.1);
                              return _buildGridRow(
                                rowIndex: displayRow,
                                rowHeight: rowHeight,
                                fontSize: fontSize,
                                radius: radius,
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _hintsRemaining > 0 ? _useHint : null,
                    icon: Image.asset(
                      'assets/images/word_ladder/WORDLADDER_HINT.png',
                      width: 22,
                      height: 22,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.lightbulb, size: 22),
                    ),
                    label: Text('Hint ($_hintsRemaining)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      foregroundColor: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridRow({
    required int rowIndex,
    required double rowHeight,
    required double fontSize,
    required double radius,
  }) {
    final row = _puzzle.rows[rowIndex];
    final isTarget = rowIndex == _puzzle.rowCount - 1;
    final isActive = rowIndex == _activeRowIndex && !_showingFeedback;
    final isFuture = rowIndex > _activeRowIndex;
    final selectedWord = _selections[rowIndex];
    final brokenHere = _brokenStepIndex != null &&
        (_brokenStepIndex == rowIndex || _brokenStepIndex == rowIndex + 1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius + 1),
      child: DecoratedBox(
        decoration: isActive
            ? BoxDecoration(
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                  width: 1,
                ),
              )
            : const BoxDecoration(),
        child: Row(
          children: [
            for (final word in row.words)
              Expanded(
                child: _buildCell(
                rowIndex: rowIndex,
                word: word,
                rowHeight: rowHeight,
                fontSize: fontSize,
                radius: radius,
                isTarget: isTarget,
                isActive: isActive,
                isFuture: isFuture,
                isSelected: selectedWord == word,
                isBroken: brokenHere && selectedWord == word,
                isHintGlow: _hintGlowWord == word && rowIndex == _activeRowIndex,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell({
    required int rowIndex,
    required String word,
    required double rowHeight,
    required double fontSize,
    required double radius,
    required bool isTarget,
    required bool isActive,
    required bool isFuture,
    required bool isSelected,
    required bool isBroken,
    required bool isHintGlow,
  }) {
    final canTap = isActive || (isSelected && !_showingFeedback);

    Color bg = AppColors.surfaceLight.withValues(alpha: isFuture ? 0.35 : 0.65);
    Color border = Colors.white24;
    Color textColor = isFuture ? AppColors.textSecondary : Colors.white;

    if (isTarget) {
      bg = AppColors.accent.withValues(alpha: isSelected ? 0.45 : 0.2);
      border = AppColors.accent;
      textColor = AppColors.accent;
    } else if (isBroken) {
      bg = AppColors.error.withValues(alpha: 0.4);
      border = AppColors.error;
    } else if (isSelected) {
      bg = AppColors.gold.withValues(alpha: 0.35);
      border = AppColors.gold;
      textColor = AppColors.gold;
    } else if (isHintGlow) {
      bg = AppColors.gold.withValues(alpha: 0.25);
      border = AppColors.gold;
    }

    List<BoxShadow>? shadows;
    if (isHintGlow) {
      shadows = [
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.55),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? () => _onCellTap(rowIndex, word) : null,
          borderRadius: BorderRadius.circular(radius),
          child: AnimatedContainer(
            height: rowHeight,
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: border, width: isActive ? 1 : 0.6),
              boxShadow: shadows,
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                word,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EndpointChip extends StatelessWidget {
  const _EndpointChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
