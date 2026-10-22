import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Supported particle shapes for procedural rendering.
enum ParticleShape {
  circle,
  square,
  rectangle,
  triangle,
  diamond,
  star,
  spark,
  smoke,
  ring,
  line,
}

/// Core particle entity representing physics, lifetime, geometry, and rendering state.
class Particle {
  Offset position;
  Offset velocity;
  Offset acceleration;
  double gravity;
  double wind;
  double drag;
  double opacity;
  double lifetime;
  double maxLifetime;
  Color color;
  Color? endColor;
  double size;
  double endSize;
  double rotation;
  double rotationSpeed;
  ParticleShape shape;
  double scaleX;
  double scaleY;
  List<Offset>? trail;
  int? maxTrailLength;

  Particle({
    this.position = Offset.zero,
    this.velocity = Offset.zero,
    this.acceleration = Offset.zero,
    this.gravity = 0.0,
    this.wind = 0.0,
    this.drag = 0.0,
    this.opacity = 1.0,
    this.lifetime = 0.0,
    this.maxLifetime = 1.0,
    this.color = Colors.white,
    this.endColor,
    this.size = 8.0,
    this.endSize = 0.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.shape = ParticleShape.circle,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.trail,
    this.maxTrailLength,
  });

  bool get isAlive => lifetime < maxLifetime;

  double get progress => (lifetime / maxLifetime).clamp(0.0, 1.0);

  /// Current interpolated opacity based on lifetime curve.
  double get currentOpacity {
    final p = progress;
    if (p < 0.1) return (p / 0.1) * opacity;
    if (p > 0.7) return (1.0 - (p - 0.7) / 0.3) * opacity;
    return opacity;
  }

  /// Current interpolated size based on start and end sizes.
  double get currentSize {
    if (endSize <= 0) return size;
    return size + (endSize - size) * progress;
  }

  /// Current interpolated color.
  Color get currentColor {
    if (endColor == null) return color;
    return Color.lerp(color, endColor, progress) ?? color;
  }

  /// Update particle position, velocity, and rotation using delta time [dt].
  void update(double dt) {
    if (!isAlive) return;

    lifetime += dt;

    // Apply forces: gravity, wind, drag
    final ax = acceleration.dx + wind;
    final ay = acceleration.dy + gravity;

    final dragFactor = (1.0 - drag * dt).clamp(0.0, 1.0);

    velocity = Offset(
      (velocity.dx + ax * dt) * dragFactor,
      (velocity.dy + ay * dt) * dragFactor,
    );

    position += velocity * dt;
    rotation += rotationSpeed * dt;

    // Maintain position history for particle trails
    if (trail != null) {
      trail!.add(position);
      final maxLen = maxTrailLength ?? 6;
      if (trail!.length > maxLen) {
        trail!.removeAt(0);
      }
    }
  }

  /// Reset particle attributes for object pooling.
  void reset() {
    position = Offset.zero;
    velocity = Offset.zero;
    acceleration = Offset.zero;
    gravity = 0.0;
    wind = 0.0;
    drag = 0.0;
    opacity = 1.0;
    lifetime = 0.0;
    maxLifetime = 1.0;
    color = Colors.white;
    endColor = null;
    size = 8.0;
    endSize = 0.0;
    rotation = 0.0;
    rotationSpeed = 0.0;
    shape = ParticleShape.circle;
    scaleX = 1.0;
    scaleY = 1.0;
    trail?.clear();
    maxTrailLength = null;
  }
}

/// Object pool for zero-allocation particle instantiation at 60 FPS.
class ParticlePool {
  final List<Particle> _pool = [];
  final List<Particle> _active = [];

  List<Particle> get activeParticles => _active;

  /// Retrieve a particle from the pool or instantiate a new one if pool is empty.
  Particle obtain() {
    if (_pool.isNotEmpty) {
      final p = _pool.removeLast();
      p.reset();
      _active.add(p);
      return p;
    }
    final p = Particle();
    _active.add(p);
    return p;
  }

  /// Release a dead particle back to the pool.
  void recycle(Particle particle) {
    if (_active.remove(particle)) {
      particle.reset();
      _pool.add(particle);
    }
  }

  /// Recycle all inactive particles.
  void recycleDeadParticles() {
    for (int i = _active.length - 1; i >= 0; i--) {
      if (!_active[i].isAlive) {
        final p = _active.removeAt(i);
        p.reset();
        _pool.add(p);
      }
    }
  }

