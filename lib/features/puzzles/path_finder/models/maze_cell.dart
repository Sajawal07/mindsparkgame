abstract class MazeCell {
  MazeCell({this.visited = false});

  bool visited;
}

class SquareMazeCell extends MazeCell {
  SquareMazeCell({
    required this.row,
    required this.col,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.left = true,
    super.visited,
  });

  final int row;
  final int col;
  bool top;
  bool right;
  bool bottom;
  bool left;

  String get id => '$row,$col';
}

class CircularMazeCell extends MazeCell {
  CircularMazeCell({
    required this.ring,
    required this.segment,
    this.inner = true,
    this.outer = true,
    this.clockwise = true,
    this.counterClockwise = true,
    super.visited,
  });

  final int ring;
  final int segment;
  bool inner;
  bool outer;
  bool clockwise;
  bool counterClockwise;

  String get id => '$ring,$segment';
}

class TriangleMazeCell extends MazeCell {
  TriangleMazeCell({
    required this.row,
    required this.col,
    required this.isPointingUp,
    this.left = true,
    this.right = true,
    this.base = true,
    super.visited,
  });

  final int row;
  final int col;
  final bool isPointingUp;
  bool left;
  bool right;
  bool base;

  /// Ups and downs can share (row,col) — prefix keeps ids unique.
  String get id => isPointingUp ? 'u,$row,$col' : 'd,$row,$col';
}
