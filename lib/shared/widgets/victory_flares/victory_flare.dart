import 'package:flutter/material.dart';
import 'flares/confetti_cannon_flare.dart';
import 'flares/fire_storm_flare.dart';
import 'flares/galaxy_burst_flare.dart';
import 'flares/lightning_strike_flare.dart';
import 'flares/training_boost_flare.dart';
import 'particle_engine.dart';
import 'victory_flare_base.dart';

export 'victory_flare_base.dart';

/// Reusable procedural Flutter Victory Flare Widget.
class VictoryFlare extends StatefulWidget {
  final VictoryFlareType type;
  final VictoryFlareController? controller;
  final Duration duration;
  final double intensity;
  final int? particleCount;
  final bool autoStart;
  final bool loop;
  /// When [loop] is true, stop after this many cycles (null = forever).
  final int? maxLoops;
  final bool isThumbnail;
  final VoidCallback? onComplete;

  const VictoryFlare({
    super.key,
    required this.type,
    this.controller,
    this.duration = const Duration(milliseconds: 3000),
    this.intensity = 1.0,
    this.particleCount,
    this.autoStart = true,
    this.loop = false,
    this.maxLoops,
    this.isThumbnail = false,
    this.onComplete,
  });

  /// Factory constructor to resolve Victory Flare by string ID (e.g. 'flair_fire_storm').
  factory VictoryFlare.fromId(
    String? id, {
    Key? key,
    VictoryFlareController? controller,
    Duration duration = const Duration(milliseconds: 3000),
    double intensity = 1.0,
    int? particleCount,
    bool autoStart = true,
    bool loop = false,
    int? maxLoops,
    bool isThumbnail = false,
    VoidCallback? onComplete,
  }) {
    final type = VictoryFlareType.fromId(id) ?? VictoryFlareType.trainingBoost;
    return VictoryFlare(
      key: key,
      type: type,
      controller: controller,
      duration: duration,
      intensity: intensity,
      particleCount: particleCount,
      autoStart: autoStart,
      loop: loop,
      maxLoops: maxLoops,
      isThumbnail: isThumbnail,
      onComplete: onComplete,
    );
  }

  /// Specialized factory constructor for compact 64x64 store thumbnail animations.
  factory VictoryFlare.thumbnail({
    Key? key,
    required VictoryFlareType type,
  }) {
    return VictoryFlare(
      key: key,
      type: type,
      duration: const Duration(milliseconds: 2000),
      intensity: 0.6,
      particleCount: _getDefaultThumbnailParticleCount(type),
      autoStart: true,
      loop: true,
      isThumbnail: true,
    );
  }

  /// Specialized factory constructor for thumbnail by string ID.
  factory VictoryFlare.thumbnailFromId(
    String? id, {
    Key? key,
  }) {
    final type = VictoryFlareType.fromId(id) ?? VictoryFlareType.trainingBoost;
    return VictoryFlare.thumbnail(key: key, type: type);
  }

  static int _getDefaultThumbnailParticleCount(VictoryFlareType type) {
    switch (type) {
      case VictoryFlareType.confettiCannon:
        return 35;
      case VictoryFlareType.galaxyBurst:
        return 30;
      case VictoryFlareType.fireStorm:
        return 25;
      case VictoryFlareType.lightningStrike:
        return 20;
      case VictoryFlareType.trainingBoost:
        return 25;
    }
  }

  static int _getDefaultFullParticleCount(VictoryFlareType type) {
    switch (type) {
      case VictoryFlareType.confettiCannon:
        return 180;
      case VictoryFlareType.galaxyBurst:
        return 120;
      case VictoryFlareType.fireStorm:
        return 110;
      case VictoryFlareType.lightningStrike:
        return 70;
      case VictoryFlareType.trainingBoost:
        return 90;
    }
  }

  @override
  State<VictoryFlare> createState() => _VictoryFlareState();
}