  /// Recycle all active particles.
  void clear() {
    for (final p in _active) {
      p.reset();
      _pool.add(p);
    }
    _active.clear();
  }
}

/// Helper extension to render various particle shapes on [Canvas].
class ParticleRenderer {
  static final Paint _paint = Paint()..style = PaintingStyle.fill;
  static final Path _path = Path();

  static void render(Canvas canvas, Particle p) {
    if (!p.isAlive) return;

    final alpha = (p.currentOpacity * 255).clamp(0, 255).toInt();
    if (alpha <= 0) return;

    final curColor = p.currentColor.withAlpha(alpha);
    final curSize = p.currentSize;
    if (curSize <= 0.1) return;

    // Render trail if present
    if (p.trail != null && p.trail!.length > 1) {
      _paint.color = curColor.withAlpha((alpha * 0.4).toInt());
      _paint.strokeWidth = curSize * 0.5;
      _paint.style = PaintingStyle.stroke;
      _paint.strokeCap = StrokeCap.round;

      _path.reset();
      _path.moveTo(p.trail!.first.dx, p.trail!.first.dy);
      for (int i = 1; i < p.trail!.length; i++) {
        _path.lineTo(p.trail![i].dx, p.trail![i].dy);
      }
      canvas.drawPath(_path, _paint);

      _paint.style = PaintingStyle.fill;
    }

    canvas.save();
    canvas.translate(p.position.dx, p.position.dy);

    if (p.rotation != 0.0 || p.scaleX != 1.0 || p.scaleY != 1.0) {
      canvas.rotate(p.rotation);
      canvas.scale(p.scaleX, p.scaleY);
    }

    _paint.color = curColor;

    switch (p.shape) {
      case ParticleShape.circle:
        canvas.drawCircle(Offset.zero, curSize / 2, _paint);
        break;

      case ParticleShape.square:
        final half = curSize / 2;
        canvas.drawRect(Rect.fromLTRB(-half, -half, half, half), _paint);
        break;

      case ParticleShape.rectangle:
        final w = curSize / 2;
        final h = curSize;
        canvas.drawRect(Rect.fromLTRB(-w, -h / 2, w, h / 2), _paint);
        break;

      case ParticleShape.triangle:
        final r = curSize / 2;
        _path.reset();
        _path.moveTo(0, -r);
        _path.lineTo(r, r);
        _path.lineTo(-r, r);
        _path.close();
        canvas.drawPath(_path, _paint);
        break;

      case ParticleShape.diamond:
        final r = curSize / 2;
        _path.reset();
        _path.moveTo(0, -r * 1.2);
        _path.lineTo(r * 0.8, 0);
        _path.moveTo(0, r * 1.2);
        _path.lineTo(-r * 0.8, 0);
        _path.close();
        canvas.drawPath(_path, _paint);
        break;

      case ParticleShape.star:
        _drawStar(canvas, curSize / 2, curColor);
        break;

      case ParticleShape.spark:
        final w = curSize * 0.3;
        final h = curSize * 1.5;
        _path.reset();
        _path.moveTo(0, -h);
        _path.lineTo(w, 0);
        _path.lineTo(0, h);
        _path.lineTo(-w, 0);
        _path.close();
        canvas.drawPath(_path, _paint);
        break;

      case ParticleShape.smoke:
        final radialPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              curColor,
              curColor.withAlpha((alpha * 0.4).toInt()),
              curColor.withAlpha(0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: curSize / 2));
        canvas.drawCircle(Offset.zero, curSize / 2, radialPaint);
        break;

      case ParticleShape.ring:
        _paint.style = PaintingStyle.stroke;
        _paint.strokeWidth = (curSize * 0.15).clamp(1.0, 6.0);
        canvas.drawCircle(Offset.zero, curSize / 2, _paint);
        _paint.style = PaintingStyle.fill;
        break;

      case ParticleShape.line:
        _paint.style = PaintingStyle.stroke;
        _paint.strokeWidth = (curSize * 0.2).clamp(1.0, 4.0);
        canvas.drawLine(Offset(0, -curSize / 2), Offset(0, curSize / 2), _paint);
        _paint.style = PaintingStyle.fill;
        break;
    }

    canvas.restore();
  }

  static void _drawStar(Canvas canvas, double radius, Color color) {
    _path.reset();
    const points = 5;
    final outerRadius = radius;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      if (i == 0) {
        _path.moveTo(x, y);
      } else {
        _path.lineTo(x, y);
      }
    }
    _path.close();
    canvas.drawPath(_path, _paint);
  }
}
