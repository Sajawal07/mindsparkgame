import 'dart:math';

import '../models/generated_maze.dart';
import '../models/maze_cell.dart';
import '../models/maze_difficulty.dart';
import '../models/maze_type.dart';
import 'maze_generator.dart';

/// Perfect maze (exactly one route start→end) with many dead-end branches.
/// Growing Tree (newest + random) avoids long single corridors.
class SquareMazeGenerator implements MazeGenerator {
  SquareMazeGenerator([Random? rng]) : _rng = rng ?? Random();

  final Random _rng;

  @override
  MazeGraphData generate(MazeDifficulty difficulty, {int mapIndex = 0}) {
    final size = difficulty.squareGridSizeForMap(mapIndex);
    final minDecisionPoints = max(2, size ~/ 3);

    MazeGraphData? best;
    var bestScore = -1;

    // Try a few layouts; keep the branchiest valid maze.
    for (var attempt = 0; attempt < 8; attempt++) {
      final candidate = _carve(size);
      final decisions = _decisionPointsOnSolution(candidate);
      final deadEnds = _deadEndCount(candidate);
      final score = decisions * 10 + deadEnds;
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
      if (decisions >= minDecisionPoints && deadEnds >= size) break;
    }

    return best!;
  }

  MazeGraphData _carve(int size) {
    final rows = size;
    final cols = size;

    final grid = List.generate(
      rows,
      (r) => List.generate(cols, (c) => SquareMazeCell(row: r, col: c)),
    );

    final cells = <String, SquareMazeCell>{};
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        cells[grid[r][c].id] = grid[r][c];
      }
    }

    final startCell = grid[0][0];
    final endCell = grid[rows - 1][cols - 1];
    startCell.visited = true;

    // Growing Tree: 70% pick newest (winding), 30% random (more branches).
    final active = <SquareMazeCell>[startCell];

    while (active.isNotEmpty) {
      final useNewest = _rng.nextDouble() < 0.7;
      final idx = useNewest ? active.length - 1 : _rng.nextInt(active.length);
      final current = active[idx];

      final unvisitedNeighbors = <(SquareMazeCell, String)>[];
      if (current.row > 0 && !grid[current.row - 1][current.col].visited) {
        unvisitedNeighbors.add((grid[current.row - 1][current.col], 'top'));
      }
      if (current.col < cols - 1 && !grid[current.row][current.col + 1].visited) {
        unvisitedNeighbors.add((grid[current.row][current.col + 1], 'right'));
      }
      if (current.row < rows - 1 && !grid[current.row + 1][current.col].visited) {
        unvisitedNeighbors.add((grid[current.row + 1][current.col], 'bottom'));
      }
      if (current.col > 0 && !grid[current.row][current.col - 1].visited) {
        unvisitedNeighbors.add((grid[current.row][current.col - 1], 'left'));
      }

      if (unvisitedNeighbors.isEmpty) {
        active.removeAt(idx);
        continue;
      }

      final chosen = unvisitedNeighbors[_rng.nextInt(unvisitedNeighbors.length)];
      final neighbor = chosen.$1;
      final dir = chosen.$2;

      if (dir == 'top') {
        current.top = false;
        neighbor.bottom = false;
      } else if (dir == 'right') {
        current.right = false;
        neighbor.left = false;
      } else if (dir == 'bottom') {
        current.bottom = false;
        neighbor.top = false;
      } else if (dir == 'left') {
        current.left = false;
        neighbor.right = false;
      }

      neighbor.visited = true;
      active.add(neighbor);
    }

    final adjacencies = <String, Map<String, String>>{};
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final cell = grid[r][c];
        final moves = <String, String>{};
        if (!cell.top && r > 0) moves['up'] = grid[r - 1][c].id;
        if (!cell.bottom && r < rows - 1) moves['down'] = grid[r + 1][c].id;
        if (!cell.left && c > 0) moves['left'] = grid[r][c - 1].id;
        if (!cell.right && c < cols - 1) moves['right'] = grid[r][c + 1].id;
        adjacencies[cell.id] = moves;
      }
    }

    final solution = MazeGenerator.solveBfs(
      startId: startCell.id,
      endId: endCell.id,
      adjacencies: adjacencies,
    );

    return MazeGraphData(
      type: MazeType.square,
      startId: startCell.id,
      endId: endCell.id,
      cells: cells,
      adjacencies: adjacencies,
      solutionPath: solution,
    );
  }

  int _decisionPointsOnSolution(MazeGraphData maze) {
    var count = 0;
    for (final id in maze.solutionPath) {
      final degree = maze.adjacencies[id]?.length ?? 0;
      if (degree >= 3) count++;
    }
    return count;
  }

  int _deadEndCount(MazeGraphData maze) {
    var count = 0;
    for (final entry in maze.adjacencies.entries) {
      if (entry.key == maze.startId || entry.key == maze.endId) continue;
      if (entry.value.length == 1) count++;
    }
    return count;
  }
}
