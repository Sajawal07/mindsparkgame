import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_assets.dart';

enum Sfx {
  correct,
  wrong,
  puzzleComplete,
  dailyComplete,
  coin,
  levelUp,
  achievement,
  streakReward,
  blitzMultiplier,
  blitzCountdown,
  arenaVictory,
  arenaDefeat,
  button,
  pageChange,
  softTap,
  whoosh,
}

class AudioSettings {
  const AudioSettings({
    this.masterVolume = 1.0,
    this.musicVolume = 0.6,
    this.sfxVolume = 1.0,
    this.muted = false,
  });

  final double masterVolume;
  final double musicVolume;
  final double sfxVolume;
  final bool muted;

  Map<String, dynamic> toJson() => {
        'masterVolume': masterVolume,
        'musicVolume': musicVolume,
        'sfxVolume': sfxVolume,
        'muted': muted,
      };

  factory AudioSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AudioSettings();
    return AudioSettings(
      masterVolume: (json['masterVolume'] as num?)?.toDouble() ?? 1.0,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.6,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 1.0,
      muted: json['muted'] as bool? ?? false,
    );
  }

  AudioSettings copyWith({
    double? masterVolume,
    double? musicVolume,
    double? sfxVolume,
    bool? muted,
  }) {
    return AudioSettings(
      masterVolume: masterVolume ?? this.masterVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      muted: muted ?? this.muted,
    );
  }
}

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  AudioSettings settings = const AudioSettings();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    _initialized = true;
  }

  void applySettings(AudioSettings value) {
    settings = value;
    if (settings.muted) {
      _musicPlayer.stop();
    }
  }

  double get _effectiveSfxVolume =>
      settings.muted ? 0 : settings.masterVolume * settings.sfxVolume;

  String _pathFor(Sfx sfx) => switch (sfx) {
        Sfx.correct => AppAssets.sfxCorrect,
        Sfx.wrong => AppAssets.sfxWrong,
        Sfx.puzzleComplete => AppAssets.sfxPuzzleComplete,
        Sfx.dailyComplete => AppAssets.sfxDailyComplete,
        Sfx.coin => AppAssets.sfxCoin,
        Sfx.levelUp => AppAssets.sfxLevelUp,
        Sfx.achievement => AppAssets.sfxAchievement,
        Sfx.streakReward => AppAssets.sfxStreakReward,
        Sfx.blitzMultiplier => AppAssets.sfxBlitzMultiplier,
        Sfx.blitzCountdown => AppAssets.sfxBlitzTick,
        Sfx.arenaVictory => AppAssets.sfxArenaVictory,
        Sfx.arenaDefeat => AppAssets.sfxArenaDefeat,
        Sfx.button => AppAssets.sfxButton,
        Sfx.pageChange => AppAssets.sfxPageChange,
        Sfx.softTap => AppAssets.sfxSoftTap,
        Sfx.whoosh => AppAssets.sfxWhoosh,
      };

  Future<void> playSfx(Sfx sfx) async {
    if (!_initialized) await init();
    final vol = _effectiveSfxVolume;
    if (vol <= 0) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(vol);
      await _sfxPlayer.play(AssetSource(_stripAssetPrefix(_pathFor(sfx))));
    } catch (e) {
      debugPrint('AudioService.playSfx($sfx): $e');
    }
  }

  /// AssetSource expects path without "assets/" prefix for some versions — use full asset path.
  String _stripAssetPrefix(String path) {
    if (path.startsWith('assets/')) return path.substring(7);
    return path;
  }

  Future<void> playButtonTap() => playSfx(Sfx.button);

  Future<void> playPageChange() => playSfx(Sfx.pageChange);

  Future<void> playSoftTap() => playSfx(Sfx.softTap);

  Future<void> playWhoosh() => playSfx(Sfx.whoosh);
}

