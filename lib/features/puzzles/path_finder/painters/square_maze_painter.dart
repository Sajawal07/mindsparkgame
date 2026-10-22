import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/generated_maze.dart';
import '../models/maze_cell.dart';

class SquareMazePainter extends CustomPainter {
  SquareMazePainter({
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
    final cells = mazeData.cells.cast<String, SquareMazeCell>();
    if (cells.isEmpty) return;

    int maxRow = 0;
    int maxCol = 0;
    for (final cell in cells.values) {
      if (cell.row > maxRow) maxRow = cell.row;
      if (cell.col > maxCol) maxCol = cell.col;
    }
    final rows = maxRow + 1;
    final cols = maxCol + 1;

    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    // 1. Draw Walls
    final wallPaint = Paint()
      ..color = wallColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (final cell in cells.values) {
      final left = cell.col * cellWidth;
      final top = cell.row * cellHeight;
      final right = left + cellWidth;
      final bottom = top + cellHeight;

      if (cell.top) canvas.drawLine(Offset(left, top), Offset(right, top), wallPaint);
      if (cell.right) canvas.drawLine(Offset(right, top), Offset(right, bottom), wallPaint);
      if (cell.bottom) canvas.drawLine(Offset(left, bottom), Offset(right, bottom), wallPaint);
      if (cell.left) canvas.drawLine(Offset(left, top), Offset(left, bottom), wallPaint);
    }

    // Offset calculation helper
    Offset cellCenter(String id) {
      final c = cells[id];
      if (c == null) return Offset.zero;
      return Offset(
        c.col * cellWidth + cellWidth / 2,
        c.row * cellHeight + cellHeight / 2,
      );
    }

    // 2. Draw Start "A" and End "B"
    final startOffset = cellCenter(mazeData.startId);
    final endOffset = cellCenter(mazeData.endId);

    _drawMarker(canvas, startOffset, 'A', const Color(0xFF4CAF50), cellWidth * 0.35);
    _drawMarker(canvas, endOffset, 'B', const Color(0xFFFF5252), cellWidth * 0.35);

    // 3. Draw Hint / Solution path if active
    if (showSolution && mazeData.solutionPath.length > 1) {
      final solutionPaint = Paint()
        ..color = Colors.amber.withOpacity(0.85)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(startOffset.dx, startOffset.dy);

      final visibleCount = (mazeData.solutionPath.length * solutionAnimationProgress).clamp(1, mazeData.solutionPath.length).toInt();
      for (var i = 1; i < visibleCount; i++) {
        final pt = cellCenter(mazeData.solutionPath[i]);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, solutionPaint);
    }

    // 4. Draw Traveled Trail
    if (traveledPath.length > 1) {
      final trailPaint = Paint()
        ..color = primaryColor.withOpacity(0.4)
        ..strokeWidth = cellWidth * 0.25
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final trailPath = Path();
      final startPt = cellCenter(traveledPath.first);
      trailPath.moveTo(startPt.dx, startPt.dy);
      for (var i = 1; i < traveledPath.length; i++) {
        final pt = cellCenter(traveledPath[i]);
        trailPath.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(trailPath, trailPaint);
    }

    // 5. Draw Player Node
    final playerPos = cellCenter(currentCellId);
    final playerRadius = cellWidth * 0.28;

    final glowPaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(playerPos, playerRadius + 4, glowPaint);

    final playerPaint = Paint()..color = accentColor;
    canvas.drawCircle(playerPos, playerRadius, playerPaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(playerPos, playerRadius * 0.4, innerPaint);
  }

  void _drawMarker(Canvas canvas, Offset pos, String text, Color color, double radius) {
    final bgPaint = Paint()..color = color.withOpacity(0.3);
    canvas.drawCircle(pos, radius + 2, bgPaint);

    final circlePaint = Paint()..color = color;
    canvas.drawCircle(pos, radius, circlePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 1.2,
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
  bool shouldRepaint(covariant SquareMazePainter oldDelegate) {
    return oldDelegate.currentCellId != currentCellId ||
        oldDelegate.traveledPath.length != traveledPath.length ||
        oldDelegate.showSolution != showSolution ||
        oldDelegate.solutionAnimationProgress != solutionAnimationProgress ||
        oldDelegate.mazeData != mazeData;
  }
}
