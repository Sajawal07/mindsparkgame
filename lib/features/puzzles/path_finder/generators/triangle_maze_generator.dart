import 'dart:math';

import '../models/generated_maze.dart';
import '../models/maze_cell.dart';
import '../models/maze_difficulty.dart';
import '../models/maze_type.dart';
import 'maze_generator.dart';

/// Triangle maze: subdivision of a large triangle into up/down unit cells.
/// Each open wall is a real shared edge — path never cuts through walls.
class TriangleMazeGenerator implements MazeGenerator {
  TriangleMazeGenerator([Random? rng]) : _rng = rng ?? Random();

  final Random _rng;

  @override
  MazeGraphData generate(MazeDifficulty difficulty, {int mapIndex = 0}) {
    final n = difficulty.triangleRowsForMap(mapIndex).clamp(3, 40);

    final ups = <(int, int), TriangleMazeCell>{};
    final downs = <(int, int), TriangleMazeCell>{};
    final keyedCells = <String, TriangleMazeCell>{};

    for (var r = 0; r < n; r++) {
      for (var c = 0; c <= r; c++) {
        final cell = TriangleMazeCell(row: r, col: c, isPointingUp: true);
        ups[(r, c)] = cell;
        keyedCells[cell.id] = cell;
      }
    }
    for (var r = 1; r < n; r++) {
      for (var c = 0; c < r; c++) {
        final cell = TriangleMazeCell(row: r, col: c, isPointingUp: false);
        downs[(r, c)] = cell;
        keyedCells[cell.id] = cell;
      }
    }

    List<(TriangleMazeCell, String, String)> linksOf(TriangleMazeCell cell) {
      final out = <(TriangleMazeCell, String, String)>[];
      final r = cell.row;
      final c = cell.col;

      if (cell.isPointingUp) {
        final base = downs[(r + 1, c)];
        if (base != null) out.add((base, 'base', 'base'));
        final left = downs[(r, c - 1)];
        if (left != null) out.add((left, 'left', 'right'));
        final right = downs[(r, c)];
        if (right != null) out.add((right, 'right', 'left'));
      } else {
        final base = ups[(r - 1, c)];
        if (base != null) out.add((base, 'base', 'base'));
        final left = ups[(r, c)];
        if (left != null) out.add((left, 'left', 'right'));
        final right = ups[(r, c + 1)];
        if (right != null) out.add((right, 'right', 'left'));
      }
      return out;
    }

    void openWall(TriangleMazeCell cell, String dir) {
      switch (dir) {
        case 'left':
          cell.left = false;
        case 'right':
          cell.right = false;
        case 'base':
          cell.base = false;
      }
    }

    // Growing Tree (50% newest / 50% random) → more dead-end branches.
    final start = ups[(0, 0)]!;
    final end = ups[(n - 1, n - 1)]!;
    start.visited = true;
    final active = <TriangleMazeCell>[start];

    while (active.isNotEmpty) {
      final idx = _rng.nextBool() ? active.length - 1 : _rng.nextInt(active.length);
      final current = active[idx];
      final options =
          linksOf(current).where((t) => !t.$1.visited).toList()..shuffle(_rng);

      if (options.isEmpty) {
        active.removeAt(idx);
        continue;
      }

      final pick = options.first;
      final neighbor = pick.$1;
      openWall(current, pick.$2);
      openWall(neighbor, pick.$3);
      neighbor.visited = true;
      active.add(neighbor);
    }

    final adjacencies = <String, Map<String, String>>{};
    for (final cell in keyedCells.values) {
      final moves = <String, String>{};
      for (final link in linksOf(cell)) {
        final dir = link.$2;
        final open = switch (dir) {
          'left' => !cell.left,
          'right' => !cell.right,
          'base' => !cell.base,
          _ => false,
        };
        if (open) moves[dir] = link.$1.id;
      }
      adjacencies[cell.id] = moves;
    }

    final solution = MazeGenerator.solveBfs(
      startId: start.id,
      endId: end.id,
      adjacencies: adjacencies,
    );

    return MazeGraphData(
      type: MazeType.triangle,
      startId: start.id,
      endId: end.id,
      cells: keyedCells,
      adjacencies: adjacencies,
      solutionPath: solution,
    );
  }
}
