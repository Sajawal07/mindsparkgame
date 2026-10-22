import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../particle_engine.dart';
import '../victory_flare_base.dart';

/// Procedural Galaxy Burst Flare Painter (Swirling Spiral Galaxy, Cosmic Nebula, and Stars).
class GalaxyBurstPainter extends CustomPainter {
  GalaxyBurstPainter({
    required this.progress,
    required this.particles,
    required this.options,
  }) : _paint = Paint();

  final double progress;
  final List<Particle> particles;
  final VictoryFlareOptions options;
  final Paint _paint;

  static const List<Color> _cosmicPalette = [
    Color(0xFF7C4DFF),
    Color(0xFF651FFF),
    Color(0xFF00E5FF),
    Color(0xFFE040FB),
    Color(0xFF00B0FF),
    Color(0xFF1A237E),
    Color(0xFFFFFFFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    // 1. Cosmic Central Core & Purple Nebula Cloud
    final coreGradient = RadialGradient(
      colors: [
        const Color(0xFFE040FB).withAlpha((200 * options.intensity).toInt()),
        const Color(0xFF7C4DFF).withAlpha((140 * options.intensity).toInt()),
        const Color(0xFF1A237E).withAlpha((80 * options.intensity).toInt()),
        const Color(0x00000000),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    _paint.shader = coreGradient.createShader(
      Rect.fromCircle(center: center, radius: maxRadius * 0.9),
    );
    canvas.drawCircle(center, maxRadius * 0.9, _paint);
    _paint.shader = null;

    // 2. Expanding Spiral Galaxy Rings
    final armCount = options.isThumbnail ? 2 : 4;
    final rotationAngle = progress * math.pi * 4;

    _paint.style = PaintingStyle.stroke;
    for (int arm = 0; arm < armCount; arm++) {
      final baseArmAngle = (arm * 2 * math.pi / armCount) + rotationAngle;
      final path = Path();

      for (double r = 10; r < maxRadius; r += 8) {
        final theta = baseArmAngle + (r / maxRadius) * math.pi * 2;
        final pos = center + Offset(math.cos(theta) * r, math.sin(theta) * r * 0.6);
        if (r == 10) {
          path.moveTo(pos.dx, pos.dy);
        } else {
          path.lineTo(pos.dx, pos.dy);
        }
      }

      _paint.strokeWidth = options.isThumbnail ? 1.5 : 2.5;
      _paint.color = _cosmicPalette[arm % _cosmicPalette.length]
          .withAlpha((140 * options.intensity).toInt());
      canvas.drawPath(path, _paint);
    }
    _paint.style = PaintingStyle.fill;

    // 3. Render Swirling Stars, Nebula Clouds, and Particle Trails
    for (final p in particles) {
      ParticleRenderer.render(canvas, p);
    }
  }

  @override
  bool shouldRepaint(covariant GalaxyBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.particles != particles;
  }

  /// Spawn spiral orbit galaxy particles, nebula clouds, and twinkling stars.
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
      final pType = random.nextDouble();

      final initialRadius = 10.0 + random.nextDouble() * 30.0;
      final angle = random.nextDouble() * math.pi * 2;
      final speed = (60.0 + random.nextDouble() * 120.0) * (options.isThumbnail ? 0.5 : 1.0);

      // Tangential velocity vector for spiral galaxy orbital spin
      final tangentVelocity = Offset(-math.sin(angle), math.cos(angle)) * speed;
      final radialVelocity = Offset(math.cos(angle), math.sin(angle)) * (speed * 0.4);

      p.position = center + Offset(math.cos(angle), math.sin(angle)) * initialRadius;
      p.velocity = tangentVelocity + radialVelocity;
      p.gravity = 0.0;
      p.drag = 0.2;

      if (pType < 0.3) {
        // Soft Nebula Cloud Particle
        p.size = (16.0 + random.nextDouble() * 24.0) * (options.isThumbnail ? 0.5 : 1.0);
        p.endSize = p.size * 1.5;
        p.color = const Color(0xFF7C4DFF);
        p.endColor = const Color(0xFF1A237E);
        p.opacity = 0.5;
        p.shape = ParticleShape.smoke;
        p.maxLifetime = 1.0 + random.nextDouble() * 1.0;
      } else if (pType < 0.75) {
        // Twinkling Star Particle with Trail
        p.size = (5.0 + random.nextDouble() * 9.0) * (options.isThumbnail ? 0.6 : 1.0);
        p.endSize = 1.0;
        p.color = _cosmicPalette[random.nextInt(_cosmicPalette.length)];
        p.endColor = const Color(0xFFFFFFFF);
        p.opacity = 0.9;
        p.shape = random.nextBool() ? ParticleShape.star : ParticleShape.circle;
        p.maxLifetime = 0.7 + random.nextDouble() * 0.8;
        p.trail = [];
        p.maxTrailLength = options.isThumbnail ? 3 : 6;
      } else {
        // High-speed Blue Plasma Energy Spark
        p.size = (3.0 + random.nextDouble() * 6.0) * (options.isThumbnail ? 0.6 : 1.0);
        p.endSize = 0.0;
        p.color = const Color(0xFF00E5FF);
        p.endColor = const Color(0xFF651FFF);
        p.opacity = 1.0;
        p.shape = ParticleShape.spark;
        p.maxLifetime = 0.4 + random.nextDouble() * 0.5;
      }

      p.rotation = random.nextDouble() * math.pi * 2;
      p.rotationSpeed = (random.nextDouble() - 0.5) * 4.0;
    }
  }
}
