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
import 'word_lists.dart';

class WordSnapScreen extends ConsumerStatefulWidget {
  const WordSnapScreen({super.key});

  @override
  ConsumerState<WordSnapScreen> createState() => _WordSnapScreenState();
}

class _WordSnapScreenState extends ConsumerState<WordSnapScreen> {
  late final List<String> _words;
  int _wordIndex = 0;
  late List<String> _shuffledLetters;
  final List<String> _picked = [];
  int _score = 0;
  int _correct = 0;
  Timer? _timer;
  int _remaining = 0;
  bool _finished = false;
  late DateTime _sessionStart;
  bool _hintUsed = false;

  late final bool _isPractice;
  int _wordTimeLimit = 0;

  @override
  void initState() {
    super.initState();
    final level = ref.read(gameStateProvider).save.player.level;
    LevelConfig.setPlayerLevel(level);
    _isPractice =
        ref.read(puzzleSessionProvider).mode == GameMode.practice;
    _words = WordLists.wordsForSession(practice: _isPractice);
    _sessionStart = DateTime.now();
    _setupWord();
  }

  void _setupWord() {
    final word = _words[_wordIndex];
    _wordTimeLimit = _isPractice
        ? switch (word.length) {
            <= 4 => 18,
            <= 6 => 15,
            <= 8 => 12,
            _ => 10,
          }
        : LevelConfig.wordTimeLimitSeconds;
    _shuffledLetters = word.split('')..shuffle();
    _picked.clear();
    _remaining = _wordTimeLimit;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) _nextWord(success: false);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _pickLetter(String letter, int fromIndex) {
    setState(() {
      _picked.add(letter);
      _shuffledLetters.removeAt(fromIndex);
    });
    final target = _words[_wordIndex];
    if (_picked.join() == target) {
      _nextWord(success: true);
    }
  }

  void _unpick(int index) {
    setState(() {
      _shuffledLetters.add(_picked[index]);
      _picked.removeAt(index);
    });
  }

  void _useHint() {
    if (_hintUsed || _picked.isNotEmpty) return;
    final letter = _words[_wordIndex][0];
    final idx = _shuffledLetters.indexOf(letter);
    if (idx < 0) return;
    setState(() {
      _hintUsed = true;
      _picked.add(letter);
      _shuffledLetters.removeAt(idx);
    });
  }

  void _nextWord({required bool success}) {
    playAnswerFeedback(success);
    if (success) {
      _correct++;
      var pts = 30;
      if (_remaining > _wordTimeLimit ~/ 2) {
        pts += 10;
      } else if (_remaining > 3) {
        pts += 5;
      }
      _score += pts;
    }
    if (_wordIndex >= _words.length - 1) {
      _endSession();
      return;
    }
    setState(() => _wordIndex++);
    _setupWord();
  }

  Future<void> _endSession() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    final elapsed = DateTime.now().difference(_sessionStart).inSeconds;

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.wordSnap,
      score: _score.clamp(0, PuzzleScores.maxScore(PuzzleType.wordSnap)),
      accuracy: _correct / _words.length,
      timeTakenSeconds: elapsed > 0 ? elapsed : 1,
      correctCount: _correct,
      totalCount: _words.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const GradientScaffold(
        body: Center(child: MindSparkLoadingIndicator(size: 84)),
      );
    }

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Word Snap'),
        actions: [
          TextButton(
            onPressed: _hintUsed ? null : _useHint,
            child: const Text('Hint'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PuzzleTimerBar(
              remainingSeconds: _remaining,
              totalSeconds: _wordTimeLimit,
            ),
            const SizedBox(height: 8),
            Text(
              'Word ${_wordIndex + 1}/${_words.length} · Score $_score',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _picked.isEmpty ? 'Tap letters to spell' : _picked.join(),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _picked.asMap().entries.map((e) {
                return ActionChip(
                  label: Text(e.value.toUpperCase()),
                  onPressed: () => _unpick(e.key),
                );
              }).toList(),
            ),
            const Spacer(),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _shuffledLetters.asMap().entries.map((e) {
                return ElevatedButton(
                  onPressed: () => _pickLetter(e.value, e.key),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    e.value.toUpperCase(),
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
