import 'dart:collection';
import 'dart:math';

/// Cell kinds on the playable maze grid.
enum CellType {
  wall,
  path,
  start,
  end,
  gate,
}

/// Immutable maze produced by [MazeGenerator].
class GeneratedMaze {
  GeneratedMaze({
    required this.grid,
    required this.start,
    required this.end,
    required this.gates,
    required this.togglableCells,
    required this.shortestPathLength,
  });

  final List<List<CellType>> grid;
  final (int row, int col) start;
  final (int row, int col) end;

  /// Paired teleport gates: `(a, b)` means stepping on either jumps to the other.
  final List<((int, int), (int, int))> gates;

  /// Wall “door” cells that Moving Walls open/close on a timer.
  final List<(int, int)> togglableCells;

  final int shortestPathLength;

  int get rows => grid.length;
  int get cols => grid.isEmpty ? 0 : grid.first.length;

  CellType at(int r, int c) => grid[r][c];

  bool inBounds(int r, int c) =>
      r >= 0 && c >= 0 && r < rows && c < cols;

  bool isWalkable(int r, int c, {Set<(int, int)>? openDoors}) {
    if (!inBounds(r, c)) return false;
    if (openDoors != null && openDoors.contains((r, c))) return true;
    final t = grid[r][c];
    return t == CellType.path ||
        t == CellType.start ||
        t == CellType.end ||
        t == CellType.gate;
  }

  GeneratedMaze copyWithGrid(List<List<CellType>> newGrid) {
    return GeneratedMaze(
      grid: newGrid,
      start: start,
      end: end,
      gates: gates,
      togglableCells: togglableCells,
      shortestPathLength: shortestPathLength,
    );
  }
}

/// Recursive-backtracker maze generator — always yields a solvable maze.
class MazeGenerator {
  MazeGenerator([Random? rng]) : _rng = rng ?? Random();

  final Random _rng;

  static const _dirs = <(int, int)>[
    (-2, 0),
    (2, 0),
    (0, -2),
    (0, 2),
  ];

