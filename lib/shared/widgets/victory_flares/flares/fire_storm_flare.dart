import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../particle_engine.dart';
import '../victory_flare_base.dart';

/// Procedural Fire Storm Flare Painter (Explosive Fire, Ember, Smoke, and Heat Glow).
class FireStormPainter extends CustomPainter {
  FireStormPainter({
    required this.progress,
    required this.particles,
    required this.options,
  }) : _paint = Paint();

  final double progress;
  final List<Particle> particles;
  final VictoryFlareOptions options;
  final Paint _paint;

  static const List<Color> _firePalette = [
    Color(0xFFFF3D00),
    Color(0xFFFF6D00),
    Color(0xFFFFAB00),
    Color(0xFFFFD600),
    Color(0xFFFF1744),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final center = Offset(size.width / 2, size.height * 0.55);
    final maxRadius = math.min(size.width, size.height) * 0.4;

    // 1. Fiery Heat Distortion / Core Glow
    final heatRadius = maxRadius * (0.8 + 0.2 * math.sin(progress * math.pi * 6));
    final fireGradient = RadialGradient(
      colors: [
        const Color(0xFFFFD600).withAlpha((220 * options.intensity).toInt()),
        const Color(0xFFFF6D00).withAlpha((160 * options.intensity).toInt()),
        const Color(0xFFFF3D00).withAlpha((80 * options.intensity).toInt()),
        const Color(0x00FF1744),
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
    );
    _paint.shader = fireGradient.createShader(
      Rect.fromCircle(center: center, radius: heatRadius),
    );
    canvas.drawCircle(center, heatRadius, _paint);
    _paint.shader = null;

    // 2. Expanding Shockwave
    final shockProgress = (progress * 1.5) % 1.0;
    final shockRadius = maxRadius * 1.3 * shockProgress;
    final shockOpacity = (1.0 - shockProgress).clamp(0.0, 1.0) * options.intensity;

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = 3.0 * (1.0 - shockProgress);
    _paint.color = const Color(0xFFFF6D00).withAlpha((shockOpacity * 220).toInt());
    canvas.drawCircle(center, shockRadius, _paint);
    _paint.style = PaintingStyle.fill;

    // 3. Render Particles (Smoke, Embers, Flame Sparks)
    for (final p in particles) {
      ParticleRenderer.render(canvas, p);
    }
  }

  @override
  bool shouldRepaint(covariant FireStormPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.particles != particles;
  }

  /// Initialize and recycle fire, ember, and smoke particles.
  static void spawnParticles(
    ParticlePool pool,
    Size size,
    double progress, {
    required VictoryFlareOptions options,
  }) {
    final center = Offset(size.width / 2, size.height * 0.58);
    final count = options.particleCount;
    final random = math.Random();

    while (pool.activeParticles.length < count) {
      final p = pool.obtain();
      final pType = random.nextDouble();

      if (pType < 0.25) {
        // Smoke Particle
        final angle = (random.nextDouble() - 0.5) * math.pi * 0.8 - math.pi / 2;
        final speed = (30.0 + random.nextDouble() * 50.0) * (options.isThumbnail ? 0.5 : 1.0);
        p.position = center + Offset((random.nextDouble() - 0.5) * 20, 0);
        p.velocity = Offset(math.cos(angle) * speed, math.sin(angle) * speed);
        p.gravity = -30;
        p.drag = 0.4;
        p.size = (14.0 + random.nextDouble() * 20.0) * (options.isThumbnail ? 0.5 : 1.0);
        p.endSize = p.size * 2.2;
        p.color = const Color(0xFF3E2723);
        p.endColor = const Color(0xFF1C100B);
        p.opacity = 0.4;
        p.maxLifetime = 1.0 + random.nextDouble() * 0.8;
        p.shape = ParticleShape.smoke;
        p.rotationSpeed = (random.nextDouble() - 0.5) * 1.5;
      } else if (pType < 0.65) {
        // Flame Particle
        final angle = (random.nextDouble() - 0.5) * math.pi * 0.9 - math.pi / 2;
        final speed = (80.0 + random.nextDouble() * 160.0) * (options.isThumbnail ? 0.5 : 1.0);
        p.position = center + Offset((random.nextDouble() - 0.5) * 16, 0);
        p.velocity = Offset(math.cos(angle) * speed, math.sin(angle) * speed);
        p.gravity = -60;
        p.drag = 0.6;
        p.size = (8.0 + random.nextDouble() * 12.0) * (options.isThumbnail ? 0.6 : 1.0);
        p.endSize = 1.0;
        p.color = _firePalette[random.nextInt(_firePalette.length)];
        p.endColor = const Color(0xFFFF1744);
        p.opacity = 0.9;
        p.maxLifetime = 0.5 + random.nextDouble() * 0.5;
        p.shape = random.nextBool() ? ParticleShape.spark : ParticleShape.circle;
        p.rotation = random.nextDouble() * math.pi * 2;
        p.rotationSpeed = (random.nextDouble() - 0.5) * 5.0;
      } else {
        // Ember Sparkle
        final angle = random.nextDouble() * math.pi * 2;
        final speed = (40.0 + random.nextDouble() * 120.0) * (options.isThumbnail ? 0.5 : 1.0);
        p.position = center;
        p.velocity = Offset(math.cos(angle) * speed, math.sin(angle) * speed);
        p.gravity = -40;
        p.drag = 0.3;
        p.size = (3.0 + random.nextDouble() * 5.0) * (options.isThumbnail ? 0.6 : 1.0);
        p.endSize = 0.0;
        p.color = const Color(0xFFFFD600);
        p.endColor = const Color(0xFFFF6D00);
        p.opacity = 1.0;
        p.maxLifetime = 0.7 + random.nextDouble() * 0.7;
        p.shape = ParticleShape.square;
        p.rotationSpeed = (random.nextDouble() - 0.5) * 8.0;
      }
    }
  }
}
