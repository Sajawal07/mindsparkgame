import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/arena_config.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/models/puzzle_type.dart';
import '../../../data/providers/game_providers.dart';
import '../../../shared/utils/puzzle_feedback.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/mindspark_loading_indicator.dart';
import '../puzzle_flow.dart';
import 'color_brain_config.dart';
import 'color_option.dart';

const _accent = Color(0xFF5B8CFF);
const _navyTop = Color(0xFF0A1628);
const _navyBottom = Color(0xFF000000);

class ColorBrainScreen extends ConsumerStatefulWidget {
  const ColorBrainScreen({super.key});

  @override
  ConsumerState<ColorBrainScreen> createState() => _ColorBrainScreenState();
}

class _ColorBrainScreenState extends ConsumerState<ColorBrainScreen>
    with TickerProviderStateMixin {
  final _rng = Random();

  late final bool _isArena;
  late final int _playerLevel;
  late final int _colorCount;
  late final double _secondsPerWord;
  late final int _wordsPerSession;

  late final AnimationController _timerController;
  late final AnimationController _burstController;
  late final AnimationController _correctPulseController;

  int _wordIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  int _mistakes = 0;
  int _streak = 0;
  int _bestStreak = 0;
  double _combo = 1;
  bool _finished = false;
  bool _lockingInput = false;

  late ColorOption _wordOption;
  late ColorOption _displayOption;
  late List<ColorOption> _choices;

  final List<int> _reactionMs = [];
  late DateTime _wordShownAt;
  late DateTime _sessionStartedAt;

  int _burstSeed = 0;
  double _comboBadgeScale = 1;

  @override
  void initState() {
    super.initState();
    final session = ref.read(puzzleSessionProvider);
    _isArena = session.mode == GameMode.arena;
    _playerLevel = session.practiceDifficulty?.simulatedLevel ??
        ref.read(gameStateProvider).save.player.level;

    final cfg = ColorBrainConfig.forLevel(_playerLevel);
    var colors = cfg['colors'] as int;
    var seconds = (cfg['seconds'] as num).toDouble();
    var words = cfg['wordsPerSession'] as int;

    if (_isArena) {
      // Arena: shorter / snappier rounds.
      colors = colors.clamp(6, 8);
      seconds = min(seconds, 4.0);
      words = min(words, 12);
    }

    _colorCount = colors;
    _secondsPerWord = seconds;
    _wordsPerSession = words;

    _timerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_secondsPerWord * 1000).round()),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_finished) {
          _onTimeout();
        }
      });

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _correctPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _sessionStartedAt = DateTime.now();
    _nextRound(initial: true);
  }

  @override
  void dispose() {
    _timerController.dispose();
    _burstController.dispose();
    _correctPulseController.dispose();
    super.dispose();
  }

  void _nextRound({bool initial = false}) {
    if (!initial && _wordIndex >= _wordsPerSession - 1) {
      _endGame();
      return;
    }

    if (!initial) {
      _wordIndex++;
    }

    final pool = ColorOption.baseSet.take(_colorCount).toList()..shuffle(_rng);
    _displayOption = pool[_rng.nextInt(pool.length)];

    // Word text must NEVER match the ink color (Stroop mismatch).
    final mismatched = pool.where((c) => c != _displayOption).toList();
    _wordOption = mismatched[_rng.nextInt(mismatched.length)];

    // Choices always include the correct ink color.
    final others = pool.where((c) => c != _displayOption).toList()..shuffle(_rng);
    _choices = [_displayOption, ...others.take(_colorCount - 1)]..shuffle(_rng);

    _wordShownAt = DateTime.now();
    _lockingInput = false;
    _timerController
      ..duration = Duration(milliseconds: (_secondsPerWord * 1000).round())
      ..forward(from: 0);

    if (mounted) setState(() {});
  }

  void _onTimeout() {
    if (_finished || _lockingInput) return;
    _lockingInput = true;
    playAnswerFeedback(false);
    setState(() {
      _mistakes++;
      _streak = 0;
      _combo = 1;
    });
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted || _finished) return;
      _nextRound();
    });
  }

  void _onChoice(ColorOption choice) {
    if (_finished || _lockingInput) return;
    _lockingInput = true;
    _timerController.stop();

    final elapsedMs =
        DateTime.now().difference(_wordShownAt).inMilliseconds.clamp(0, 60000);
    final remainingFraction =
        (1.0 - _timerController.value).clamp(0.05, 1.0);
    final correct = choice.color == _displayOption.color;

    playAnswerFeedback(correct);

    if (correct) {
      _reactionMs.add(elapsedMs);
      _correctCount++;
      _streak++;
      if (_streak > _bestStreak) _bestStreak = _streak;
      final nextCombo = ColorBrainConfig.comboMultiplier(_streak);
      final gained = (ColorBrainConfig.basePoints * nextCombo * remainingFraction)
          .round()
          .clamp(1, 80);
      setState(() {
        _combo = nextCombo;
        _score = (_score + gained).clamp(0, 300);
        _comboBadgeScale = 1.35;
        _burstSeed = _rng.nextInt(1 << 30);
      });
      _burstController.forward(from: 0);
      _correctPulseController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 160), () {
        if (mounted) setState(() => _comboBadgeScale = 1);
      });
    } else {
      setState(() {
        _mistakes++;
        _streak = 0;
        _combo = 1;
      });
    }

    Future.delayed(Duration(milliseconds: correct ? 320 : 220), () {
      if (!mounted || _finished) return;
      _nextRound();
    });
  }

  Future<void> _endGame() async {
    if (_finished) return;
    _finished = true;
    _timerController.stop();
    if (mounted) setState(() {});

    final total = _wordsPerSession;
    final accuracy = total == 0 ? 0.0 : _correctCount / total;
    final timeTaken =
        DateTime.now().difference(_sessionStartedAt).inSeconds.clamp(1, 9999);

    await finishPuzzleAndShowResult(
      context: context,
      ref: ref,
      type: PuzzleType.colorBrain,
      score: _score.clamp(0, 300),
      accuracy: accuracy,
      timeTakenSeconds: timeTaken,
      correctCount: _correctCount,
      totalCount: total,
      maxScoreOverride: _isArena ? ArenaConfig.maxScorePerRound : 300,
    );
  }

  double get _avgReactionMs {
    if (_reactionMs.isEmpty) return 0;
    return _reactionMs.reduce((a, b) => a + b) / _reactionMs.length;
  }

  String get _comboLabel {
    if (_combo >= 5) return 'x5';
    if (_combo >= 2) return 'x2';
    return 'x1';
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const GradientScaffold(
        body: Center(child: MindSparkLoadingIndicator(size: 84)),
      );
    }

    return Scaffold(
      backgroundColor: _navyBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_navyTop, _navyBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                _buildTopBar(context),
                const SizedBox(height: 28),
                Expanded(child: _buildWordArea()),
                const SizedBox(height: 12),
                Text(
                  'Tap the INK color — not the word',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSwatches(),
                const SizedBox(height: 8),
                Text(
                  'Word ${_wordIndex + 1}/$_wordsPerSession'
                  '${_mistakes > 0 ? '  ·  Mistakes $_mistakes' : ''}'
                  '${_bestStreak > 0 ? '  ·  Best $_bestStreak' : ''}'
                  '${_reactionMs.isNotEmpty ? '  ·  ${_avgReactionMs.round()}ms' : ''}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, color: Colors.white70),
          tooltip: 'Exit',
        ),
        _TopChip(
          label: 'Lv $_playerLevel',
          color: _accent.withValues(alpha: 0.25),
          textColor: _accent,
        ),
        const Spacer(),
        AnimatedBuilder(
          animation: _timerController,
          builder: (context, _) {
            final t = 1.0 - _timerController.value;
            return _TimerRing(
              progress: t.clamp(0.0, 1.0),
              secondsLeft: (_secondsPerWord * t).ceil().clamp(0, 99),
            );
          },
        ),
        const Spacer(),
        _TopChip(
          label: '$_score',
          color: Colors.white.withValues(alpha: 0.08),
          textColor: Colors.white,
          icon: Icons.bolt_rounded,
        ),
        const SizedBox(width: 8),
        AnimatedScale(
          scale: _comboBadgeScale,
          duration: const Duration(milliseconds: 420),
          curve: Curves.elasticOut,
          child: _ComboBadge(label: _comboLabel, combo: _combo),
        ),
      ],
    );
  }

  Widget _buildWordArea() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_burstController, _correctPulseController]),
          builder: (context, _) {
            return CustomPaint(
              painter: _ParticleBurstPainter(
                progress: _burstController.value,
                seed: _burstSeed,
              ),
              size: const Size(280, 280),
            );
          },
        ),
        ScaleTransition(
          scale: TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween(begin: 1.0, end: 1.28)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 40,
            ),
            TweenSequenceItem(
              tween: Tween(begin: 1.28, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeIn)),
              weight: 60,
            ),
          ]).animate(_correctPulseController),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            // Keep linear here — easeOutBack is applied once below.
            // Double-curving easeOutBack feeds t>1 into Curve.transform and asserts.
            switchInCurve: Curves.linear,
            switchOutCurve: Curves.linear,
            transitionBuilder: (child, animation) {
              final scale = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
                reverseCurve: Curves.easeIn,
              );
              final fade = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
                reverseCurve: Curves.easeIn,
              );
              return FadeTransition(
                opacity: fade,
                child: ScaleTransition(scale: scale, child: child),
              );
            },
            child: Text(
              _wordOption.name.toUpperCase(),
              key: ValueKey('word-$_wordIndex-${_wordOption.name}'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _displayOption.color,
                fontSize: 54,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.4,
                height: 1.05,
                shadows: [
                  Shadow(
                    color: _displayOption.color.withValues(alpha: 0.35),
                    blurRadius: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwatches() {
    final crossAxisCount = _colorCount <= 4 ? 2 : (_colorCount <= 6 ? 3 : 4);
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 10.0;
        final cols = crossAxisCount;
        final rows = (_colorCount / cols).ceil();
        final tileW =
            (constraints.maxWidth - gap * (cols - 1)) / cols;
        final tileH = 56.0;
        return SizedBox(
          height: rows * tileH + (rows - 1) * gap,
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: _choices.map((option) {
              return SizedBox(
                width: tileW,
                height: tileH,
                child: _ColorSwatchButton(
                  option: option,
                  onTap: () => _onChoice(option),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _TopChip extends StatelessWidget {
  const _TopChip({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComboBadge extends StatelessWidget {
  const _ComboBadge({required this.label, required this.combo});

  final String label;
  final double combo;

  @override
  Widget build(BuildContext context) {
    final hot = combo >= 2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: hot
              ? const [Color(0xFFFF9100), Color(0xFFFF5252)]
              : [
                  _accent.withValues(alpha: 0.35),
                  _accent.withValues(alpha: 0.15),
                ],
        ),
        boxShadow: hot
            ? [
                BoxShadow(
                  color: const Color(0xFFFF9100).withValues(alpha: 0.35),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({required this.progress, required this.secondsLeft});

  final double progress;
  final int secondsLeft;

  Color get _ringColor {
    if (progress > 0.55) return const Color(0xFF69F0AE);
    if (progress > 0.28) return const Color(0xFFFFD740);
    return const Color(0xFFFF5252);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(
        painter: _TimerRingPainter(progress: progress, color: _ringColor),
        child: Center(
          child: Text(
            '$secondsLeft',
            style: TextStyle(
              color: _ringColor,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 3;
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _ColorSwatchButton extends StatelessWidget {
  const _ColorSwatchButton({required this.option, required this.onTap});

  final ColorOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = option.color.computeLuminance() > 0.55;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: option.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: option.color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Center(
            child: Text(
              option.name,
              style: TextStyle(
                color: isLight ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticleBurstPainter extends CustomPainter {
  _ParticleBurstPainter({required this.progress, required this.seed});

  final double progress;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final rng = Random(seed);
    final center = Offset(size.width / 2, size.height / 2);
    final t = Curves.easeOut.transform(progress);

    for (var i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi + rng.nextDouble() * 0.35;
      final dist = 28 + rng.nextDouble() * 70;
      final pos = center + Offset(cos(angle), sin(angle)) * dist * t;
      final radius = (3.5 + rng.nextDouble() * 3.5) * (1 - t * 0.65);
      final paint = Paint()
        ..color = Color.lerp(
          _accent,
          const Color(0xFF18FFFF),
          rng.nextDouble(),
        )!
            .withValues(alpha: (1 - t) * 0.9);
      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleBurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.seed != seed;
}
