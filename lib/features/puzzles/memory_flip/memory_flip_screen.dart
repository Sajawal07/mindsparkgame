import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/level_config.dart';
import '../../../core/utils/practice_config.dart';
import '../../../data/models/arena_config.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/models/puzzle_type.dart';
import '../../../data/providers/game_providers.dart';
import '../../../shared/utils/puzzle_feedback.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../puzzle_flow.dart';

class _CardData {
  _CardData({required this.id, required this.symbol});

  final int id;
  final String symbol;
  bool isFlipped = false;
  bool isMatched = false;
}

class MemoryFlipScreen extends ConsumerStatefulWidget {
  const MemoryFlipScreen({super.key});

  @override
  ConsumerState<MemoryFlipScreen> createState() => _MemoryFlipScreenState();
}

class _MemoryFlipScreenState extends ConsumerState<MemoryFlipScreen> {
  static const _symbols = [
    '🌟', '🎯', '🔮', '⚡', '🎨', '🎵', '🌈', '🔥',
    '💎', '🚀', '🌙', '⭐', '🍀', '🎲', '🦋',
  ];

  late List<_CardData> _cards;
  int? _firstIndex;
  int _moves = 0;
  bool _canFlip = true;
  bool _previewing = true;
  DateTime? _startTime;

  int _memoryRows = 2;
  int _memoryCols = 3;
  double _previewSeconds = 3;

  late final bool _isArena;
  Timer? _arenaTimer;
  int _arenaRemaining = 60;
  int _pairsFound = 0;
  bool _timerFlash = false;
  int? _penaltyCardIndex;

  @override
  void initState() {
    super.initState();
    final level = ref.read(gameStateProvider).save.player.level;
    LevelConfig.setPlayerLevel(level);
    final mode = ref.read(puzzleSessionProvider).mode;
    final isPractice = mode == GameMode.practice;
    _isArena = mode == GameMode.arena;
    PracticeConfig.setEnabled(isPractice);

    if (_isArena) {
      _memoryRows = LevelConfig.memoryRows.clamp(4, 5);
      _memoryCols = LevelConfig.memoryCols.clamp(4, 5);
      if (_memoryRows * _memoryCols < 16) {
        _memoryRows = 4;
        _memoryCols = 4;
      }
      _previewSeconds = LevelConfig.memoryPreviewSeconds.clamp(2.0, 4.0);
    } else if (isPractice) {
      final grid = PracticeConfig.randomMemoryGrid();
      _memoryRows = grid.rows;
      _memoryCols = grid.cols;
    } else {
      _memoryRows = LevelConfig.memoryRows;
      _memoryCols = LevelConfig.memoryCols;
      _previewSeconds = LevelConfig.memoryPreviewSeconds;
    }

    _initCards();

    if (isPractice) {
      _previewSeconds = PracticeConfig.previewSecondsForPairs(_pairCount);
    }

    Future.delayed(
      Duration(milliseconds: (_previewSeconds * 1000).round()),
      () {
        if (!mounted) return;
        setState(() {
          _previewing = false;
          for (final c in _cards) {
            c.isFlipped = false;
          }
          _startTime = DateTime.now();
        });
        if (_isArena) _startArenaTimer();
      },
    );
  }

  void _startArenaTimer() {
    _arenaTimer?.cancel();
    _arenaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _previewing) return;
      setState(() {
        if (_arenaRemaining <= 0) {
          _finish();
          return;
        }
        _arenaRemaining--;
        if (_arenaRemaining <= 0) _finish();
      });
    });
  }

  void _initCards() {
    final rows = _memoryRows;
    final cols = _memoryCols;
    final pairCount = (rows * cols) ~/ 2;
    final pool = List<String>.from(_symbols)..shuffle(Random());
    final symbols = pool.take(pairCount).toList();
    final deck = <_CardData>[];
    var id = 0;
    for (final s in symbols) {
      deck.add(_CardData(id: id++, symbol: s));
      deck.add(_CardData(id: id++, symbol: s));
    }
    deck.shuffle(Random());
    _cards = deck;
    for (final c in _cards) {
      c.isFlipped = true;
    }
  }

  int get _pairCount => _cards.length ~/ 2;

  void _applyPenalty() {
    setState(() {
      _arenaRemaining = (_arenaRemaining - 2).clamp(0, 60);
      _timerFlash = true;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _timerFlash = false);
    });
    if (_arenaRemaining <= 0) {
      _finish();
    }
  }

  void _onCardTap(int index) {
    if (_previewing || !_canFlip) return;
    final card = _cards[index];
    if (card.isMatched || card.isFlipped) return;

    setState(() => card.isFlipped = true);

    if (_firstIndex == null) {
      _firstIndex = index;
      return;
    }

    final first = _cards[_firstIndex!];
    _moves++;
    _canFlip = false;

    if (first.symbol == card.symbol) {
      playAnswerFeedback(true);
      first.isMatched = true;
      card.isMatched = true;
      _firstIndex = null;
      _canFlip = true;
      if (_isArena) {
        _pairsFound++;
        if (_cards.every((c) => c.isMatched)) _finish();
      } else if (_cards.every((c) => c.isMatched)) {
        _finish();
      }
      setState(() {});
      return;
    }

    playAnswerFeedback(false);
    if (_isArena) {
      setState(() => _penaltyCardIndex = index);
      _applyPenalty();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          first.isFlipped = false;
          card.isFlipped = false;
          _firstIndex = null;
          _canFlip = true;
          _penaltyCardIndex = null;
        });
      });
      return;
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        first.isFlipped = false;
        card.isFlipped = false;
        _firstIndex = null;
        _canFlip = true;
      });
    });
  }

  bool _finishing = false;

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    _arenaTimer?.cancel();

    final elapsed = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 1;

    int score;
    if (_isArena) {
      final pointsPerPair = 300 / _pairCount;
      score = (_pairsFound * pointsPerPair).round().clamp(0, 300);
    } else {
      final minMoves = _pairCount;
      final extra = (_moves - minMoves).clamp(0, 999);
      score = (200 - extra * 5).clamp(0, 200);
    }

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.memoryFlip,
      score: score,
      accuracy: 1.0,
      timeTakenSeconds: elapsed > 0 ? elapsed : 1,
      correctCount: _isArena ? _pairsFound : _pairCount,
      totalCount: _pairCount,
      maxScoreOverride: _isArena ? ArenaConfig.maxScorePerRound : null,
    );
  }

  @override
  void dispose() {
    _arenaTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cols = _memoryCols;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(_isArena ? 'Memory Flip — Arena' : 'Memory Flip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isArena)
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _timerFlash
                          ? AppColors.error.withValues(alpha: 0.4)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_arenaRemaining s',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: _arenaRemaining <= 10
                                ? AppColors.error
                                : Colors.white,
                          ),
                    ),
                  ),
                  if (_penaltyCardIndex != null)
                    const Positioned(
                      top: -8,
                      child: Text(
                        '-2s',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              )
            else
              Text(
                'Moves: $_moves · $_pairCount pairs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            if (_isArena)
              Text(
                'Pairs found: $_pairsFound / $_pairCount',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (_previewing)
              Text(
                'Memorize the cards…',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final showFace = card.isFlipped || card.isMatched;
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: showFace
                            ? AppColors.surfaceLight
                            : AppColors.primary,
                      ),
                      child: showFace
                          ? Center(
                              child: Text(
                                card.symbol,
                                style: const TextStyle(fontSize: 28),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                AppAssets.cardBack,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.help_outline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
