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
import '../../../data/catalog/who_am_i_database.dart';
import '../../../data/models/who_am_i_question.dart';
import '../../../data/providers/game_providers.dart';

class WhoAmIScreen extends ConsumerStatefulWidget {
  const WhoAmIScreen({super.key});

  @override
  ConsumerState<WhoAmIScreen> createState() => _WhoAmIScreenState();
}

class _WhoAmIScreenState extends ConsumerState<WhoAmIScreen> {
  late List<WhoAmIQuestion> _questions;
  late List<List<String>> _optionsPerQuestion;
  Timer? _timer;

  int _questionIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  int _streak = 0;
  bool _finished = false;

  int _remainingSeconds = 60;
  int _cluesRevealed = 1;
  bool _isAnswerTransitioning = false;

  static const int _timePerQuestion = 60;
  static const int _pointsPerCorrect = 10;

  static int? _coinCostForClue(int clueNumber) => switch (clueNumber) {
        4 => 20,
        5 => 30,
        6 => 50,
        _ => null,
      };

  @override
  void initState() {
    super.initState();
    final all = List<WhoAmIQuestion>.from(WhoAmIDatabase.questions)..shuffle();
    _questions = all.take(10).toList();
    _optionsPerQuestion = _questions.map((q) {
      final wrongOpts = q.options.where((o) => o != q.name).toList();
      final opts = [q.name, ...wrongOpts.take(3)];
      opts.shuffle();
      return List<String>.from(opts);
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
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

  void _onTimeout() {
    if (_finished || _isAnswerTransitioning) return;
    _streak = 0;
    _moveToNextQuestion();
  }

  Future<void> _revealNextClue() async {
    if (_cluesRevealed >= 6 || _isAnswerTransitioning) return;

    final nextClue = _cluesRevealed + 1;
    final cost = _coinCostForClue(nextClue);

    if (cost != null) {
      final gameState = ref.read(gameStateProvider);
      final coins = gameState.save.player.coins;
      if (coins < cost) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Need $cost coins for clue $nextClue. You have $coins.',
              ),
            ),
          );
        }
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Reveal Clue $nextClue'),
          content: Text(
            'Spend $cost coins to reveal clue $nextClue of 6?',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Buy ($cost coins)'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      final spent = await ref.read(gameStateProvider).spendCoins(cost);
      if (!spent) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not complete purchase.')),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    setState(() => _cluesRevealed++);
  }

  String _nextClueButtonLabel() {
    final next = _cluesRevealed + 1;
    final cost = _coinCostForClue(next);
    if (cost == null) return 'Reveal Clue $next';
    return 'Clue $next ($cost coins)';
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
      var points = _pointsPerCorrect;
      _score += points;
    } else {
      _streak = 0;
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    if (_questionIndex >= _questions.length - 1) {
      _endGame();
      return;
    }
    setState(() {
      _questionIndex++;
      _isAnswerTransitioning = false;
      _cluesRevealed = 1;
    });
    _startTimer();
  }

  Future<void> _endGame() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();

    final accuracy = _correctCount / _questions.length;
    final totalTime = (_questions.length * _timePerQuestion) - _remainingSeconds;

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.whoAmI,
      score: _score,
      accuracy: accuracy,
      timeTakenSeconds: totalTime,
      correctCount: _correctCount,
      totalCount: _questions.length,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    final coins = ref.watch(gameStateProvider.select((g) => g.save.player.coins));
    final revealProgress = (_cluesRevealed - 1) / 5.0;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Who Am I'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, size: 18, color: AppColors.gold),
                Text(' $coins', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Score: $_score',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 10),
            Expanded(
              flex: 5,
              child: GameCardWidget(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 76,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcATop,
                              ),
                              child: _CharacterPortrait(
                                question: q,
                                iconSize: 40,
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: revealProgress.clamp(0.0, 1.0),
                              duration: const Duration(milliseconds: 600),
                              child: _CharacterPortrait(
                                question: q,
                                iconSize: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Clues: $_cluesRevealed/6',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                                if (_cluesRevealed < 6 && !_isAnswerTransitioning)
                                  ElevatedButton.icon(
                                    onPressed: _revealNextClue,
                                    icon: const Icon(Icons.search, size: 16),
                                    label: Text(_nextClueButtonLabel()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.textPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 0,
                                      ),
                                      minimumSize: const Size(0, 32),
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(color: AppColors.primaryLight, height: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  for (var i = 0; i < _cluesRevealed; i++)
                                    Flexible(
                                      child: _ClueText(
                                        '${i + 1}. ${q.clues[i]}',
                                        totalRevealed: _cluesRevealed,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 4,
              child: AnswerOptionsWidget(
                key: ValueKey('who_${q.id}_$_questionIndex'),
                options: options,
                correctAnswer: q.name,
                onAnswerSelected: _onAnswer,
                // Keep buttons compact so the option text remains readable.
                childAspectRatio: 2.5,
                maxOptionLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterPortrait extends StatelessWidget {
  const _CharacterPortrait({
    required this.question,
    required this.iconSize,
  });

  final WhoAmIQuestion question;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (!question.hasIllustration) {
      return ColoredBox(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        child: Center(
          child: Icon(Icons.person, size: iconSize, color: AppColors.textSecondary),
        ),
      );
    }

    return Image.asset(
      question.imagePath,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(Icons.person, size: iconSize, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ClueText extends StatelessWidget {
  const _ClueText(this.text, {required this.totalRevealed});

  final String text;
  final int totalRevealed;

  @override
  Widget build(BuildContext context) {
    final fontSize = switch (totalRevealed) {
      <= 2 => 14.0,
      <= 4 => 12.5,
      _ => 11.0,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: fontSize,
          height: 1.2,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
