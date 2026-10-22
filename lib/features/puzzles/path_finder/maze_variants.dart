import 'dart:math';

import 'package:flutter/material.dart';

import 'maze_generator.dart';
import 'path_finder_config.dart';

/// Visual skin applied on top of the core maze engine.
enum MazeSkin {
  classic,
  neon,
}

/// Rule / presentation modifiers stacked onto the core maze.
enum MazeModifierKind {
  classic,
  neon,
  timeMaze,
  fog,
  movingWalls,
  teleportGates,
}

/// Resolved play profile — skins + rule modifiers.
class MazeVariantProfile {
  const MazeVariantProfile({
    required this.id,
    required this.label,
    required this.skin,
    this.timed = false,
    this.fog = false,
    this.movingWalls = false,
    this.teleports = false,
    this.description = '',
  });

  final String id;
  final String label;
  final MazeSkin skin;
  final bool timed;
  final bool fog;
  final bool movingWalls;
  final bool teleports;
  final String description;

  bool get usesNeon => skin == MazeSkin.neon;

  /// Classic maze, no extra rules.
  static const classic = MazeVariantProfile(
    id: 'classic',
    label: 'Classic',
    skin: MazeSkin.classic,
    description: 'Clean corridors. Trace start → end.',
  );

  /// Neon skin only (default look).
  static const neon = MazeVariantProfile(
    id: 'neon',
    label: 'Neon',
    skin: MazeSkin.neon,
    description: 'Cyan / magenta glow trails.',
  );

  /// Countdown clock — fail if time hits zero.
  static const timeMaze = MazeVariantProfile(
    id: 'time_maze',
    label: 'Time Maze',
    skin: MazeSkin.neon,
    timed: true,
    description: 'Beat the clock through the neon maze.',
  );

  /// Finger-local visibility (fog of war).
  static const fogDark = MazeVariantProfile(
    id: 'fog',
    label: 'Fog',
    skin: MazeSkin.neon,
    fog: true,
    description: 'Only a circle around your finger is lit.',
  );

  /// Subset of corridors seal / reopen on a timer.
  static const shiftingWalls = MazeVariantProfile(
    id: 'moving_walls',
    label: 'Moving Walls',
    skin: MazeSkin.neon,
    movingWalls: true,
    description: 'Corridors lock and unlock every few seconds.',
  );

  /// Paired teleport gates on the path.
  static const teleportGates = MazeVariantProfile(
    id: 'teleport',
    label: 'Teleport Gates',
    skin: MazeSkin.neon,
    teleports: true,
    description: 'Step a gate to jump to its twin.',
  );

  /// Arena default: neon look + timed round.
  static const arenaDefault = MazeVariantProfile(
    id: 'arena_neon_time',
    label: 'Arena',
    skin: MazeSkin.neon,
    timed: true,
    description: 'Timed neon maze for Arena duels.',
  );

  static const List<MazeVariantProfile> catalog = [
    classic,
    neon,
    timeMaze,
    fogDark,
    shiftingWalls,
    teleportGates,
  ];

  MazeVariantProfile copyWith({
    String? id,
    String? label,
    MazeSkin? skin,
    bool? timed,
    bool? fog,
    bool? movingWalls,
    bool? teleports,
    String? description,
  }) {
    return MazeVariantProfile(
      id: id ?? this.id,
      label: label ?? this.label,
      skin: skin ?? this.skin,
      timed: timed ?? this.timed,
      fog: fog ?? this.fog,
      movingWalls: movingWalls ?? this.movingWalls,
      teleports: teleports ?? this.teleports,
      description: description ?? this.description,
    );
  }
}

/// Palette resolved from [MazeSkin].
class MazePalette {
  const MazePalette({
    required this.wall,
    required this.path,
    required this.start,
    required this.end,
    required this.trail,
    required this.trailGlow,
    required this.gate,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.accent,
    required this.sealedWall,
  });

  final Color wall;
  final Color path;
  final Color start;
  final Color end;
  final Color trail;
  final Color trailGlow;
  final Color gate;
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color accent;
  final Color sealedWall;

  static MazePalette forSkin(MazeSkin skin) {
    switch (skin) {
      case MazeSkin.classic:
        return const MazePalette(
          wall: PathFinderConfig.classicWall,
          path: PathFinderConfig.classicPath,
          start: Color(0xFF2E7D32),
          end: Color(0xFFC62828),
          trail: Color(0xFF1565C0),
          trailGlow: Color(0x661565C0),
          gate: Color(0xFF6A1B9A),
          backgroundTop: Color(0xFF1B1B1F),
          backgroundBottom: Color(0xFF101014),
          accent: PathFinderConfig.classicAccent,
          sealedWall: Color(0xFF5D4037),
        );
      case MazeSkin.neon:
        return const MazePalette(
          wall: PathFinderConfig.wallFill,
          path: PathFinderConfig.pathFill,
          start: PathFinderConfig.neonCyan,
          end: PathFinderConfig.neonMagenta,
          trail: PathFinderConfig.neonCyan,
          trailGlow: Color(0xAA00F5FF),
          gate: PathFinderConfig.neonPurple,
          backgroundTop: PathFinderConfig.neonBgTop,
          backgroundBottom: PathFinderConfig.neonBgBottom,
          accent: PathFinderConfig.neonMagenta,
          sealedWall: Color(0xFF4A148C),
        );
    }
  }
}

/// Applies variant flags when asking the generator for a maze.
class MazeVariantEngine {
  const MazeVariantEngine(this.profile);

  final MazeVariantProfile profile;

  GeneratedMaze generate(int size, {Random? rng}) {
    final gen = MazeGenerator(rng);
    return gen.generate(
      size,
      withGates: profile.teleports,
      withMovableWalls: profile.movingWalls,
      gatePairCount: profile.teleports ? 1 : 0,
      movableCount: profile.movingWalls ? (size >= 12 ? 6 : 4) : 0,
    );
  }

  MazePalette get palette => MazePalette.forSkin(profile.skin);

  /// Moving-walls toggle interval.
  Duration get wallToggleInterval => const Duration(milliseconds: 2800);

  /// Fog reveal radius as a fraction of the maze short side.
  double get fogRadiusFraction => 0.22;
}
