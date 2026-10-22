import 'package:flutter/material.dart';

import '../models/generated_maze.dart';
import '../models/maze_cell.dart';

class TriangleMazePainter extends CustomPainter {
  TriangleMazePainter({
    required this.mazeData,
    required this.currentCellId,
    required this.traveledPath,
    this.showSolution = false,
    this.solutionAnimationProgress = 1.0,
    required this.primaryColor,
    required this.accentColor,
    required this.wallColor,
  });

  final MazeGraphData mazeData;
  final String currentCellId;
  final List<String> traveledPath;
  final bool showSolution;
  final double solutionAnimationProgress;
  final Color primaryColor;
  final Color accentColor;
  final Color wallColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cells = mazeData.cells.cast<String, TriangleMazeCell>();
    if (cells.isEmpty) return;

    var n = 1;
    for (final cell in cells.values) {
      if (cell.isPointingUp && cell.row + 1 > n) n = cell.row + 1;
    }

    final pad = size.width * 0.04;
    final usableW = size.width - pad * 2;
    final usableH = size.height - pad * 2;
    final side = (usableW / n).clamp(4.0, usableH / (n * 0.9));
    final triH = side * 0.86602540378; // √3/2
    final origin = Offset(
      pad + (usableW - n * side) / 2,
      pad + (usableH - n * triH) / 2,
    );

    Offset point(int i, int j) {
      return Offset(
        origin.dx + (j + (n - i) * 0.5) * side,
        origin.dy + i * triH,
      );
    }

    (Offset, Offset, Offset) verticesOf(TriangleMazeCell cell) {
      final r = cell.row;
      final c = cell.col;
      if (cell.isPointingUp) {
        // (r,c), (r+1,c), (r+1,c+1)
        return (point(r, c), point(r + 1, c), point(r + 1, c + 1));
      }
      // Down: (r,c), (r,c+1), (r+1,c+1)
      return (point(r, c), point(r, c + 1), point(r + 1, c + 1));
    }

    Offset centerOf(TriangleMazeCell cell) {
      final (a, b, c) = verticesOf(cell);
      return Offset((a.dx + b.dx + c.dx) / 3, (a.dy + b.dy + c.dy) / 3);
    }

    Offset centerById(String id) {
      final cell = cells[id];
      if (cell == null) return Offset.zero;
      return centerOf(cell);
    }

    final wallPaint = Paint()
      ..color = wallColor
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (final cell in cells.values) {
      final (v0, v1, v2) = verticesOf(cell);
      // Edge mapping for up: left=v0-v1, right=v0-v2, base=v1-v2
      // Down: left=v0-v2, right=v1-v2, base=v0-v1
      if (cell.isPointingUp) {
        if (cell.left) canvas.drawLine(v0, v1, wallPaint);
        if (cell.right) canvas.drawLine(v0, v2, wallPaint);
        if (cell.base) canvas.drawLine(v1, v2, wallPaint);
      } else {
        if (cell.base) canvas.drawLine(v0, v1, wallPaint);
        if (cell.right) canvas.drawLine(v1, v2, wallPaint);
        if (cell.left) canvas.drawLine(v0, v2, wallPaint);
      }
    }

    final markerR = triH * 0.22;
    _drawMarker(canvas, centerById(mazeData.startId), 'A', const Color(0xFF4CAF50), markerR);
    _drawMarker(canvas, centerById(mazeData.endId), 'B', const Color(0xFFFF5252), markerR);

    if (showSolution && mazeData.solutionPath.length > 1) {
      final solutionPaint = Paint()
        ..color = Colors.amber.withValues(alpha: 0.85)
        ..strokeWidth = 3.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final first = centerById(mazeData.solutionPath.first);
      path.moveTo(first.dx, first.dy);
      final visibleCount = (mazeData.solutionPath.length * solutionAnimationProgress)
          .clamp(1, mazeData.solutionPath.length)
          .toInt();
      for (var i = 1; i < visibleCount; i++) {
        final pt = centerById(mazeData.solutionPath[i]);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, solutionPaint);
    }

    if (traveledPath.length > 1) {
      final trailPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.45)
        ..strokeWidth = (side * 0.18).clamp(2.0, 8.0)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final trail = Path();
      final p0 = centerById(traveledPath.first);
      trail.moveTo(p0.dx, p0.dy);
      for (var i = 1; i < traveledPath.length; i++) {
        final pt = centerById(traveledPath[i]);
        trail.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(trail, trailPaint);
    }

    final playerPos = centerById(currentCellId);
    final playerR = (side * 0.16).clamp(4.0, 14.0);

    canvas.drawCircle(
      playerPos,
      playerR + 4,
      Paint()
        ..color = accentColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(playerPos, playerR, Paint()..color = accentColor);
    canvas.drawCircle(playerPos, playerR * 0.4, Paint()..color = Colors.white);
  }

  void _drawMarker(Canvas canvas, Offset pos, String text, Color color, double radius) {
    canvas.drawCircle(pos, radius + 2, Paint()..color = color.withValues(alpha: 0.3));
    canvas.drawCircle(pos, radius, Paint()..color = color);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 1.1,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant TriangleMazePainter oldDelegate) {
    return oldDelegate.currentCellId != currentCellId ||
        oldDelegate.traveledPath != traveledPath ||
        oldDelegate.showSolution != showSolution ||
        oldDelegate.solutionAnimationProgress != solutionAnimationProgress ||
        oldDelegate.mazeData != mazeData;
  }
}
