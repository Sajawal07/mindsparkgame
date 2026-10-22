import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/home_level_up.dart';
import '../../core/utils/level_config.dart';
import '../../data/models/blitz_question.dart';
import '../../data/providers/game_providers.dart';
import '../../data/providers/network_provider.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/blitz_question_engine.dart';
import '../../data/services/brain_score_service.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/network/no_internet_view.dart';

class BlitzModeScreen extends ConsumerStatefulWidget {
  const BlitzModeScreen({super.key});

  @override
  ConsumerState<BlitzModeScreen> createState() => _BlitzModeScreenState();
}

class _BlitzModeScreenState extends ConsumerState<BlitzModeScreen> {
  static const _durationSeconds = 60;

  Timer? _timer;
  int _remaining = _durationSeconds;
  int _score = 0;
  int _streak = 0;
  int _multiplier = 1;
  bool _playing = false;
  bool _finished = false;
  late BlitzQuestion _question;
  final _engine = BlitzQuestionEngine();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    LevelConfig.setPlayerLevel(ref.read(gameStateProvider).save.player.level);
    setState(() {
      _playing = true;
      _finished = false;
      _remaining = _durationSeconds;
      _score = 0;
      _streak = 0;
      _multiplier = 1;
      _question = _engine.generate();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 5 && _remaining > 0) {
        AudioService.instance.playSfx(Sfx.blitzCountdown);
      }
      setState(() {
        _remaining--;
        if (_remaining <= 0) _endBlitz();
      });
    });
  }

  void _onAnswer(int choiceIndex) {
    if (!_playing || _finished) return;
    final correct = choiceIndex == _question.correctIndex;
    if (correct) {
      _streak++;
      _updateMultiplier();
      setState(() {
        _score += 10 * _multiplier;
        _question = _engine.generate();
      });
      AudioService.instance.playSfx(Sfx.correct);
    } else {
      _streak = 0;
      _multiplier = 1;
      setState(() => _question = _engine.generate());
      AudioService.instance.playSfx(Sfx.wrong);
    }
  }

  void _updateMultiplier() {
    final prev = _multiplier;
    _multiplier = BlitzQuestionEngine.multiplierForStreak(_streak);
    if (_multiplier > prev) {
      AudioService.instance.playSfx(Sfx.blitzMultiplier);
    }
  }

  Color _multiplierColor() => switch (_multiplier) {
        5 => AppColors.gold,
        3 => Colors.orange,
        2 => AppColors.accent,
        _ => Colors.white70,
      };

  String _multiplierAsset() => switch (_multiplier) {
        5 => AppAssets.blitzMultiplierX5,
        3 => AppAssets.blitzMultiplierX3,
        2 => AppAssets.blitzMultiplierX2,
        _ => AppAssets.blitzMultiplierX1,
      };

  Future<void> _endBlitz() async {
    if (_finished) return;
    _finished = true;
    _playing = false;
    _timer?.cancel();
    final result = await ref.read(gameStateProvider).completeBlitzSession(_score);
    await AudioService.instance.playSfx(Sfx.puzzleComplete);
    if (result.coinsEarned > 0) {
      await AudioService.instance.playSfx(Sfx.coin);
    }
    if (result.beatAllTimeBest) {
      await AudioService.instance.playSfx(Sfx.achievement);
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Blitz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${result.score}',
              style: Theme.of(ctx).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              result.motivationalMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: result.beatAllTimeBest ? AppColors.gold : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text('+${result.coinsEarned} coins'),
            Text('+${result.xpEarned} XP'),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final rank = BrainScoreService.simulateIqForRound(
                  score: result.score,
                  maxScore: 500, // Roughly an Einstein level benchmark for Blitz
                );
                return Column(
                  children: [
                    Text(
                      rank.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Estimated IQ: ${rank.iqEstimate}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rank.comparison,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
              scheduleHomeLevelUpCheck(context, ref);
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _start();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    if (!isOnline) {
      return GradientScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
          title: const Text('Blitz Mode'),
        ),
        body: const NoInternetView(
          featureName: 'Blitz Mode',
          customMessage: 'Blitz Mode requires an active internet connection to submit scores and record multipliers.',
          showPracticeOption: true,
        ),
      );
    }

    final player = ref.watch(gameStateProvider).save.player;

    if (!_playing && !_finished) {
      return _BlitzLobby(
        allTimeBest: player.blitzAllTimeBest,
        todayBest: player.blitzTodayBest,
        lastRun: player.blitzLastScore,
        onStart: _start,
      );
    }

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _timer?.cancel();
            context.pop();
          },
        ),
        title: const Text('Blitz'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.blitzBackground,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          Container(color: Colors.black.withValues(alpha: 0.5)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _PersonalBestRow(
                  allTime: player.blitzAllTimeBest,
                  today: player.blitzTodayBest,
                  lastRun: player.blitzLastScore,
                ),
                const SizedBox(height: 12),
                Text(
                  '$_remaining',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: _remaining <= 10 ? AppColors.error : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'seconds',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: $_score',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _multiplierColor().withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _multiplierColor()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        _multiplierAsset(),
                        height: 28,
                        errorBuilder: (_, __, ___) =>
                            Text('x$_multiplier', style: TextStyle(color: _multiplierColor())),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Streak: $_streak',
                        style: TextStyle(color: _multiplierColor()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _question.type.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.accent,
                      ),
                ),
                const Spacer(),
                _QuestionArea(question: _question, onAnswer: _onAnswer),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionArea extends StatelessWidget {
  const _QuestionArea({required this.question, required this.onAnswer});

  final BlitzQuestion question;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    if (question.type == BlitzGameType.patternIq &&
        question.sequence != null) {
      return Column(
        children: [
          Wrap(
            spacing: 8,
            children: question.sequence!
                .map(
                  (s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 20)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
          ..._choiceButtons(context),
        ],
      );
    }

    if (question.type == BlitzGameType.focusFind &&
        question.gridIcons != null) {
      final cols = question.gridIcons!.length == 16 ? 4 : 3;
      return Column(
        children: [
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: question.gridIcons!.length,
            itemBuilder: (context, index) {
              return ElevatedButton(
                onPressed: () => onAnswer(index),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: question.gridColors![index].withValues(alpha: 0.3),
                ),
                child: Icon(
                  question.gridIcons![index],
                  color: question.gridColors![index],
                  size: 32,
                ),
              );
            },
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          question.prompt,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ..._choiceButtons(context),
      ],
    );
  }

  List<Widget> _choiceButtons(BuildContext context) {
    return question.choices.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ElevatedButton(
          onPressed: () => onAnswer(entry.key),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
          child: Text(
            entry.value,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
    }).toList();
  }
}

class _PersonalBestRow extends StatelessWidget {
  const _PersonalBestRow({
    required this.allTime,
    required this.today,
    required this.lastRun,
  });

  final int allTime;
  final int today;
  final int lastRun;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _BestChip(label: 'All Time', value: allTime),
        _BestChip(label: 'Today', value: today),
        _BestChip(label: 'Last Run', value: lastRun),
      ],
    );
  }
}

class _BestChip extends StatelessWidget {
  const _BestChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white60,
              ),
        ),
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _BlitzLobby extends StatelessWidget {
  const _BlitzLobby({
    required this.allTimeBest,
    required this.todayBest,
    required this.lastRun,
    required this.onStart,
  });

  final int allTimeBest;
  final int todayBest;
  final int lastRun;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Blitz Mode')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.blitzBackground,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          Container(color: Colors.black.withValues(alpha: 0.55)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Image.asset(
                  AppAssets.blitzMascot,
                  height: 120,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.bolt, size: 80, color: AppColors.accent),
                ),
                const SizedBox(height: 16),
                Text(
                  '60 seconds. 5 games rotate randomly. Beat your personal best!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 24),
                _PersonalBestRow(
                  allTime: allTimeBest,
                  today: todayBest,
                  lastRun: lastRun,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AudioService.instance.playButtonTap();
                      onStart();
                    },
                    child: const Text('Start Blitz'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
