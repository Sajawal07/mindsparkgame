import 'maze_cell.dart';
import 'maze_type.dart';

class MazeGraphData {
  MazeGraphData({
    required this.type,
    required this.startId,
    required this.endId,
    required this.cells,
    required this.adjacencies,
    required this.solutionPath,
  });

  final MazeType type;
  final String startId;
  final String endId;
  final Map<String, MazeCell> cells;
  final Map<String, Map<String, String>> adjacencies; // cellId -> (direction -> neighborId)
  final List<String> solutionPath;

  bool isConnected(String cellId, String neighborId) {
    final moves = adjacencies[cellId];
    if (moves == null) return false;
    return moves.containsValue(neighborId);
  }

  String? getNeighborInDirection(String cellId, String direction) {
    return adjacencies[cellId]?[direction];
  }

  Set<String> getValidDirections(String cellId) {
    return adjacencies[cellId]?.keys.toSet() ?? {};
  }
}
