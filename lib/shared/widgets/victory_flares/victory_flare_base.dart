import 'package:flutter/material.dart';

/// Enumeration of supported victory flare types.
enum VictoryFlareType {
  trainingBoost('flair_training_boost', 'Training Boost'),
  fireStorm('flair_fire_storm', 'Fire Storm'),
  lightningStrike('flair_lightning_strike', 'Lightning Strike'),
  confettiCannon('flair_confetti_cannon', 'Confetti Cannon'),
  galaxyBurst('flair_galaxy_burst', 'Galaxy Burst');

  final String id;
  final String displayName;
  const VictoryFlareType(this.id, this.displayName);

  static VictoryFlareType? fromId(String? id) {
    if (id == null) return null;
    for (final type in VictoryFlareType.values) {
      if (type.id == id) return type;
    }
    return null;
  }
}

/// Controller interface to programmatically manage a flare lifecycle.
class VictoryFlareController extends ChangeNotifier {
  VictoryFlareController({
    Duration duration = const Duration(milliseconds: 3000),
    double intensity = 1.0,
    int? particleCount,
  })  : _duration = duration,
        _intensity = intensity,
        _particleCount = particleCount;

  Duration _duration;
  double _intensity;
  int? _particleCount;
  bool _isPlaying = false;

  Duration get duration => _duration;
  double get intensity => _intensity;
  int? get particleCount => _particleCount;
  bool get isPlaying => _isPlaying;

  void start() {
    _isPlaying = true;
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    notifyListeners();
  }

  void updateConfig({
    Duration? duration,
    double? intensity,
    int? particleCount,
  }) {
    if (duration != null) _duration = duration;
    if (intensity != null) _intensity = intensity;
    if (particleCount != null) _particleCount = particleCount;
    notifyListeners();
  }
}

/// Base configuration options passed down to CustomPainters for flare rendering.
class VictoryFlareOptions {
  final double intensity;
  final int particleCount;
  final bool isThumbnail;

  const VictoryFlareOptions({
    this.intensity = 1.0,
    this.particleCount = 100,
    this.isThumbnail = false,
  });
}
