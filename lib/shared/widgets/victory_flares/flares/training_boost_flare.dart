import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../particle_engine.dart';
import '../victory_flare_base.dart';

/// Procedural Training Boost Flare Painter (Purple Energy Burst).
class TrainingBoostPainter extends CustomPainter {
  TrainingBoostPainter({
    required this.progress,
    required this.particles,
    required this.options,
  }) : _paint = Paint();

  final double progress;
  final List<Particle> particles;
  final VictoryFlareOptions options;
  final Paint _paint;

  static const List<Color> _purplePalette = [
    Color(0xFFE040FB),
    Color(0xFFAB47BC),
    Color(0xFF7C4DFF),
    Color(0xFFD500F9),
    Color(0xFF651FFF),
    Color(0xFFEA80FC),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;
    final pulseScale = 1.0 + 0.15 * math.sin(progress * math.pi * 4);

    // 1. Central Radial Pulse Effect
    final coreGradient = RadialGradient(
      colors: [
        const Color(0xFFE040FB).withAlpha((180 * options.intensity).toInt()),
        const Color(0xFF7C4DFF).withAlpha((100 * options.intensity).toInt()),
        const Color(0xFF651FFF).withAlpha(0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    _paint.shader = coreGradient.createShader(
      Rect.fromCircle(center: center, radius: maxRadius * pulseScale),
    );
    canvas.drawCircle(center, maxRadius * pulseScale, _paint);
    _paint.shader = null;

    // 2. Fading Rings
    final ringCount = options.isThumbnail ? 2 : 4;
    for (int i = 0; i < ringCount; i++) {
      final ringProgress = (progress + i / ringCount) % 1.0;
      final ringRadius = maxRadius * ringProgress * 1.2;
      final ringOpacity = (1.0 - ringProgress).clamp(0.0, 1.0) * options.intensity;

      _paint.style = PaintingStyle.stroke;
      _paint.strokeWidth = 2.5 * (1.0 - ringProgress);
      _paint.color = _purplePalette[i % _purplePalette.length]
          .withAlpha((ringOpacity * 200).toInt());
      canvas.drawCircle(center, ringRadius, _paint);
    }
    _paint.style = PaintingStyle.fill;

    // 3. Expanding Radial Lines
    final rayCount = options.isThumbnail ? 8 : 16;
    final rayRotation = progress * math.pi * 2;

    _paint.style = PaintingStyle.stroke;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi / rayCount) + rayRotation;
      final rayLength = maxRadius * (0.6 + 0.4 * math.sin(angle * 3 + progress * 6));
      final rayOpacity = (0.3 + 0.4 * math.cos(angle * 2)).clamp(0.1, 0.8) * options.intensity;

      _paint.strokeWidth = options.isThumbnail ? 1.5 : 2.5;
      _paint.color = const Color(0xFFEA80FC).withAlpha((rayOpacity * 255).toInt());

      final start = center + Offset(math.cos(angle), math.sin(angle)) * (maxRadius * 0.15);
      final end = center + Offset(math.cos(angle), math.sin(angle)) * rayLength;

      canvas.drawLine(start, end, _paint);
    }
    _paint.style = PaintingStyle.fill;

    // 4. Render Glowing Energy Particles & Sparkles
    for (final p in particles) {
      ParticleRenderer.render(canvas, p);
    }
  }

  @override
  bool shouldRepaint(covariant TrainingBoostPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.particles != particles;
  }

  /// Initialize or refresh particles for Training Boost
  static void spawnParticles(
    ParticlePool pool,
    Size size,
    double progress, {
    required VictoryFlareOptions options,
  }) {
    final center = Offset(size.width / 2, size.height / 2);
    final count = options.particleCount;
    final random = math.Random();

    while (pool.activeParticles.length < count) {
      final p = pool.obtain();
      final angle = random.nextDouble() * math.pi * 2;
      final speed = (60.0 + random.nextDouble() * 140.0) * (options.isThumbnail ? 0.5 : 1.0);

      p.position = center + Offset(math.cos(angle), math.sin(angle)) * (random.nextDouble() * 12);
      p.velocity = Offset(math.cos(angle), math.sin(angle)) * speed;
      p.drag = 0.8;
      p.gravity = -20; // Soft upward energy float
      p.size = (6.0 + random.nextDouble() * 10.0) * (options.isThumbnail ? 0.6 : 1.0);
      p.endSize = 0.0;
      p.color = _purplePalette[random.nextInt(_purplePalette.length)];
      p.endColor = const Color(0xFF651FFF);
      p.opacity = 0.8 + random.nextDouble() * 0.2;
      p.maxLifetime = 0.6 + random.nextDouble() * 0.8;
      p.shape = random.nextBool() ? ParticleShape.circle : ParticleShape.spark;
      p.rotation = random.nextDouble() * math.pi * 2;
      p.rotationSpeed = (random.nextDouble() - 0.5) * 4.0;
    }
  }
}
