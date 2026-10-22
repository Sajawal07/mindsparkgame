import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/home_level_up.dart';
import '../../data/models/arena_config.dart';
import '../../data/models/game_mode.dart';
import '../../data/providers/game_providers.dart';
import '../../data/providers/network_provider.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/brain_score_service.dart';
import '../../data/services/save_service.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/network/no_internet_view.dart';
import '../../shared/widgets/victory_flares/victory_flare.dart';
import '../puzzles/puzzle_flow.dart';

class ArenaModeScreen extends ConsumerStatefulWidget {
  const ArenaModeScreen({super.key});

  @override
  ConsumerState<ArenaModeScreen> createState() => _ArenaModeScreenState();
}

class _ArenaModeScreenState extends ConsumerState<ArenaModeScreen>
    with TickerProviderStateMixin {
  Timer? _refreshTimer;

  // Intro animation
  bool _showIntro = true;
  late AnimationController _gateCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _gateLeft;
  late Animation<double> _gateRight;
  late Animation<double> _glowAnim;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    // Gate opening animation controllers
    _gateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Left gate slides left, right gate slides right
    _gateLeft = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(parent: _gateCtrl, curve: Curves.easeInBack),
    );
    _gateRight = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _gateCtrl, curve: Curves.easeInBack),
    );
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeIn);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    _playIntro();

    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowMatchResult());
  }

  void _playIntro() async {
    // Small pause then open the gates
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    AudioService.instance.playSfx(Sfx.achievement);
    await _gateCtrl.forward();
    if (!mounted) return;
    setState(() => _showIntro = false);
    _contentCtrl.forward();

    // Show leaderboard nudge ONLY the very first time (one-time event)
    final alreadyShown = ref.read(gameStateProvider).arenaUnlockDialogShown;
    if (!alreadyShown) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      // Mark as shown BEFORE displaying so rapid re-opens don't double-show
      await ref.read(gameStateProvider).markArenaUnlockDialogShown();
      _showLeaderboardNudge();
    }
  }

  void _showLeaderboardNudge() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A3E), Color(0xFF0D0D1F)],
            ),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.leaderboard, color: AppColors.gold, size: 48),
              const SizedBox(height: 12),
              Text(
                '🏆 Leaderboard Unlocked!',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You have unlocked the Arena & Global Leaderboard!\n\nCompete in matches, earn Arena Points (AP), and climb the global rankings.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.gold),
                        foregroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.push(AppRoutes.leaderboard);
                      },
                      child: const Text('View Rankings',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Let\'s Fight!',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _gateCtrl.dispose();
    _glowCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _maybeShowMatchResult() {
    final extra = GoRouterState.of(context).extra;
    if (extra is! ArenaMatchResult) return;
    _showResultDialog(extra);
  }

  Future<void> _showResultDialog(ArenaMatchResult result) async {
    await AudioService.instance.playSfx(Sfx.arenaVictory);
    if (!mounted) return;
    final equippedFlair = ref.read(gameStateProvider).save.player.equippedVictoryFlair;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: VictoryFlare.fromId(
                equippedFlair,
                autoStart: true,
                loop: true,
              ),
            ),
          ),
          AlertDialog(
            backgroundColor: AppColors.surface.withValues(alpha: 0.94),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.arenaVictory,
                  height: 120,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Match Complete!',
                  style: Theme.of(ctx).textTheme.headlineMedium,
                ),
                Text('Final Score: ${result.playerScore}'),
                const SizedBox(height: 8),
                Text(
                  '+${result.arenaPointsDelta} Arena Points',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (result.perfectRoundBonus > 0)
                  Text('+${result.perfectRoundBonus} AP perfect round bonus'),
                Text('+${result.coinsEarned} coins'),
                Text('+${result.xpEarned} XP'),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final rank = BrainScoreService.simulateIqForRound(
                      score: result.playerScore,
                      maxScore: ArenaConfig.maxScorePerRound * ArenaConfig.roundsPerMatch,
                    );
                    return Column(
                      children: [
                        Text(
                          rank.displayName,
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Estimated IQ: ${rank.iqEstimate}',
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rank.comparison,
                          textAlign: TextAlign.center,
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
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
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _startMatch() async {
    AudioService.instance.playButtonTap();
    final game = ref.read(gameStateProvider);
    final match = await game.startArenaMatch();
    if (match == null || !mounted) return;
    final first = match.roundOrder.first;
    launchPuzzle(
      ref,
      context,
      type: first,
      mode: GameMode.arena,
      arenaRoundIndex: 0,
    );
  }

  void _continueMatch() {
    AudioService.instance.playButtonTap();
    final game = ref.read(gameStateProvider);
    final roundType = game.currentArenaRoundType;
    final match = game.activeArenaMatch;
    if (roundType == null || match == null) return;
    launchPuzzle(
      ref,
      context,
      type: roundType,
      mode: GameMode.arena,
      arenaRoundIndex: match.round,
    );
  }

  String _formatCountdown(Duration? remaining) {
    if (remaining == null || remaining.isNegative) return '--:--:--';
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    final s = remaining.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final save = ref.watch(gameStateProvider).save;
    final player = save.player;
    final inMatch = ref.watch(gameStateProvider).activeArenaMatch != null;
    final matchesLeft = player.arenaMatchesRemaining;
    final matchesUsed = ArenaConfig.maxMatchesPerCycle - matchesLeft;
    final nextRefresh = save.arenaNextRefreshTime;
    final refreshRemaining = nextRefresh?.difference(DateTime.now());

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService.instance.playButtonTap();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
            scheduleHomeLevelUpCheck(context, ref);
          },
        ),
        title: const Text('Arena'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.push(AppRoutes.leaderboard),
          ),
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () => context.push(AppRoutes.arenaStore),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            AppAssets.arenaBackground,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          Container(color: Colors.black.withValues(alpha: 0.6)),

          // Main content (fades in after gates open)
          if (!_showIntro)
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Image.asset(
                        AppAssets.arenaPointsBadge,
                        width: 72,
                        height: 72,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.shield, size: 64, color: AppColors.gold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${player.arenaPoints} Arena Points',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatChip(label: 'Matches', value: '${player.arenaWins}'),
                        _StatChip(
                          label: 'Weekly AP',
                          value: '${player.arenaWeeklyAP}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '4-round brain challenge. '
                      'Earn AP for the Arena Store and global leaderboard.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _RoundOverviewCard(),
                    const SizedBox(height: 24),
                    if (inMatch)
                      Column(
                        children: [
                          Text(
                            'Match in Progress',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Round ${(ref.watch(gameStateProvider).activeArenaMatch?.round ?? 0) + 1} of ${ArenaConfig.roundsPerMatch}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _continueMatch,
                              child: const Text('Continue Match'),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      Text(
                        '$matchesUsed of ${ArenaConfig.maxMatchesPerCycle} matches used',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: matchesLeft > 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$matchesLeft matches remaining',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (matchesLeft <= 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Next refresh: ${_formatCountdown(refreshRemaining)}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: matchesLeft > 0 ? _startMatch : null,
                          child: const Text('Enter Match'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Gate intro animation overlay
          if (_showIntro) _ArenaGateIntro(gateLeft: _gateLeft, gateRight: _gateRight, glowAnim: _glowAnim),

          // Offline overlay — shown on top when no internet
          if (!isOnline)
            const ColoredBox(
              color: Colors.black54,
              child: NoInternetView(featureName: 'Arena Mode'),
            ),
        ],
      ),
    );
  }
}

/// Split-gate intro animation – two dark panels slide apart revealing the arena.
class _ArenaGateIntro extends StatelessWidget {
  const _ArenaGateIntro({
    required this.gateLeft,
    required this.gateRight,
    required this.glowAnim,
  });

  final Animation<double> gateLeft;
  final Animation<double> gateRight;
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final halfW = w / 2;

        return AnimatedBuilder(
          animation: Listenable.merge([gateLeft, gateRight, glowAnim]),
          builder: (context, _) {
            return Stack(
              children: [
                // Glow in the center crack
                Positioned(
                  left: halfW + (gateLeft.value * halfW) - 30,
                  top: 0,
                  bottom: 0,
                  width: 60,
                  child: Opacity(
                    opacity: (1 - gateLeft.value.abs()).clamp(0.0, 1.0) * (0.5 + 0.5 * glowAnim.value),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.gold.withValues(alpha: 0.9),
                            AppColors.gold.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Left gate panel
                Positioned(
                  left: gateLeft.value * halfW,
                  top: 0,
                  width: halfW,
                  height: h,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          const Color(0xFF0D0D1F),
                          const Color(0xFF1A1040),
                        ],
                      ),
                      border: Border(
                        right: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.6 * (1 - gateLeft.value.abs())),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Transform(
                            alignment: Alignment.centerRight,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(gateLeft.value * math.pi / 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shield, color: AppColors.gold.withValues(alpha: 0.4), size: 48),
                                const SizedBox(height: 8),
                                Text(
                                  'ARENA',
                                  style: TextStyle(
                                    color: AppColors.gold.withValues(alpha: 0.5),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
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
                // Right gate panel
                Positioned(
                  left: halfW + gateRight.value * halfW,
                  top: 0,
                  width: halfW,
                  height: h,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF0D0D1F),
                          const Color(0xFF1A1040),
                        ],
                      ),
                      border: Border(
                        left: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.6 * (1 - gateRight.value.abs())),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(-gateRight.value * math.pi / 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events, color: AppColors.gold.withValues(alpha: 0.4), size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'MODE',
                              style: TextStyle(
                                color: AppColors.gold.withValues(alpha: 0.5),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RoundOverviewCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(gameStateProvider).activeArenaMatch;
    final currentRound = match?.round ?? 0;
    final order = match?.roundOrder ?? ArenaConfig.arenaRoundPool;

    return Card(
      color: AppColors.surface.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match Format',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              match == null
                  ? 'All 4 games every match — order randomized'
                  : 'Order for this match',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < order.length; i++)
              _RoundRow(
                label: ArenaConfig.roundLabel(i, order),
                isActive: match != null && i == currentRound,
                isComplete: match != null && i < currentRound,
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundRow extends StatelessWidget {
  const _RoundRow({
    required this.label,
    required this.isActive,
    required this.isComplete,
  });

  final String label;
  final bool isActive;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isComplete
                ? Icons.check_circle
                : isActive
                    ? Icons.play_circle_fill
                    : Icons.circle_outlined,
            color: isActive
                ? AppColors.accent
                : isComplete
                    ? AppColors.success
                    : Colors.white38,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
