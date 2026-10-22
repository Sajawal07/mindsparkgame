import 'dart:collection';

import '../models/generated_maze.dart';
import '../models/maze_difficulty.dart';

abstract class MazeGenerator {
  /// [mapIndex] is 0-based (0..29). Same index + seeded RNG ⇒ same map.
  MazeGraphData generate(MazeDifficulty difficulty, {int mapIndex = 0});

  /// Standard BFS shortest-path solver on open adjacencies.
  static List<String> solveBfs({
    required String startId,
    required String endId,
    required Map<String, Map<String, String>> adjacencies,
  }) {
    if (startId == endId) return [startId];

    final queue = Queue<String>()..add(startId);
    final parentMap = <String, String>{};
    final visited = <String>{startId};

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == endId) break;

      final neighbors = adjacencies[current]?.values ?? [];
      for (final neighbor in neighbors) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          parentMap[neighbor] = current;
          queue.add(neighbor);
        }
      }
    }

    if (!parentMap.containsKey(endId)) {
      return [];
    }

    final path = <String>[endId];
    String? curr = endId;
    while (curr != null && curr != startId) {
      curr = parentMap[curr];
      if (curr != null) {
        path.add(curr);
      }
    }

    return path.reversed.toList();
  }
}
