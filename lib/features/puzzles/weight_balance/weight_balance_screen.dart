import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/arena_config.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/models/puzzle_type.dart';
import '../../../data/providers/game_providers.dart';
import '../../../shared/utils/puzzle_feedback.dart';
import '../../../shared/widgets/mindspark_loading_indicator.dart';
import '../puzzle_flow.dart';
import 'weight_balance_config.dart';
import 'weight_balance_daily.dart';
import 'weight_balance_puzzle.dart';

const _labTop = Color(0xFF2A1810);
const _labBottom = Color(0xFF1A1008);
const _amber = Color(0xFFFFB74D);

class WeightBalanceScreen extends ConsumerStatefulWidget {
  const WeightBalanceScreen({super.key});

  @override
  ConsumerState<WeightBalanceScreen> createState() =>
      _WeightBalanceScreenState();
}

class _WeightBalanceScreenState extends ConsumerState<WeightBalanceScreen>
    with TickerProviderStateMixin {
  late final bool _isArena;
  late final List<WeightBalancePuzzle> _puzzles;
  bool _usedDailyPuzzle = false;

  late final AnimationController _beamController;
  late final AnimationController _dropController;
  late final AnimationController _idleController;
  late final AnimationController _feedbackController;

  int _index = 0;
  int _score = 0;
  int _correctCount = 0;
  bool _finished = false;
  bool _locking = false;
  bool _showGoldFlash = false;
  bool _showRedTint = false;
  String _keypadBuffer = '';
  int? _selectedChoice;

  Timer? _puzzleTimer;
  int _secondsLeft = 20;

  late DateTime _sessionStart;
  late DateTime _puzzleStart;
  final List<double> _solveSeconds = [];
  final List<double> _floatPhases = [];

  WeightBalancePuzzle get _puzzle => _puzzles[_index];

  @override
  void initState() {
    super.initState();
    final session = ref.read(puzzleSessionProvider);
    final level = session.practiceDifficulty?.simulatedLevel ??
        ref.read(gameStateProvider).save.player.level;
    final mode = session.mode;
    _isArena = mode == GameMode.arena;

    final diffs = _isArena
        ? WeightBalanceConfig.arenaDifficulties(level)
        : WeightBalanceConfig.sessionDifficulties(level);
    _puzzles = WeightBalanceGenerator().generateSession(diffs);

    // Non-arena: slot today's seeded hard challenge into the session.
    if (!_isArena && _puzzles.length >= 3) {
      _puzzles[2] = WeightBalanceDaily.todaysPuzzle();
      _usedDailyPuzzle = true;
    }

    _beamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _sessionStart = DateTime.now();
    _startPuzzleAnims();
  }

  void _startPuzzleAnims() {
    final rng = math.Random(_index * 97 + 13);
    _floatPhases
      ..clear()
      ..addAll(List.generate(12, (_) => rng.nextDouble() * math.pi * 2));
    _keypadBuffer = '';
    _selectedChoice = null;
    _locking = false;
    _showGoldFlash = false;
    _showRedTint = false;
    _puzzleStart = DateTime.now();
    _dropController.forward(from: 0);
    _beamController.forward(from: 0);
    _startPuzzleTimer();
  }

  void _startPuzzleTimer() {
    _puzzleTimer?.cancel();
    _secondsLeft = _puzzle.difficulty.secondsPerPuzzle;
    _puzzleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished || _locking) return;
      if (_secondsLeft <= 1) {
        _puzzleTimer?.cancel();
        setState(() => _secondsLeft = 0);
        // Timeout = wrong answer (sentinel that never matches).
        _submit(-1);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _puzzleTimer?.cancel();
    _beamController.dispose();
    _dropController.dispose();
    _idleController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit(int value) async {
    if (_finished || _locking) return;
    _puzzleTimer?.cancel();
    setState(() => _locking = true);

    final elapsed =
        DateTime.now().difference(_puzzleStart).inMilliseconds / 1000.0;
    final correct = value == _puzzle.answer;
    playAnswerFeedback(correct);
    _solveSeconds.add(elapsed);

    if (correct) {
      _correctCount++;
      final gained = WeightBalanceConfig.basePointsPerCorrect +
          WeightBalanceConfig.speedBonusFor(elapsed);
      setState(() {
        _score = (_score + gained).clamp(0, WeightBalanceConfig.maxScore);
        _showGoldFlash = true;
        _showRedTint = false;
      });
      _feedbackController.forward(from: 0);
      await Future<void>.delayed(const Duration(milliseconds: 700));
    } else {
      setState(() {
        _showRedTint = true;
        _showGoldFlash = false;
      });
      _feedbackController.forward(from: 0);
      await Future<void>.delayed(const Duration(milliseconds: 750));
    }

    if (!mounted || _finished) return;

    if (_index >= _puzzles.length - 1) {
      await _endGame();
      return;
    }

    setState(() {
      _index++;
      _showGoldFlash = false;
      _showRedTint = false;
    });
    _startPuzzleAnims();
    setState(() {});
  }

  Future<void> _endGame() async {
    if (_finished) return;
    _finished = true;
    setState(() {});

    final timeTaken =
        DateTime.now().difference(_sessionStart).inSeconds.clamp(1, 9999);
    final accuracy = _correctCount / _puzzles.length;

    // Persist seeded daily completion when this session included today's puzzle.
    if (_usedDailyPuzzle) {
      await WeightBalanceDaily.markCompletedToday();
    }

    if (!mounted) return;
    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.weightBalance,
      score: _score,
      accuracy: accuracy,
      timeTakenSeconds: timeTaken,
      correctCount: _correctCount,
      totalCount: _puzzles.length,
      maxScoreOverride:
          _isArena ? ArenaConfig.maxScorePerRound : WeightBalanceConfig.maxScore,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const Scaffold(
        backgroundColor: _labBottom,
        body: Center(child: MindSparkLoadingIndicator(size: 84)),
      );
    }

    final puzzle = _puzzle;

    return Scaffold(
      backgroundColor: _labBottom,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _beamController,
          _dropController,
          _idleController,
          _feedbackController,
        ]),
        builder: (context, _) {
          final flash = _showGoldFlash
              ? Curves.easeOut.transform(
                  (1 - (_feedbackController.value - 0.15).clamp(0.0, 1.0)))
              : 0.0;
          final red = _showRedTint
              ? (1 - _feedbackController.value) * 0.35
              : 0.0;
          final shake = _showRedTint
              ? (1 - _feedbackController.value) *
                  math.sin(_feedbackController.value * math.pi * 8) *
                  0.12
              : 0.0;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(_labTop, AppColors.gold, flash * 0.45)!,
                  Color.lerp(_labBottom, const Color(0xFF4A1010), red)!,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildProgressHeader(puzzle),
                          const SizedBox(height: 4),
                          // Scale shrinks first when space is tight.
                          Expanded(
                            flex: 3,
                            child: _BalanceScaleView(
                              equation: puzzle.equations.first,
                              dropValue: Curves.bounceOut
                                  .transform(_dropController.value),
                              idleValue: _idleController.value,
                              phases: _floatPhases,
                              beamAngle: _beamAngle(shake),
                              goldFlash: flash,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Equations scroll if Hard/Expert has many lines.
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.sizeOf(context).height * 0.16,
                            ),
                            child: SingleChildScrollView(
                              child: _buildEquations(puzzle),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'How much does ${puzzle.askEmoji} weigh?',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          // Answer area: reserved height so buttons never vanish.
                          SizedBox(
                            height: (MediaQuery.sizeOf(context).height * 0.28)
                                .clamp(168.0, 240.0),
                            child: _buildMcq(puzzle),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _beamAngle(double shake) {
    // During drop: tilt toward heavier visual side, then settle level.
    final drop = _dropController.value;
    final settle = Curves.easeOutCubic.transform(_beamController.value);
    final tilt = (1 - settle) * 0.18 * math.sin(drop * math.pi);
    // Correct settle: force level when gold flash is active.
    if (_showGoldFlash) return shake * 0.0;
    return tilt + shake;
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              'Weight Balance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Text(
              '$_score',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(WeightBalancePuzzle puzzle) {
    final total = puzzle.difficulty.secondsPerPuzzle;
    final t = total <= 0 ? 0.0 : (_secondsLeft / total).clamp(0.0, 1.0);
    final urgent = _secondsLeft <= 5;
    final timerColor = urgent
        ? AppColors.error
        : _secondsLeft <= 10
            ? const Color(0xFFFFD54F)
            : AppColors.gold;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Puzzle ${_index + 1}/${_puzzles.length}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _amber.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                puzzle.difficulty.label,
                style: const TextStyle(
                  color: _amber,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: timerColor.withValues(alpha: urgent ? 0.28 : 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: timerColor.withValues(alpha: 0.7),
                  width: urgent ? 1.5 : 1,
                ),
                boxShadow: urgent
                    ? [
                        BoxShadow(
                          color: timerColor.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    urgent ? Icons.timer_off : Icons.timer,
                    size: 16,
                    color: timerColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_secondsLeft}s',
                    style: TextStyle(
                      color: timerColor,
                      fontWeight: FontWeight.w900,
                      fontSize: urgent ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: t,
            minHeight: 6,
            backgroundColor: Colors.white12,
            color: timerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEquations(WeightBalancePuzzle puzzle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final eq in puzzle.equations)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                eq.display,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMcq(WeightBalancePuzzle puzzle) {
    final raw = puzzle.choices;
    final List<int> options;
    if (raw == null || raw.isEmpty) {
      // Safety: never leave the player without answer buttons.
      final a = puzzle.answer;
      options = [a, a + 1, a + 2, (a - 1).clamp(1, 99)]..shuffle();
    } else {
      options = raw;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final n = options.length;
        final maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 200.0;
        final available = (maxH - gap * (n - 1)).clamp(0.0, maxH);
        // Never force buttons taller than the slot — that caused clipping.
        final btnH = n == 0 ? 0.0 : (available / n).clamp(32.0, 52.0);
        final fontSize = btnH >= 48 ? 22.0 : (btnH >= 40 ? 18.0 : 16.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < n; i++) ...[
              if (i > 0) const SizedBox(height: gap),
              SizedBox(
                width: double.infinity,
                height: btnH,
                child: ElevatedButton(
                  onPressed: _locking
                      ? null
                      : () {
                          setState(() => _selectedChoice = options[i]);
                          _submit(options[i]);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedChoice == options[i]
                        ? AppColors.gold.withValues(alpha: 0.35)
                        : const Color(0xFF3A2418),
                    foregroundColor: AppColors.gold,
                    padding: EdgeInsets.zero,
                    side: BorderSide(
                      color: AppColors.gold.withValues(alpha: 0.45),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    '${options[i]}',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          ),
          child: Text(
            _keypadBuffer.isEmpty ? '—' : _keypadBuffer,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.55,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 1; i <= 9; i++) _key(i.toString()),
              _key('⌫', special: true),
              _key('0'),
              _key('OK', special: true, accent: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _key(String label, {bool special = false, bool accent = false}) {
    return Material(
      color: accent
          ? AppColors.gold.withValues(alpha: 0.85)
          : const Color(0xFF3A2418),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _locking
            ? null
            : () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (label == '⌫') {
                    if (_keypadBuffer.isNotEmpty) {
                      _keypadBuffer = _keypadBuffer.substring(
                        0,
                        _keypadBuffer.length - 1,
                      );
                    }
                  } else if (label == 'OK') {
                    if (_keypadBuffer.isEmpty) return;
                    final v = int.tryParse(_keypadBuffer);
                    if (v != null) _submit(v);
                  } else if (_keypadBuffer.length < 3) {
                    _keypadBuffer += label;
                  }
                });
              },
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: accent ? _labBottom : AppColors.gold,
              fontSize: special ? 18 : 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceScaleView extends StatelessWidget {
  const _BalanceScaleView({
    required this.equation,
    required this.dropValue,
    required this.idleValue,
    required this.phases,
    required this.beamAngle,
    required this.goldFlash,
  });

  final WeightEquation equation;
  final double dropValue;
  final double idleValue;
  final List<double> phases;
  final double beamAngle;
  final double goldFlash;

  @override
  Widget build(BuildContext context) {
    final leftItems = _expand(equation.left);
    final rightItems = equation.rightIsNumber
        ? <String>[]
        : _expand(equation.rightEmojis);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (goldFlash > 0.05)
              Container(
                width: w * 0.9,
                height: h * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.35 * goldFlash),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            // Fulcrum
            Positioned(
              bottom: h * 0.08,
              child: CustomPaint(
                size: Size(w * 0.22, h * 0.28),
                painter: _FulcrumPainter(),
              ),
            ),
            // Beam + pans
            Positioned(
              top: h * 0.12,
              child: Transform.rotate(
                angle: beamAngle,
                child: SizedBox(
                  width: w * 0.92,
                  height: h * 0.55,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Beam bar
                      Container(
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB8860B),
                              AppColors.gold,
                              Color(0xFFB8860B),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.35),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // Left pan
                      Positioned(
                        left: 0,
                        top: 18,
                        child: _Pan(
                          items: leftItems,
                          dropValue: dropValue,
                          idleValue: idleValue,
                          phases: phases,
                          phaseOffset: 0,
                          numberLabel: null,
                        ),
                      ),
                      // Right pan
                      Positioned(
                        right: 0,
                        top: 18,
                        child: _Pan(
                          items: rightItems,
                          dropValue: dropValue,
                          idleValue: idleValue,
                          phases: phases,
                          phaseOffset: 4,
                          numberLabel: equation.rightNumber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<String> _expand(Map<String, int> side) {
    final out = <String>[];
    for (final e in side.entries) {
      for (var i = 0; i < e.value && out.length < 6; i++) {
        out.add(e.key);
      }
    }
    return out;
  }
}

class _Pan extends StatelessWidget {
  const _Pan({
    required this.items,
    required this.dropValue,
    required this.idleValue,
    required this.phases,
    required this.phaseOffset,
    required this.numberLabel,
  });

  final List<String> items;
  final double dropValue;
  final double idleValue;
  final List<double> phases;
  final int phaseOffset;
  final int? numberLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chain
        Container(
          width: 2,
          height: 22,
          color: AppColors.gold.withValues(alpha: 0.7),
        ),
        Container(
          width: 110,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF4A3020).withValues(alpha: 0.85),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(48),
              bottomRight: Radius.circular(48),
            ),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: numberLabel != null
                ? _FloatItem(
                    label: '$numberLabel',
                    isNumber: true,
                    dropValue: dropValue,
                    idleValue: idleValue,
                    phase: phases.isEmpty ? 0 : phases[phaseOffset % phases.length],
                  )
                : Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 2,
                    runSpacing: 0,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        _FloatItem(
                          label: items[i],
                          isNumber: false,
                          dropValue: dropValue,
                          idleValue: idleValue,
                          phase: phases.isEmpty
                              ? 0
                              : phases[(phaseOffset + i) % phases.length],
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _FloatItem extends StatelessWidget {
  const _FloatItem({
    required this.label,
    required this.isNumber,
    required this.dropValue,
    required this.idleValue,
    required this.phase,
  });

  final String label;
  final bool isNumber;
  final double dropValue;
  final double idleValue;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final dropY = (1 - dropValue) * -48;
    final floatY = math.sin(idleValue * 2 * math.pi + phase) * 3.5;
    return Transform.translate(
      offset: Offset(0, dropY + floatY),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isNumber ? 26 : 22,
          fontWeight: isNumber ? FontWeight.w800 : FontWeight.w500,
          color: isNumber ? AppColors.gold : null,
        ),
      ),
    );
  }
}

class _FulcrumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD4A017), Color(0xFF8B6914)],
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final rim = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, rim);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
