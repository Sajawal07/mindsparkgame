import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../particle_engine.dart';
import '../victory_flare_base.dart';

/// Procedural Confetti Cannon Flare Painter.
class ConfettiCannonPainter extends CustomPainter {
  ConfettiCannonPainter({
    required this.progress,
    required this.particles,
    required this.options,
  });

  final double progress;
  final List<Particle> particles;
  final VictoryFlareOptions options;

  static const List<Color> _confettiPalette = [
    Color(0xFFFF1744),
    Color(0xFFFF9100),
    Color(0xFFFFEA00),
    Color(0xFF00E676),
    Color(0xFF00E5FF),
    Color(0xFFD500F9),
    Color(0xFFE040FB),
    Color(0xFF3D5AFE),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final groundY = size.height * 0.95;

    // Render Confetti Particles with 3D Flutter Simulation & Ground Bounce Physics
    for (final p in particles) {
      // 3D Fluttering effect by scaling horizontal/vertical dimensions with cosine
      final flutterScale = math.cos(p.lifetime * 8.0 + p.rotation);
      p.scaleX = flutterScale;

      // Air resistance wind drift oscillation
      final windDrift = math.sin(p.lifetime * 3.0 + p.position.dy * 0.02) * 20;
      p.wind = windDrift;

      // Slight ground bounce check
      if (p.position.dy >= groundY && p.velocity.dy > 0) {
        p.position = Offset(p.position.dx, groundY);
        p.velocity = Offset(p.velocity.dx * 0.5, -p.velocity.dy * 0.25); // Dampened bounce
      }

      ParticleRenderer.render(canvas, p);
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiCannonPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.particles != particles;
  }

  /// Initialize 150-250 confetti shapes launched from cannons at bottom corners/center.
  static void spawnParticles(
    ParticlePool pool,
    Size size,
    double progress, {
    required VictoryFlareOptions options,
  }) {
    final count = options.particleCount;
    final random = math.Random();

    final shapes = [
      ParticleShape.rectangle,
      ParticleShape.square,
      ParticleShape.circle,
      ParticleShape.triangle,
      ParticleShape.diamond,
      ParticleShape.star,
    ];

    while (pool.activeParticles.length < count) {
      final p = pool.obtain();

      // Launch source: left cannon, right cannon, or center bottom
      final cannonIndex = random.nextInt(3);
      final Offset launchPos;
      final double baseAngle;

      if (cannonIndex == 0) {
        launchPos = Offset(size.width * 0.1, size.height * 0.9);
        baseAngle = -math.pi / 3; // Launch top-right
      } else if (cannonIndex == 1) {
        launchPos = Offset(size.width * 0.9, size.height * 0.9);
        baseAngle = -2 * math.pi / 3; // Launch top-left
      } else {
        launchPos = Offset(size.width * 0.5, size.height * 0.95);
        baseAngle = -math.pi / 2; // Launch straight up
      }

      final angle = baseAngle + (random.nextDouble() - 0.5) * 0.6;
      final speed = (180.0 + random.nextDouble() * 260.0) * (options.isThumbnail ? 0.45 : 1.0);

      p.position = launchPos + Offset((random.nextDouble() - 0.5) * 20, 0);
      p.velocity = Offset(math.cos(angle) * speed, math.sin(angle) * speed);
      p.gravity = 140.0 * (options.isThumbnail ? 0.6 : 1.0); // Natural downward gravity
      p.drag = 0.25; // Air resistance drag
      p.size = (8.0 + random.nextDouble() * 10.0) * (options.isThumbnail ? 0.6 : 1.0);
      p.endSize = p.size;
      p.color = _confettiPalette[random.nextInt(_confettiPalette.length)];
      p.opacity = 1.0;
      p.maxLifetime = 1.8 + random.nextDouble() * 1.5;
      p.shape = shapes[random.nextInt(shapes.length)];
      p.rotation = random.nextDouble() * math.pi * 2;
      p.rotationSpeed = (random.nextDouble() - 0.5) * 8.0;
    }
  }
}
