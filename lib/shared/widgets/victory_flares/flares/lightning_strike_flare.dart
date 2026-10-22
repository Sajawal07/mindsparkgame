import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../particle_engine.dart';
import '../victory_flare_base.dart';

/// Procedural Lightning Strike Flare Painter.
class LightningStrikePainter extends CustomPainter {
  LightningStrikePainter({
    required this.progress,
    required this.particles,
    required this.options,
  }) : _paint = Paint();

  final double progress;
  final List<Particle> particles;
  final VictoryFlareOptions options;
  final Paint _paint;

  static const List<Color> _electricPalette = [
    Color(0xFFFFFFFF),
    Color(0xFF80D8FF),
    Color(0xFF40C4FF),
    Color(0xFF00E5FF),
    Color(0xFF2979FF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final startPoint = Offset(size.width / 2, size.height * 0.05);
    final impactPoint = Offset(size.width / 2, size.height * 0.65);

    // 1. Ambient Electric Screen Flash
    final flashCycle = math.sin(progress * math.pi * 8);
    if (flashCycle > 0.6) {
      final flashOpacity = ((flashCycle - 0.6) / 0.4 * 0.25 * options.intensity).clamp(0.0, 0.3);
      _paint.color = const Color(0xFF40C4FF).withAlpha((flashOpacity * 255).toInt());
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _paint);
    }

    // 2. Procedural Branching Lightning Paths
    final random = math.Random((progress * 30).floor());
    final mainBoltPath = _generateLightningPath(startPoint, impactPoint, random, displacement: 28);

    // Render outer cyan glow bolt
    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = options.isThumbnail ? 4.0 : 7.0;
    _paint.color = const Color(0xFF00E5FF).withAlpha((200 * options.intensity).toInt());
    _paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawPath(mainBoltPath, _paint);
    _paint.maskFilter = null;

    // Render sharp inner white core bolt
    _paint.strokeWidth = options.isThumbnail ? 1.5 : 2.5;
    _paint.color = Colors.white;
    canvas.drawPath(mainBoltPath, _paint);

    // Render 2-3 side branches
    final branchCount = options.isThumbnail ? 1 : 3;
    for (int i = 0; i < branchCount; i++) {
      final branchStartProgress = 0.2 + i * 0.25;
      final bStart = Offset(
        startPoint.dx + (impactPoint.dx - startPoint.dx) * branchStartProgress,
        startPoint.dy + (impactPoint.dy - startPoint.dy) * branchStartProgress,
      );
      final angle = (i.isEven ? 1 : -1) * (0.4 + random.nextDouble() * 0.4);
      final bEnd = bStart + Offset(math.cos(angle) * 50, math.sin(angle) * 60 + 30);
      final branchPath = _generateLightningPath(bStart, bEnd, random, displacement: 14);

      _paint.strokeWidth = options.isThumbnail ? 1.0 : 1.8;
      _paint.color = const Color(0xFF80D8FF).withAlpha((180 * options.intensity).toInt());
      canvas.drawPath(branchPath, _paint);
    }
    _paint.style = PaintingStyle.fill;

    // 3. Circular Impact Wave
    final impactProgress = (progress * 2) % 1.0;
    final waveRadius = math.min(size.width, size.height) * 0.35 * impactProgress;
    final waveOpacity = (1.0 - impactProgress).clamp(0.0, 1.0) * options.intensity;

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = 2.0;
    _paint.color = const Color(0xFF00E5FF).withAlpha((waveOpacity * 240).toInt());
    canvas.drawCircle(impactPoint, waveRadius, _paint);
    _paint.style = PaintingStyle.fill;

    // 4. Render Electric Sparks & Particles
    for (final p in particles) {
      ParticleRenderer.render(canvas, p);
    }
  }

  /// Generate a fractal / segment-displaced lightning Path between [start] and [end].
  Path _generateLightningPath(
    Offset start,
    Offset end,
    math.Random random, {
    required double displacement,
  }) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final segments = 12;
    var current = start;

    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final targetX = start.dx + (end.dx - start.dx) * t;
      final targetY = start.dy + (end.dy - start.dy) * t;

      if (i == segments) {
        path.lineTo(end.dx, end.dy);
      } else {
        final dx = (random.nextDouble() - 0.5) * displacement;
        final dy = (random.nextDouble() - 0.5) * (displacement * 0.5);
        current = Offset(targetX + dx, targetY + dy);
        path.lineTo(current.dx, current.dy);
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant LightningStrikePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.particles != particles;
  }

  /// Spawn high-velocity electric sparks at the impact point.
  static void spawnParticles(
    ParticlePool pool,
    Size size,
    double progress, {
    required VictoryFlareOptions options,
  }) {
    final impactPoint = Offset(size.width / 2, size.height * 0.65);
    final count = options.particleCount;
    final random = math.Random();

    while (pool.activeParticles.length < count) {
      final p = pool.obtain();
      final angle = random.nextDouble() * math.pi * 2;
      final speed = (100.0 + random.nextDouble() * 220.0) * (options.isThumbnail ? 0.5 : 1.0);

      p.position = impactPoint;
      p.velocity = Offset(math.cos(angle) * speed, math.sin(angle) * speed);
      p.gravity = 120;
      p.drag = 0.5;
      p.size = (4.0 + random.nextDouble() * 8.0) * (options.isThumbnail ? 0.6 : 1.0);
      p.endSize = 0.0;
      p.color = _electricPalette[random.nextInt(_electricPalette.length)];
      p.endColor = const Color(0xFF2979FF);
      p.opacity = 1.0;
      p.maxLifetime = 0.3 + random.nextDouble() * 0.4;
      p.shape = ParticleShape.spark;
      p.rotation = angle;
      p.rotationSpeed = 0.0;
    }
  }
}