class _VictoryFlareState extends State<VictoryFlare>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final ParticlePool _particlePool = ParticlePool();
  late DateTime _lastFrameTime;
  int _loopCount = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animController.addListener(_onFrameTick);
    _animController.addStatusListener(_onStatusChanged);

    widget.controller?.addListener(_onControllerChanged);

    _lastFrameTime = DateTime.now();

    if (widget.autoStart || widget.loop || (widget.controller?.isPlaying ?? false)) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant VictoryFlare oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
    if (oldWidget.type != widget.type) {
      _particlePool.clear();
    }
  }

  void _onControllerChanged() {
    if (widget.controller == null) return;
    if (widget.controller!.isPlaying) {
      _startAnimation();
    } else {
      _stopAnimation();
    }
  }

  void _startAnimation() {
    _particlePool.clear();
    _loopCount = 0;
    _finished = false;
    _lastFrameTime = DateTime.now();
    if (widget.loop && widget.maxLoops == null) {
      _animController.repeat();
    } else {
      _animController.forward(from: 0.0);
    }
  }

  void _stopAnimation() {
    _animController.stop();
    _particlePool.clear();
    _finished = true;
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    _loopCount++;
    final maxLoops = widget.maxLoops;
    final shouldContinueLoop =
        widget.loop && (maxLoops == null || _loopCount < maxLoops);

    if (shouldContinueLoop) {
      _particlePool.clear();
      _animController.forward(from: 0.0);
    } else {
      _finished = true;
      widget.onComplete?.call();
      if (mounted) setState(() {});
    }
  }

  void _onFrameTick() {
    final now = DateTime.now();
    final dt = (now.difference(_lastFrameTime).inMicroseconds / 1000000.0)
        .clamp(0.001, 0.05); // Cap dt to avoid huge jumps on frame drops
    _lastFrameTime = now;

    // 1. Physics update for active particles
    for (final p in _particlePool.activeParticles) {
      p.update(dt);
    }

    // 2. Recycle expired particles
    _particlePool.recycleDeadParticles();

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _animController.removeListener(_onFrameTick);
    _animController.removeStatusListener(_onStatusChanged);
    _animController.dispose();
    _particlePool.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished && !widget.loop) {
      return const SizedBox.shrink();
    }
    // After maxLoops finishes, hide flare so score stays readable.
    if (_finished && widget.maxLoops != null) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          if (size.width > 0 && size.height > 0) {
            final effectiveParticleCount = widget.particleCount ??
                (widget.isThumbnail
                    ? VictoryFlare._getDefaultThumbnailParticleCount(widget.type)
                    : VictoryFlare._getDefaultFullParticleCount(widget.type));

            final options = VictoryFlareOptions(
              intensity: widget.intensity,
              particleCount: effectiveParticleCount,
              isThumbnail: widget.isThumbnail,
            );

            // Spawn particles based on flare type
            switch (widget.type) {
              case VictoryFlareType.trainingBoost:
                TrainingBoostPainter.spawnParticles(
                  _particlePool,
                  size,
                  _animController.value,
                  options: options,
                );
                return CustomPaint(
                  size: size,
                  painter: TrainingBoostPainter(
                    progress: _animController.value,
                    particles: _particlePool.activeParticles,
                    options: options,
                  ),
                );

              case VictoryFlareType.fireStorm:
                FireStormPainter.spawnParticles(
                  _particlePool,
                  size,
                  _animController.value,
                  options: options,
                );
                return CustomPaint(
                  size: size,
                  painter: FireStormPainter(
                    progress: _animController.value,
                    particles: _particlePool.activeParticles,
                    options: options,
                  ),
                );

              case VictoryFlareType.lightningStrike:
                LightningStrikePainter.spawnParticles(
                  _particlePool,
                  size,
                  _animController.value,
                  options: options,
                );
                return CustomPaint(
                  size: size,
                  painter: LightningStrikePainter(
                    progress: _animController.value,
                    particles: _particlePool.activeParticles,
                    options: options,
                  ),
                );

              case VictoryFlareType.confettiCannon:
                ConfettiCannonPainter.spawnParticles(
                  _particlePool,
                  size,
                  _animController.value,
                  options: options,
                );
                return CustomPaint(
                  size: size,
                  painter: ConfettiCannonPainter(
                    progress: _animController.value,
                    particles: _particlePool.activeParticles,
                    options: options,
                  ),
                );

              case VictoryFlareType.galaxyBurst:
                GalaxyBurstPainter.spawnParticles(
                  _particlePool,
                  size,
                  _animController.value,
                  options: options,
                );
                return CustomPaint(
                  size: size,
                  painter: GalaxyBurstPainter(
                    progress: _animController.value,
                    particles: _particlePool.activeParticles,
                    options: options,
                  ),
                );
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
