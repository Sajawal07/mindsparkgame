import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/arena_config.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/models/puzzle_type.dart';
import '../../../data/providers/game_providers.dart';
import '../../../data/services/audio_service.dart';

import 'generators/circular_maze_generator.dart';
import 'generators/square_maze_generator.dart';
import 'generators/triangle_maze_generator.dart';

import 'models/generated_maze.dart';
import 'models/maze_difficulty.dart';
import 'models/maze_type.dart';

import 'painters/circular_maze_painter.dart';
import 'painters/square_maze_painter.dart';
import 'painters/triangle_maze_painter.dart';

import 'path_finder_config.dart';
import '../puzzle_flow.dart';

import 'widgets/direction_controls.dart';
import 'widgets/maze_win_dialog.dart';
import 'screens/maze_type_select_screen.dart';

class PathFinderScreen extends ConsumerStatefulWidget {
  const PathFinderScreen({super.key});

  @override
  ConsumerState<PathFinderScreen> createState() => _PathFinderScreenState();
}

class _PathFinderScreenState extends ConsumerState<PathFinderScreen>
    with SingleTickerProviderStateMixin {
  late bool _isArena;
  MazeType _type = MazeType.square;
  MazeDifficulty _difficulty = MazeDifficulty.easy;
  /// 0-based map slot within the selected difficulty (0..29).
  int _mapIndex = 0;

  late MazeGraphData _mazeData;
  late String _currentCellId;
  final List<String> _traveledPath = [];
  int _moveCount = 0;
  int _mistakes = 0;

  bool _finished = false;
  bool _won = false;
  bool _showHint = false;

  Timer? _clockTimer;
  int _remainingTimeSeconds = 0;
  int _elapsedSeconds = 0;

  late AnimationController _hintAnimCtrl;

  @override
  void initState() {
    super.initState();
    final session = ref.read(puzzleSessionProvider);
    _isArena = session.mode == GameMode.arena;

    if (_isArena) {
      _type = MazeType.square;
      _difficulty = MazeDifficulty.hard; // Arena forces Hard difficulty
    }

    _hintAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _initMaze();

    if (!_isArena) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openTypeSelector();
      });
    }
  }

  void _initMaze() {
    _clockTimer?.cancel();
    final seed = MazeDifficulty.seedFor(
      type: _type,
      difficulty: _difficulty,
      mapIndex: _mapIndex,
    );
    // Arena keeps a compact timed maze; practice Hard is the huge unique-path set.
    final rng = _isArena ? Random() : Random(seed);
    final generator = switch (_type) {
      MazeType.square => SquareMazeGenerator(rng),
      MazeType.circular => CircularMazeGenerator(rng),
      MazeType.triangle => TriangleMazeGenerator(rng),
    };

    _mazeData = generator.generate(
      _isArena ? MazeDifficulty.medium : _difficulty,
      mapIndex: _isArena ? 20 : _mapIndex, // medium map 21 ≈ 15×15
    );
    _currentCellId = _mazeData.startId;
    _traveledPath
      ..clear()
      ..add(_currentCellId);

    _moveCount = 0;
    _mistakes = 0;
    _won = false;
    _finished = false;
    _showHint = false;
    _hintAnimCtrl.reset();

    _remainingTimeSeconds = _isArena
        ? PathFinderConfig.arenaTimeSeconds
        : _difficulty.estimatedSolveTimeSeconds;
    _elapsedSeconds = 0;

    _startTimer();
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished || _won) return;
      setState(() {
        _elapsedSeconds++;
        _remainingTimeSeconds--;
        if (_remainingTimeSeconds <= 0) {
          _remainingTimeSeconds = 0;
          _onTimeExpired();
        }
      });
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _hintAnimCtrl.dispose();
    super.dispose();
  }

  void _moveInDirection(String direction) {
    if (_finished || _won) return;

    final targetCellId = _mazeData.getNeighborInDirection(_currentCellId, direction);

    if (targetCellId == null) {
      // Wall bump feedback
      HapticFeedback.lightImpact();
      AudioService.instance.playSfx(Sfx.wrong);
      setState(() {
        _mistakes++;
      });
      return;
    }

    // Valid open path — revisiting a prior cell trims the trail (moves still count).
    HapticFeedback.selectionClick();
    setState(() {
      _moveCount++;
      final existing = _traveledPath.lastIndexOf(targetCellId);
      if (existing >= 0) {
        _traveledPath.removeRange(existing + 1, _traveledPath.length);
      } else {
        _traveledPath.add(targetCellId);
      }
      _currentCellId = targetCellId;
    });

    if (_currentCellId == _mazeData.endId) {
      _onWin();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_finished || _won) return;

    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;

    if (dx.abs() < 100 && dy.abs() < 100) return;

    if (_type == MazeType.square) {
      if (dx.abs() > dy.abs()) {
        _moveInDirection(dx > 0 ? 'right' : 'left');
      } else {
        _moveInDirection(dy > 0 ? 'down' : 'up');
      }
    } else if (_type == MazeType.circular) {
      if (dx.abs() > dy.abs()) {
        _moveInDirection(dx > 0 ? 'cw' : 'ccw');
      } else {
        _moveInDirection(dy > 0 ? 'out' : 'in');
      }
    } else if (_type == MazeType.triangle) {
      if (dy.abs() > dx.abs()) {
        _moveInDirection('base');
      } else {
        _moveInDirection(dx > 0 ? 'right' : 'left');
      }
    }
  }

  void _toggleHint() {
    if (_finished || _won) return;
    setState(() {
      _showHint = !_showHint;
    });
    if (_showHint) {
      _hintAnimCtrl.repeat(reverse: true);
    } else {
      _hintAnimCtrl.stop();
    }
  }

  void _onWin() {
    if (_won || _finished) return;
    _won = true;
    _clockTimer?.cancel();

    HapticFeedback.mediumImpact();
    AudioService.instance.playSfx(Sfx.puzzleComplete);

    final stars = PathFinderConfig.starsFor(
      completed: true,
      elapsedSeconds: _elapsedSeconds,
      timeLimitSeconds: _difficulty.estimatedSolveTimeSeconds,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MazeWinDialog(
        elapsedSeconds: _elapsedSeconds,
        moveCount: _moveCount,
        optimalMoves: _mazeData.solutionPath.length - 1,
        stars: stars,
        onRetry: () {
          Navigator.of(context).pop();
          _initMaze();
        },
        onContinue: () {
          Navigator.of(context).pop();
          _completeSession(completed: true);
        },
      ),
    );
  }

  void _onTimeExpired() {
    if (_finished || _won) return;
    HapticFeedback.heavyImpact();
    AudioService.instance.playSfx(Sfx.wrong);
    _completeSession(completed: false);
  }

  Future<void> _completeSession({required bool completed}) async {
    if (_finished) return;
    _finished = true;
    _clockTimer?.cancel();

    final score = PathFinderConfig.computeScore(
      completed: completed,
      elapsedSeconds: _elapsedSeconds,
      timeLimitSeconds: _isArena
          ? PathFinderConfig.arenaTimeSeconds
          : _difficulty.estimatedSolveTimeSeconds,
      mistakes: _mistakes,
    );

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.pathFinder,
      score: score,
      accuracy: completed
          ? 1.0
          : (_traveledPath.length / max(1, _mazeData.solutionPath.length)).clamp(0.0, 1.0),
      timeTakenSeconds: _elapsedSeconds,
      correctCount: completed ? 1 : 0,
      totalCount: 1,
      maxScoreOverride: _isArena ? ArenaConfig.maxScorePerRound : PathFinderConfig.maxScore,
    );
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _openTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MazeTypeSelectSheet(
        initialType: _type,
        initialDifficulty: _difficulty,
        initialMapIndex: _mapIndex,
        onStart: (newType, newDiff, newMapIndex) {
          setState(() {
            _type = newType;
            _difficulty = newDiff;
            _mapIndex = newMapIndex;
          });
          _initMaze();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isArena
              ? 'Path Finder · Arena (Hard)'
              : '${_type.displayName} · ${_difficulty.displayName} · Map ${_mapIndex + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Hint Path',
            icon: Icon(
              Icons.lightbulb_outline,
              color: _showHint ? const Color(0xFFFFD700) : Colors.white60,
            ),
            onPressed: _toggleHint,
          ),
          if (!_isArena)
            IconButton(
              tooltip: 'Change Mode',
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: _openTypeSelector,
            ),
          IconButton(
            tooltip: 'Restart',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _initMaze,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top HUD Status Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BadgeInfo(
                    icon: Icons.timer,
                    label: _formatTime(_remainingTimeSeconds),
                    color: _remainingTimeSeconds <= 8
                        ? const Color(0xFFFF5252)
                        : const Color(0xFF00CEC9),
                  ),
                  _BadgeInfo(
                    icon: Icons.directions_walk,
                    label: 'Moves: $_moveCount',
                    color: Colors.white70,
                  ),
                  _BadgeInfo(
                    icon: Icons.warning_amber_rounded,
                    label: 'Bumps: $_mistakes',
                    color: _mistakes > 0 ? Colors.orangeAccent : Colors.white70,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Central Interactive Canvas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GestureDetector(
                      onPanEnd: _handleDragEnd,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF161626),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: AnimatedBuilder(
                            animation: _hintAnimCtrl,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: switch (_type) {
                                  MazeType.square => SquareMazePainter(
                                      mazeData: _mazeData,
                                      currentCellId: _currentCellId,
                                      traveledPath: _traveledPath,
                                      showSolution: _showHint,
                                      solutionAnimationProgress: _hintAnimCtrl.value,
                                      primaryColor: const Color(0xFF6C5CE7),
                                      accentColor: const Color(0xFF00CEC9),
                                      wallColor: Colors.white24,
                                    ),
                                  MazeType.circular => CircularMazePainter(
                                      mazeData: _mazeData,
                                      currentCellId: _currentCellId,
                                      traveledPath: _traveledPath,
                                      showSolution: _showHint,
                                      solutionAnimationProgress: _hintAnimCtrl.value,
                                      primaryColor: const Color(0xFF6C5CE7),
                                      accentColor: const Color(0xFF00CEC9),
                                      wallColor: Colors.white24,
                                    ),
                                  MazeType.triangle => TriangleMazePainter(
                                      mazeData: _mazeData,
                                      currentCellId: _currentCellId,
                                      traveledPath: _traveledPath,
                                      showSolution: _showHint,
                                      solutionAnimationProgress: _hintAnimCtrl.value,
                                      primaryColor: const Color(0xFF6C5CE7),
                                      accentColor: const Color(0xFF00CEC9),
                                      wallColor: Colors.white24,
                                    ),
                                },
                                size: Size.infinite,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Directional Controls Component
            DirectionControls(
              type: _type,
              mazeData: _mazeData,
              currentCellId: _currentCellId,
              onMove: _moveInDirection,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _BadgeInfo extends StatelessWidget {
  const _BadgeInfo({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
