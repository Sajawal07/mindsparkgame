import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/puzzle_feedback.dart';
import '../../../core/utils/level_config.dart';
import '../../../data/models/puzzle_type.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/providers/game_providers.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/puzzle_timer_bar.dart';
import '../../../shared/widgets/mindspark_loading_indicator.dart';
import '../puzzle_flow.dart';
import 'math_question.dart';
import 'math_question_generator.dart';

class MathBlitzScreen extends ConsumerStatefulWidget {
  const MathBlitzScreen({super.key});

  @override
  ConsumerState<MathBlitzScreen> createState() => _MathBlitzScreenState();
}

class _MathBlitzScreenState extends ConsumerState<MathBlitzScreen> {
  late final List<MathQuestion> _questions;
  late final int _totalTime;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _questionIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  int _questionStartMs = 0;
  bool _finished = false;

  static const int _dailyPointsPerCorrect = 10;
  static const int _maxSpeedBonus = 5;

  late final bool _isArena;
  late final int _activePointsPerCorrect;

  @override
  void initState() {
    super.initState();
    final level = ref.read(gameStateProvider).save.player.level;
    LevelConfig.setPlayerLevel(level);
    final mode = ref.read(puzzleSessionProvider).mode;
    final isPractice = mode == GameMode.practice;
    _isArena = mode == GameMode.arena;
    final generator = MathQuestionGenerator();

    if (_isArena) {
      _questions = List.generate(20, (_) => generator.generateQuestion());
      _totalTime = 45;
      _activePointsPerCorrect = 15;
    } else {
      _questions = generator.generateSession(
        practice: isPractice,
        playerLevel: level,
      );
      _totalTime = LevelConfig.mathTimeLimitSeconds;
      _activePointsPerCorrect = _dailyPointsPerCorrect;
    }
    _remainingSeconds = _totalTime;
    _questionStartMs = DateTime.now().millisecondsSinceEpoch;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) _endGame();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onAnswer(int choice) {
    if (_finished) return;
    final q = _questions[_questionIndex];
    final elapsed =
        (DateTime.now().millisecondsSinceEpoch - _questionStartMs) / 1000;
    final correct = choice == q.correctAnswer;
    playAnswerFeedback(correct);
    if (correct) {
      _correctCount++;
      var bonus = 0;
      if (!_isArena) {
        if (elapsed < 3) {
          bonus = _maxSpeedBonus;
        } else if (elapsed < 5) {
          bonus = 3;
        } else if (elapsed < 8) {
          bonus = 1;
        }
      }
      _score += _activePointsPerCorrect + bonus;
    }
    if (_questionIndex >= _questions.length - 1) {
      _endGame();
      return;
    }
    setState(() {
      _questionIndex++;
      _questionStartMs = DateTime.now().millisecondsSinceEpoch;
    });
  }

  Future<void> _endGame() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();

    final timeTaken = _totalTime - _remainingSeconds.clamp(0, _totalTime);
    final accuracy = _correctCount / _questions.length;

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.mathBlitz,
      score: _score,
      accuracy: accuracy,
      timeTakenSeconds: timeTaken > 0 ? timeTaken : 1,
      correctCount: _correctCount,
      totalCount: _questions.length,
      maxScoreOverride: _isArena ? 300 : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const GradientScaffold(
        body: Center(child: MindSparkLoadingIndicator(size: 84)),
      );
    }

    final q = _questions[_questionIndex];

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Math Blitz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PuzzleTimerBar(
              remainingSeconds: _remainingSeconds,
              totalSeconds: _totalTime,
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${_questionIndex + 1}/${_questions.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text('Score: $_score', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Text(
              q.prompt,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ...q.choices.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () => _onAnswer(c),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: AppColors.surfaceLight,
                  ),
                  child: Text('$c', style: const TextStyle(fontSize: 22)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
