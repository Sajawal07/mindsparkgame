import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/arena_config.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/models/puzzle_type.dart';
import '../../../data/providers/game_providers.dart';
import '../../../data/services/audio_service.dart';
import '../../../shared/utils/puzzle_feedback.dart';
import '../puzzle_flow.dart';
import 'cup_shuffle_config.dart';

enum _Phase {
  showingBall,
  covering,
  shuffling,
  guessing,
  revealing,
  betweenRounds,
}

class CupShuffleScreen extends ConsumerStatefulWidget {
  const CupShuffleScreen({super.key});

  @override
  ConsumerState<CupShuffleScreen> createState() => _CupShuffleScreenState();
}

class _CupShuffleScreenState extends ConsumerState<CupShuffleScreen>
    with TickerProviderStateMixin {
  final _rng = Random();

  late final bool _isArena;
  late final CupShuffleSettings _settings;
  late final DateTime _sessionStart;

  /// Slot index → cup identity.
  late List<int> _cupsInSlots;

  /// Cup identity that hides the ball.
  late int _ballCupId;

  int _roundIndex = 0;
  int _score = 0;
  int _wins = 0;
  int _guesses = 0;
  int _streak = 0;
  bool _finished = false;

  _Phase _phase = _Phase.showingBall;
  String? _feedback;

  /// Per-cup visual offsets during swap / reveal.
  late List<double> _dx;
  late List<double> _dy;
  late List<double> _rotation;
  late List<double> _shakeX;

  int? _glowCupId;
  bool _showBall = true;
  bool _oops = false;

  AnimationController? _activeController;
  double _slotSpacing = 72;

  static const _woodColors = [
    Color(0xFF6B4423),
    Color(0xFF4A2F1A),
    Color(0xFF3E2723),
    Color(0xFF5D4037),
  ];

  static const _ballColor = Color(0xFFE53935);
  static const _ballGlow = Color(0xFFFF8A80);

  @override
  void initState() {
    super.initState();
    final session = ref.read(puzzleSessionProvider);
    _isArena = session.mode == GameMode.arena;
    final level = session.practiceDifficulty?.simulatedLevel ??
        ref.read(gameStateProvider).save.player.level;
    _settings = CupShuffleConfig.forPlayer(level, isArena: _isArena);
    _sessionStart = DateTime.now();
    _initVisualArrays();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startRound();
    });
  }

  void _initVisualArrays() {
    final n = _settings.cupCount;
    _cupsInSlots = List.generate(n, (i) => i);
    _dx = List.filled(n, 0);
    _dy = List.filled(n, 0);
    _rotation = List.filled(n, 0);
    _shakeX = List.filled(n, 0);
    _ballCupId = 0;
  }

  @override
  void dispose() {
    _activeController?.dispose();
    super.dispose();
  }

  Future<void> _startRound() async {
    if (_finished || !mounted) return;

    final n = _settings.cupCount;
    _cupsInSlots = List.generate(n, (i) => i);
    for (var i = 0; i < n; i++) {
      _dx[i] = 0;
      _dy[i] = 0;
      _rotation[i] = 0;
      _shakeX[i] = 0;
    }
    _ballCupId = _rng.nextInt(n);
    _glowCupId = null;
    _oops = false;
    _feedback = null;
    _showBall = true;

    // Cups lifted so ball is visible.
    AudioService.instance.playSoftTap();
    setState(() {
      _phase = _Phase.showingBall;
      for (var i = 0; i < n; i++) {
        _dy[i] = -40;
      }
    });

    await Future.delayed(
      const Duration(milliseconds: CupShuffleConfig.ballRevealMs),
    );
    if (!mounted || _finished) return;

    // Cover: lower cups over the ball.
    setState(() => _phase = _Phase.covering);
    final cover = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: CupShuffleConfig.coverMs),
    );
    _activeController = cover;
    final lower = Tween<double>(begin: -40, end: 0).animate(
      CurvedAnimation(parent: cover, curve: Curves.easeInOutCubic),
    );
    void coverTick() {
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < n; i++) {
          _dy[i] = lower.value;
        }
      });
    }

    cover.addListener(coverTick);
    await cover.forward();
    cover.removeListener(coverTick);
    cover.dispose();
    if (_activeController == cover) _activeController = null;
    if (!mounted || _finished) return;

    setState(() {
      _showBall = false;
      for (var i = 0; i < n; i++) {
        _dy[i] = 0;
      }
      _phase = _Phase.shuffling;
    });

    await _runShuffle();
    if (!mounted || _finished) return;

    setState(() {
      _phase = _Phase.guessing;
      _feedback = 'Which cup hides the ball?';
    });
  }

  List<({int a, int b, bool feint})> _buildSwapPlan() {
    final n = _settings.cupCount;
    final plan = <({int a, int b, bool feint})>[];
    for (var i = 0; i < _settings.swapCount; i++) {
      late int a;
      late int b;
      // Prefer adjacent swaps for a hand-shuffled look.
      if (_rng.nextDouble() < 0.75 || n <= 2) {
        a = _rng.nextInt(n - 1);
        b = a + 1;
      } else {
        a = _rng.nextInt(n);
        do {
          b = _rng.nextInt(n);
        } while (b == a);
        if (a > b) {
          final t = a;
          a = b;
          b = t;
        }
      }
      final feint = _settings.includesFeints &&
          _rng.nextDouble() < CupShuffleConfig.feintChance;
      plan.add((a: a, b: b, feint: feint));
    }
    return plan;
  }

  Curve _randomCurve() {
    const curves = [
      Curves.easeInOutCubic,
      Curves.easeInOutQuart,
      Curves.fastOutSlowIn,
    ];
    return curves[_rng.nextInt(curves.length)];
  }

  int _swapDurationMs() {
    if (_settings.randomSpeed) {
      return CupShuffleConfig.swapDurationMinMs +
          _rng.nextInt(
            CupShuffleConfig.swapDurationMaxMs -
                CupShuffleConfig.swapDurationMinMs +
                1,
          );
    }
    return _settings.baseDurationMs;
  }

  int _pauseMs() =>
      CupShuffleConfig.swapPauseMinMs +
      _rng.nextInt(
        CupShuffleConfig.swapPauseMaxMs - CupShuffleConfig.swapPauseMinMs + 1,
      );

  Future<void> _runShuffle() async {
    final plan = _buildSwapPlan();
    for (final step in plan) {
      if (!mounted || _finished) return;
      await _animateSwap(step.a, step.b, feint: step.feint);
      if (!mounted || _finished) return;
      await Future.delayed(Duration(milliseconds: _pauseMs()));
    }
  }

  Future<void> _animateSwap(int slotA, int slotB, {required bool feint}) async {
    final cupA = _cupsInSlots[slotA];
    final cupB = _cupsInSlots[slotB];
    final deltaX = (slotB - slotA) * _slotSpacing;
    final curve = _randomCurve();
    final durationMs =
        feint ? (_swapDurationMs() * 0.65).round() : _swapDurationMs();

    AudioService.instance.playWhoosh();

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    _activeController = controller;

    if (feint) {
      // Lift slightly, return — no horizontal swap.
      final lift = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: CupShuffleConfig.feintLiftPx)
              .chain(CurveTween(curve: curve)),
          weight: 45,
        ),
        TweenSequenceItem(
          tween: Tween(begin: CupShuffleConfig.feintLiftPx, end: 0.0)
              .chain(CurveTween(curve: curve)),
          weight: 55,
        ),
      ]).animate(controller);

      void tick() {
        if (!mounted) return;
        setState(() {
          _dy[cupA] = lift.value;
          _dy[cupB] = lift.value;
        });
      }

      controller.addListener(tick);
      await controller.forward();
      controller.removeListener(tick);
    } else {
      // Interval-staggered: lift → arc translateX → lower.
      final liftY = Tween<double>(begin: 0.0, end: CupShuffleConfig.liftPx)
          .animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.28, curve: curve),
      ));
      final lowerY = Tween<double>(begin: 0.0, end: CupShuffleConfig.liftPx)
          .animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.72, 1.0, curve: curve),
      ));
      final shiftT = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(0.20, 0.78, curve: curve),
        ),
      );
      // Slight mid-arc bump for hand-shuffled feel.
      final arcBump = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.28, 0.72, curve: Curves.easeOut),
        ),
      );

      void tick() {
        if (!mounted) return;
        final y = liftY.value - lowerY.value;
        final bump = -6.0 * sin(arcBump.value * pi);
        final t = shiftT.value;
        setState(() {
          _dy[cupA] = y + bump;
          _dy[cupB] = y + bump;
          _dx[cupA] = deltaX * t;
          _dx[cupB] = -deltaX * t;
        });
      }

      controller.addListener(tick);
      await controller.forward();
      controller.removeListener(tick);

      // Commit logical swap once the motion finishes.
      final tmp = _cupsInSlots[slotA];
      _cupsInSlots[slotA] = _cupsInSlots[slotB];
      _cupsInSlots[slotB] = tmp;
    }

    controller.dispose();
    if (_activeController == controller) _activeController = null;

    if (!mounted) return;
    setState(() {
      _dx[cupA] = 0;
      _dx[cupB] = 0;
      _dy[cupA] = 0;
      _dy[cupB] = 0;
    });
  }

  Future<void> _onCupTap(int slot) async {
    if (_phase != _Phase.guessing || _finished) return;

    final cupId = _cupsInSlots[slot];
    final correct = cupId == _ballCupId;

    AudioService.instance.playSoftTap();
    setState(() {
      _phase = _Phase.revealing;
      _showBall = true;
      _feedback = null;
    });
    _guesses++;

    playAnswerFeedback(correct);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _activeController = controller;

    if (correct) {
      final lift = Tween<double>(begin: 0.0, end: -48.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
        ),
      );
      final rot = Tween<double>(begin: 0.0, end: -0.12).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
        ),
      );

      void tick() {
        if (!mounted) return;
        setState(() {
          _dy[cupId] = lift.value;
          _rotation[cupId] = rot.value;
          _glowCupId = cupId;
        });
      }

      controller.addListener(tick);
      await controller.forward();
      controller.removeListener(tick);

      _wins++;
      _streak++;
      final nextScore =
          (_score + _settings.pointsPerWin).clamp(0, CupShuffleConfig.maxScore);
      setState(() {
        _score = nextScore;
        _feedback = 'Nice catch!';
      });
    } else {
      // Shake + Oops! for empty cup; still lift to show empty.
      final lift = Tween<double>(begin: 0.0, end: -36.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
        ),
      );
      final shake = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -10.0, end: 8.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
      ]).animate(CurvedAnimation(
        parent: controller,
        curve: const Interval(0.15, 0.95, curve: Curves.linear),
      ));
      final rot = Tween<double>(begin: 0.0, end: 0.08).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
        ),
      );

      void tick() {
        if (!mounted) return;
        setState(() {
          _dy[cupId] = lift.value;
          _shakeX[cupId] = shake.value;
          _rotation[cupId] = rot.value;
          _oops = true;
          _feedback = 'Oops!';
        });
      }

      controller.addListener(tick);
      await controller.forward();
      controller.removeListener(tick);

      _streak = 0;

      // Briefly reveal the real ball cup.
      if (mounted) {
        setState(() {
          _dy[_ballCupId] = -40;
          _glowCupId = _ballCupId;
        });
      }
    }

    controller.dispose();
    if (_activeController == controller) _activeController = null;

    await Future.delayed(
      const Duration(milliseconds: CupShuffleConfig.revealHoldMs),
    );
    if (!mounted || _finished) return;

    final lastRound = _roundIndex >= CupShuffleConfig.roundsPerSession - 1;
    if (lastRound) {
      await _finishSession();
      return;
    }

    setState(() {
      _phase = _Phase.betweenRounds;
      _roundIndex++;
      _oops = false;
      _feedback = 'Round ${_roundIndex + 1}';
    });

    await Future.delayed(
      const Duration(milliseconds: CupShuffleConfig.betweenRoundsMs),
    );
    if (!mounted || _finished) return;
    await _startRound();
  }

  Future<void> _finishSession() async {
    if (_finished) return;
    _finished = true;
    _activeController?.dispose();
    _activeController = null;

    final elapsed = DateTime.now().difference(_sessionStart).inSeconds;
    final total = CupShuffleConfig.roundsPerSession;
    final accuracy = total == 0 ? 0.0 : _wins / total;

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.cupShuffle,
      score: _score.clamp(0, CupShuffleConfig.maxScore),
      accuracy: accuracy,
      timeTakenSeconds: elapsed > 0 ? elapsed : 1,
      correctCount: _wins,
      totalCount: total,
      maxScoreOverride:
          _isArena ? ArenaConfig.maxScorePerRound : null,
    );
  }

  int _slotOfCup(int cupId) => _cupsInSlots.indexOf(cupId);

  @override
  Widget build(BuildContext context) {
    final winPct =
        _guesses == 0 ? 0 : ((_wins / _guesses) * 100).round().clamp(0, 100);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isArena ? 'Cup Shuffle — Arena' : 'Cup Shuffle',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _woodColors,
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _StatusBar(
                  round: _roundIndex + 1,
                  totalRounds: CupShuffleConfig.roundsPerSession,
                  score: _score,
                  maxScore: CupShuffleConfig.maxScore,
                  streak: _streak,
                  difficulty: _settings.label,
                  winPct: winPct,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedOpacity(
                opacity: _feedback != null ? 1 : 0.55,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _feedback ??
                      switch (_phase) {
                        _Phase.showingBall => 'Watch the ball…',
                        _Phase.covering => 'Covering…',
                        _Phase.shuffling => 'Follow carefully…',
                        _Phase.guessing => 'Tap a cup',
                        _Phase.revealing => '',
                        _Phase.betweenRounds => 'Next round…',
                      },
                  style: TextStyle(
                    color: _oops
                        ? const Color(0xFFFFCDD2)
                        : Colors.white.withValues(alpha: 0.92),
                    fontSize: _oops ? 28 : 18,
                    fontWeight: _oops ? FontWeight.w800 : FontWeight.w500,
                    letterSpacing: _oops ? 1.2 : 0.2,
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final n = _settings.cupCount;
                    final maxW = constraints.maxWidth;
                    _slotSpacing = (maxW * 0.82) / n;
                    final cupW = (_slotSpacing * 0.72).clamp(48.0, 78.0);
                    final cupH = cupW * 1.25;
                    final tableW = _slotSpacing * n;
                    final originX = (maxW - tableW) / 2 + _slotSpacing / 2;

                    return Center(
                      child: SizedBox(
                        width: maxW,
                        height: cupH + 120,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Soft table sheen.
                            Positioned(
                              left: 24,
                              right: 24,
                              bottom: 18,
                              height: 28,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.0),
                                      Colors.black.withValues(alpha: 0.28),
                                      Colors.black.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Ball under the ball cup's current slot.
                            if (_showBall)
                              Builder(
                                builder: (_) {
                                  final slot = _slotOfCup(_ballCupId);
                                  if (slot < 0) return const SizedBox.shrink();
                                  final ballSize = cupW * 0.38;
                                  final cx = originX +
                                      slot * _slotSpacing +
                                      _dx[_ballCupId] +
                                      _shakeX[_ballCupId];
                                  return Positioned(
                                    left: cx - ballSize / 2,
                                    bottom: 42,
                                    child: _Ball(
                                      size: ballSize,
                                      color: _ballColor,
                                      glow: _ballGlow,
                                      glowing: _glowCupId == _ballCupId,
                                    ),
                                  );
                                },
                              ),
                            // Cups (draw by cup identity so transforms stick).
                            for (var cupId = 0; cupId < n; cupId++)
                              Builder(
                                builder: (_) {
                                  final slot = _slotOfCup(cupId);
                                  final cx = originX +
                                      slot * _slotSpacing +
                                      _dx[cupId] +
                                      _shakeX[cupId];
                                  final canTap = _phase == _Phase.guessing;
                                  return Positioned(
                                    left: cx - cupW / 2,
                                    bottom: 36 + (-_dy[cupId]),
                                    child: Transform.rotate(
                                      angle: _rotation[cupId],
                                      alignment: Alignment.bottomCenter,
                                      child: GestureDetector(
                                        onTap: canTap
                                            ? () => _onCupTap(slot)
                                            : null,
                                        child: _GlassCup(
                                          width: cupW,
                                          height: cupH,
                                          glowing: _glowCupId == cupId,
                                          highlighted: canTap,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '${_settings.cupCount} cups · ${_settings.swapCount} swaps'
                  '${_settings.includesFeints ? ' · feints' : ''}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.round,
    required this.totalRounds,
    required this.score,
    required this.maxScore,
    required this.streak,
    required this.difficulty,
    required this.winPct,
  });

  final int round;
  final int totalRounds;
  final int score;
  final int maxScore;
  final int streak;
  final String difficulty;
  final int winPct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          _chip('R$round/$totalRounds'),
          const SizedBox(width: 8),
          _chip('$score/$maxScore'),
          const Spacer(),
          _chip('$winPct%'),
          const SizedBox(width: 8),
          _chip('🔥$streak'),
          const SizedBox(width: 8),
          _chip(difficulty),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.88),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}


class _Ball extends StatelessWidget {
  const _Ball({
    required this.size,
    required this.color,
    required this.glow,
    required this.glowing,
  });

  final double size;
  final Color color;
  final Color glow;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.85),
            color,
            color.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.45, 1.0],
          center: const Alignment(-0.3, -0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: glowing ? 0.85 : 0.45),
            blurRadius: glowing ? 22 : 10,
            spreadRadius: glowing ? 4 : 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

class _GlassCup extends StatelessWidget {
  const _GlassCup({
    required this.width,
    required this.height,
    required this.glowing,
    required this.highlighted,
  });

  final double width;
  final double height;
  final bool glowing;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: height,
      child: CustomPaint(
        painter: _GlassCupPainter(
          glowing: glowing,
          highlighted: highlighted,
        ),
        child: ClipPath(
          clipper: _CupClipper(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _CupClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.12, 0)
      ..lineTo(w * 0.88, 0)
      ..lineTo(w * 0.78, h * 0.92)
      ..quadraticBezierTo(w * 0.5, h, w * 0.22, h * 0.92)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _GlassCupPainter extends CustomPainter {
  _GlassCupPainter({required this.glowing, required this.highlighted});

  final bool glowing;
  final bool highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.12, 0)
      ..lineTo(w * 0.88, 0)
      ..lineTo(w * 0.78, h * 0.92)
      ..quadraticBezierTo(w * 0.5, h, w * 0.22, h * 0.92)
      ..close();

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.save();
    canvas.translate(0, 6);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.38),
          const Color(0xFFB0BEC5).withValues(alpha: 0.22),
          const Color(0xFF78909C).withValues(alpha: 0.28),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fill);

    if (glowing) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawPath(path, glowPaint);
    }

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white.withValues(alpha: highlighted ? 0.7 : 0.45);
    canvas.drawPath(path, rim);

    // Inner glass highlight streak.
    final highlight = Path()
      ..moveTo(w * 0.22, h * 0.08)
      ..lineTo(w * 0.30, h * 0.08)
      ..lineTo(w * 0.26, h * 0.72)
      ..lineTo(w * 0.20, h * 0.72)
      ..close();
    canvas.drawPath(
      highlight,
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );

    // Base ellipse shadow under cup mouth (top rim depth).
    final rimOval = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.04),
      width: w * 0.72,
      height: h * 0.08,
    );
    canvas.drawOval(
      rimOval,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _GlassCupPainter oldDelegate) =>
      oldDelegate.glowing != glowing || oldDelegate.highlighted != highlighted;
}
