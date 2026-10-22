import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/level_config.dart';
import '../../../core/utils/puzzle_scores.dart';
import '../../../data/models/puzzle_type.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/providers/game_providers.dart';
import '../../../shared/utils/puzzle_feedback.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/mindspark_loading_indicator.dart';
import '../../../shared/widgets/puzzle_timer_bar.dart';
import '../puzzle_flow.dart';
import 'pattern_question_generator.dart';

class PatternIqScreen extends ConsumerStatefulWidget {
  const PatternIqScreen({super.key});

  @override
  ConsumerState<PatternIqScreen> createState() => _PatternIqScreenState();
}

class _PatternIqScreenState extends ConsumerState<PatternIqScreen> {
  static const _secondsPerQuestion = 15;

  late final List<PatternQuestion> _questions;
  Timer? _timer;
  int _remaining = _secondsPerQuestion;
  int _index = 0;
  int _correct = 0;
  int _score = 0;
  bool _finished = false;
  late DateTime _sessionStart;

  @override
  void initState() {
    super.initState();
    final level = ref.read(gameStateProvider).save.player.level;
    LevelConfig.setPlayerLevel(level);
    final isPractice =
        ref.read(puzzleSessionProvider).mode == GameMode.practice;
    _questions = PatternQuestionGenerator().generateSession(
      practice: isPractice,
      playerLevel: level,
    );
    _sessionStart = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) _advance(wasCorrect: false);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _answer(String choice) {
    if (_finished) return;
    final q = _questions[_index];
    _advance(wasCorrect: choice == q.correctAnswer);
  }

  void _advance({required bool wasCorrect}) {
    if (_finished) return;
    playAnswerFeedback(wasCorrect);
    if (wasCorrect) {
      _correct++;
      _score += 25;
    }
    if (_index >= _questions.length - 1) {
      _endSession();
      return;
    }
    setState(() => _index++);
    _startTimer();
  }

  Future<void> _endSession() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    final elapsed = DateTime.now().difference(_sessionStart).inSeconds;

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.patternIq,
      score: _score.clamp(0, PuzzleScores.maxScore(PuzzleType.patternIq)),
      accuracy: _correct / _questions.length,
      timeTakenSeconds: elapsed > 0 ? elapsed : 1,
      correctCount: _correct,
      totalCount: _questions.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const GradientScaffold(
        body: Center(child: MindSparkLoadingIndicator(size: 84)),
      );
    }

    final q = _questions[_index];

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Pattern IQ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PuzzleTimerBar(
              remainingSeconds: _remaining,
              totalSeconds: _secondsPerQuestion,
            ),
            const SizedBox(height: 12),
            Text(
              'Question ${_index + 1}/${_questions.length} · Score $_score',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            Text(
              'What comes next?',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...q.sequence.map(
                  (s) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(s, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const Text(' ? ', style: TextStyle(fontSize: 32)),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: q.choices.map((c) {
                return SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () => _answer(c),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      minimumSize: const Size(100, 48),
                    ),
                    child: Text(c, style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
