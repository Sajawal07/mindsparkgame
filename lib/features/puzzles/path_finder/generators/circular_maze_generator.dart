import 'dart:math';

import '../models/generated_maze.dart';
import '../models/maze_cell.dart';
import '../models/maze_difficulty.dart';
import '../models/maze_type.dart';
import 'maze_generator.dart';

class CircularMazeGenerator implements MazeGenerator {
  CircularMazeGenerator([Random? rng]) : _rng = rng ?? Random();

  final Random _rng;

  @override
  MazeGraphData generate(MazeDifficulty difficulty, {int mapIndex = 0}) {
    final (totalRings, segmentsPerRing) =
        difficulty.circularConfigForMap(mapIndex);

    final grid = <int, List<CircularMazeCell>>{};
    final cells = <String, CircularMazeCell>{};

    for (var r = 0; r < totalRings; r++) {
      grid[r] = List.generate(
        segmentsPerRing,
        (s) => CircularMazeCell(ring: r, segment: s),
      );
      for (final cell in grid[r]!) {
        cells[cell.id] = cell;
      }
    }

    final startCell = grid[totalRings - 1]![0];
    final endCell = grid[0]![segmentsPerRing ~/ 2];
    startCell.visited = true;

    // Growing Tree → more dead-end branches (still one true path).
    final active = <CircularMazeCell>[startCell];

    while (active.isNotEmpty) {
      final idx = _rng.nextDouble() < 0.7
          ? active.length - 1
          : _rng.nextInt(active.length);
      final current = active[idx];
      final unvisitedNeighbors = <(CircularMazeCell, String)>[];

      final r = current.ring;
      final s = current.segment;

      final cwSeg = (s + 1) % segmentsPerRing;
      if (!grid[r]![cwSeg].visited) {
        unvisitedNeighbors.add((grid[r]![cwSeg], 'cw'));
      }

      final ccwSeg = (s - 1 + segmentsPerRing) % segmentsPerRing;
      if (!grid[r]![ccwSeg].visited) {
        unvisitedNeighbors.add((grid[r]![ccwSeg], 'ccw'));
      }

      if (r > 0 && !grid[r - 1]![s].visited) {
        unvisitedNeighbors.add((grid[r - 1]![s], 'inner'));
      }

      if (r < totalRings - 1 && !grid[r + 1]![s].visited) {
        unvisitedNeighbors.add((grid[r + 1]![s], 'outer'));
      }

      if (unvisitedNeighbors.isEmpty) {
        active.removeAt(idx);
        continue;
      }

      final chosen = unvisitedNeighbors[_rng.nextInt(unvisitedNeighbors.length)];
      final neighbor = chosen.$1;
      final dir = chosen.$2;

      if (dir == 'cw') {
        current.clockwise = false;
        neighbor.counterClockwise = false;
      } else if (dir == 'ccw') {
        current.counterClockwise = false;
        neighbor.clockwise = false;
      } else if (dir == 'inner') {
        current.inner = false;
        neighbor.outer = false;
      } else if (dir == 'outer') {
        current.outer = false;
        neighbor.inner = false;
      }

      neighbor.visited = true;
      active.add(neighbor);
    }

    final adjacencies = <String, Map<String, String>>{};
    for (var r = 0; r < totalRings; r++) {
      for (var s = 0; s < segmentsPerRing; s++) {
        final cell = grid[r]![s];
        final moves = <String, String>{};

        if (!cell.inner && r > 0) {
          moves['in'] = grid[r - 1]![s].id;
        }
        if (!cell.outer && r < totalRings - 1) {
          moves['out'] = grid[r + 1]![s].id;
        }
        if (!cell.clockwise) {
          final cwSeg = (s + 1) % segmentsPerRing;
          moves['cw'] = grid[r]![cwSeg].id;
        }
        if (!cell.counterClockwise) {
          final ccwSeg = (s - 1 + segmentsPerRing) % segmentsPerRing;
          moves['ccw'] = grid[r]![ccwSeg].id;
        }

        adjacencies[cell.id] = moves;
      }
    }

    final solution = MazeGenerator.solveBfs(
      startId: startCell.id,
      endId: endCell.id,
      adjacencies: adjacencies,
    );

    return MazeGraphData(
      type: MazeType.circular,
      startId: startCell.id,
      endId: endCell.id,
      cells: cells,
      adjacencies: adjacencies,
      solutionPath: solution,
    );
  }
}
