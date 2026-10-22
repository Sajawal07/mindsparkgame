enum MazeType {
  square,
  circular,
  triangle;

  String get displayName => switch (this) {
        square => 'Square Grid',
        circular => 'Circular Polar',
        triangle => 'Triangle Tessellation',
      };

  String get description => switch (this) {
        square => 'Classic 2D grid maze with 4-way movement.',
        circular => 'Concentric rings with polar movement & arcs.',
        triangle => 'Triangular mesh with orientation-aware edges.',
      };
}
