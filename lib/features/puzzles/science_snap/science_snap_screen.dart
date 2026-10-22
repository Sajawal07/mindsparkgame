import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/puzzle_feedback.dart';
import '../../../data/models/puzzle_type.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/answer_options_widget.dart';
import '../../../shared/widgets/game_card_widget.dart';
import '../../../shared/widgets/game_timer_widget.dart';
import '../../../shared/widgets/mindspark_loading_indicator.dart';
import '../puzzle_flow.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/models/science_snap_data.dart';
import '../../../data/providers/game_providers.dart';

class ScienceSnapScreen extends ConsumerStatefulWidget {
  const ScienceSnapScreen({super.key});

  @override
  ConsumerState<ScienceSnapScreen> createState() => _ScienceSnapScreenState();
}

class _ScienceSnapScreenState extends ConsumerState<ScienceSnapScreen> {
  late final List<ScienceElement> _questions;
  late final List<List<String>> _optionsPerQuestion;
  Timer? _timer;
  int _remainingSeconds = 12;
  int _questionIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  int _streak = 0;
  bool _finished = false;
  int _hintsRemaining = 3;
  bool _hintRevealed = false;
  bool _isAnswerTransitioning = false;
  late final bool _isPracticeMode;

  static const int _timePerQuestion = 12;
  static const int _pointsPerCorrect = 10;

  @override
  void initState() {
    super.initState();
    _isPracticeMode =
        ref.read(puzzleSessionProvider).mode == GameMode.practice;
    final allElements = List<ScienceElement>.from(ScienceElement.dataset)
      ..shuffle();
    _questions = allElements.take(10).toList();
    // Symbol image is shown; options are always full element names (fixed order per question).
    _optionsPerQuestion = _questions.map((q) {
      final opts = [q.name, ...q.wrongOptions.take(3)];
      opts.shuffle();
      return List<String>.from(opts);
    }).toList();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = _timePerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isAnswerTransitioning || _finished) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _onTimeout();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onTimeout() {
    if (_finished || _isAnswerTransitioning) return;
    _streak = 0;
    if (_isPracticeMode) {
      _showFunFactPopup(false);
    } else {
      _moveToNextQuestion();
    }
  }

  Future<void> _onAnswer(String answer) async {
    if (_finished || _isAnswerTransitioning) return;

    setState(() {
      _isAnswerTransitioning = true;
      _timer?.cancel();
    });

    final q = _questions[_questionIndex];
    final correct = answer == q.name;
    playAnswerFeedback(correct);

    if (correct) {
      _correctCount++;
      _streak++;
      _score += _pointsPerCorrect;
    } else {
      _streak = 0;
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    if (_isPracticeMode) {
      _showFunFactPopup(correct);
    } else {
      _moveToNextQuestion();
    }
  }

  void _showFunFactPopup(bool wasCorrect) {
    setState(() {
      _isAnswerTransitioning = true;
    });

    final q = _questions[_questionIndex];

    // Practice keeps fun-fact popup but auto-advances without button.
    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          wasCorrect ? 'Correct!' : 'Time\'s Up / Incorrect',
          style: TextStyle(
            color: wasCorrect ? AppColors.success : AppColors.error,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Did you know?',
              style: Theme.of(dialogContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${q.symbol} = ${q.name}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(q.funFact, textAlign: TextAlign.center),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 900)).then((_) {
      if (!mounted) return;
      // Close the dialog (if still open), then move on.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    dialogFuture.then((_) {
      if (!mounted) return;
      _moveToNextQuestion();
    });
  }

  void _moveToNextQuestion() {
    if (_questionIndex >= _questions.length - 1) {
      _endGame();
      return;
    }
    setState(() {
      _questionIndex++;
      _hintRevealed = false;
      _isAnswerTransitioning = false;
    });
    _startTimer();
  }

  Future<void> _endGame() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();

    final accuracy = _correctCount / _questions.length;

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.scienceSnap,
      score: _score,
      accuracy: accuracy,
      timeTakenSeconds: 120 - (_questionIndex * 12 + _remainingSeconds),
      correctCount: _correctCount,
      totalCount: _questions.length,
    );
  }

  void _showHint() {
    if (_hintsRemaining > 0 && !_hintRevealed) {
      setState(() {
        _hintsRemaining--;
        _hintRevealed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const GradientScaffold(
        body: Center(child: MindSparkLoadingIndicator(size: 84)),
      );
    }

    final q = _questions[_questionIndex];
    final options = _optionsPerQuestion[_questionIndex];

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Science Snap'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: $_score',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_questionIndex + 1}/${_questions.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_streak >= 3)
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: AppColors.streakOrange,
                        size: 20,
                      ),
                      Text(
                        ' $_streak Streak!',
                        style: const TextStyle(
                          color: AppColors.streakOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                GameTimerWidget(
                  remainingSeconds: _remainingSeconds,
                  totalSeconds: _timePerQuestion,
                  size: 50,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GameCardWidget(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.asset(
                          q.imagePath,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceLight,
                              alignment: Alignment.center,
                              child: Text(
                                q.symbol,
                                style: const TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight.withValues(alpha: 0.8),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: const Text(
                              'Name this element',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_hintRevealed)
                            Expanded(
                              child: Text(
                                'Category: ${q.category}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          else
                            const Spacer(),
                          if (!_hintRevealed)
                            ElevatedButton.icon(
                              onPressed:
                                  _hintsRemaining > 0 ? _showHint : null,
                              icon: const Icon(Icons.lightbulb, size: 16),
                              label: Text('Hint ($_hintsRemaining)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                                minimumSize: const Size(0, 32),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnswerOptionsWidget(
              key: ValueKey('science_${q.symbol}_$_questionIndex'),
              options: options,
              correctAnswer: q.name,
              onAnswerSelected: _onAnswer,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