  /// Build a [size]×[size] maze. Size is clamped to ≥5.
  ///
  /// Passages live on odd coordinates; intervening walls are carved between
  /// visits — classic recursive backtracker. Start is nearest odd cell to the
  /// top-left; end is the BFS-farthest carved cell (guarantees a path).
  GeneratedMaze generate(
    int size, {
    bool withGates = false,
    bool withMovableWalls = false,
    int gatePairCount = 1,
    int movableCount = 4,
  }) {
    final n = size.clamp(5, 31);
    final grid = List.generate(
      n,
      (_) => List<CellType>.filled(n, CellType.wall),
    );

    // Odd passage coordinates inside the border.
    final maxOdd = n.isOdd ? n - 2 : n - 3;
    if (maxOdd < 1) {
      // Degenerate fallback — open a corridor.
      grid[1][1] = CellType.path;
      grid[1][n - 2] = CellType.path;
      grid[1][1] = CellType.start;
      grid[1][n - 2] = CellType.end;
      return GeneratedMaze(
        grid: grid,
        start: (1, 1),
        end: (1, n - 2),
        gates: const [],
        togglableCells: const [],
        shortestPathLength: n - 3,
      );
    }

    final startR = 1;
    final startC = 1;
    _carve(grid, startR, startC);

    final stack = <(int, int)>[(startR, startC)];
    while (stack.isNotEmpty) {
      final (r, c) = stack.last;
      final neighbors = <(int, int)>[];
      for (final (dr, dc) in _dirs) {
        final nr = r + dr;
        final nc = c + dc;
        if (nr >= 1 &&
            nc >= 1 &&
            nr <= maxOdd &&
            nc <= maxOdd &&
            grid[nr][nc] == CellType.wall) {
          neighbors.add((nr, nc));
        }
      }
      if (neighbors.isEmpty) {
        stack.removeLast();
        continue;
      }
      final (nr, nc) = neighbors[_rng.nextInt(neighbors.length)];
      final wr = (r + nr) ~/ 2;
      final wc = (c + nc) ~/ 2;
      _carve(grid, wr, wc);
      _carve(grid, nr, nc);
      stack.add((nr, nc));
    }

    final passages = <(int, int)>[];
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (grid[r][c] == CellType.path) passages.add((r, c));
      }
    }

    // Ensure connectivity: if somehow empty, punch a line.
    if (passages.isEmpty) {
      for (var c = 1; c <= maxOdd; c++) {
        grid[1][c] = CellType.path;
        passages.add((1, c));
      }
    }

    final start = (startR, startC);
    final distances = _bfsDistances(grid, start);
    var end = start;
    var best = -1;
    for (final p in passages) {
      final d = distances[p] ?? -1;
      if (d > best) {
        best = d;
        end = p;
      }
    }

    grid[start.$1][start.$2] = CellType.start;
    grid[end.$1][end.$2] = CellType.end;

    final reserved = <(int, int)>{start, end};
    final gates = <((int, int), (int, int))>[];
    if (withGates) {
      final candidates = passages
          .where((p) => !reserved.contains(p) && (distances[p] ?? 0) > 1)
          .toList()
        ..shuffle(_rng);
      final pairs = gatePairCount.clamp(1, 3);
      for (var i = 0; i + 1 < candidates.length && gates.length < pairs; i += 2) {
        final a = candidates[i];
        final b = candidates[i + 1];
        grid[a.$1][a.$2] = CellType.gate;
        grid[b.$1][b.$2] = CellType.gate;
        gates.add((a, b));
        reserved.add(a);
        reserved.add(b);
      }
    }

    final togglable = <(int, int)>[];
    if (withMovableWalls) {
      // Door cells: walls with ≥2 orthogonal walkable neighbors. They open into
      // shortcuts on a timer; when closed the original maze stays solvable.
      final doors = <(int, int)>[];
      const steps = [(-1, 0), (1, 0), (0, -1), (0, 1)];
      for (var r = 1; r < n - 1; r++) {
        for (var c = 1; c < n - 1; c++) {
          if (grid[r][c] != CellType.wall) continue;
          var walkNeighbors = 0;
          for (final (dr, dc) in steps) {
            final t = grid[r + dr][c + dc];
            if (t != CellType.wall) walkNeighbors++;
          }
          if (walkNeighbors >= 2) doors.add((r, c));
        }
      }
      doors.shuffle(_rng);
      final want = movableCount.clamp(2, 10);
      togglable.addAll(doors.take(want));
    }

    final shortest = distances[end] ?? best;
    assert(
      _hasPathAvoiding(grid, start, end, {}),
      'Generated maze must be solvable',
    );

    return GeneratedMaze(
      grid: grid,
      start: start,
      end: end,
      gates: gates,
      togglableCells: togglable,
      shortestPathLength: shortest < 0 ? 0 : shortest,
    );
  }

  static void _carve(List<List<CellType>> grid, int r, int c) {
    grid[r][c] = CellType.path;
  }

  /// BFS distances from [origin] over walkable cells.
  static Map<(int, int), int> _bfsDistances(
    List<List<CellType>> grid,
    (int, int) origin,
  ) {
    final rows = grid.length;
    final cols = grid.first.length;
    final dist = <(int, int), int>{origin: 0};
    final q = Queue<(int, int)>()..add(origin);
    const steps = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    while (q.isNotEmpty) {
      final (r, c) = q.removeFirst();
      final d = dist[(r, c)]!;
      for (final (dr, dc) in steps) {
        final nr = r + dr;
        final nc = c + dc;
        if (nr < 0 || nc < 0 || nr >= rows || nc >= cols) continue;
        final t = grid[nr][nc];
        if (t == CellType.wall) continue;
        final key = (nr, nc);
        if (dist.containsKey(key)) continue;
        dist[key] = d + 1;
        q.add(key);
      }
    }
    return dist;
  }

  static bool _hasPathAvoiding(
    List<List<CellType>> grid,
    (int, int) start,
    (int, int) end,
    Set<(int, int)> avoid,
  ) {
    if (avoid.contains(start) || avoid.contains(end)) return false;
    final rows = grid.length;
    final cols = grid.first.length;
    final seen = <(int, int)>{start};
    final q = Queue<(int, int)>()..add(start);
    const steps = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    while (q.isNotEmpty) {
      final (r, c) = q.removeFirst();
      if ((r, c) == end) return true;
      for (final (dr, dc) in steps) {
        final nr = r + dr;
        final nc = c + dc;
        if (nr < 0 || nc < 0 || nr >= rows || nc >= cols) continue;
        final key = (nr, nc);
        if (seen.contains(key) || avoid.contains(key)) continue;
        final t = grid[nr][nc];
        if (t == CellType.wall) continue;
        // Treat start/end/path/gate as walkable.
        seen.add(key);
        q.add(key);
      }
    }
    return false;
  }

  /// Partner gate for [cell], or null.
  static (int, int)? partnerGate(
    GeneratedMaze maze,
    (int, int) cell,
  ) {
    for (final (a, b) in maze.gates) {
      if (a == cell) return b;
      if (b == cell) return a;
    }
    return null;
  }
}
