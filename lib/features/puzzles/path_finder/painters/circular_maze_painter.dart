import 'dart:math';

import 'package:flutter/material.dart';

import '../models/generated_maze.dart';
import '../models/maze_cell.dart';

class CircularMazePainter extends CustomPainter {
  CircularMazePainter({
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
    final cells = mazeData.cells.cast<String, CircularMazeCell>();
    if (cells.isEmpty) return;

    int maxRing = 0;
    int maxSeg = 0;
    for (final cell in cells.values) {
      if (cell.ring > maxRing) maxRing = cell.ring;
      if (cell.segment > maxSeg) maxSeg = cell.segment;
    }
    final totalRings = maxRing + 1;
    final segmentsPerRing = maxSeg + 1;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2 * 0.92;
    final ringRadiusStep = maxRadius / totalRings;

    final wallPaint = Paint()
      ..color = wallColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final angleStep = (2 * pi) / segmentsPerRing;

    // Helper: Angle for segment index
    double segmentAngle(int s) => s * angleStep - (pi / 2);

    // Helper: Cell center in Cartesian coords
    Offset getCellCenter(String id) {
      final c = cells[id];
      if (c == null) return center;
      final r = (c.ring + 0.5) * ringRadiusStep;
      final a = (c.segment + 0.5) * angleStep - (pi / 2);
      return Offset(center.dx + r * cos(a), center.dy + r * sin(a));
    }

    // 1. Draw Walls
    for (final cell in cells.values) {
      final innerR = cell.ring * ringRadiusStep;
      final outerR = (cell.ring + 1) * ringRadiusStep;
      final startA = segmentAngle(cell.segment);
      final endA = segmentAngle(cell.segment + 1);

      // Inner wall arc
      if (cell.inner && cell.ring > 0) {
        final rect = Rect.fromCircle(center: center, radius: innerR);
        canvas.drawArc(rect, startA, angleStep, false, wallPaint);
      }

      // Outer wall arc
      if (cell.outer) {
        final rect = Rect.fromCircle(center: center, radius: outerR);
        canvas.drawArc(rect, startA, angleStep, false, wallPaint);
      }

      // Clockwise radial wall line
      if (cell.clockwise) {
        final p1 = Offset(center.dx + innerR * cos(endA), center.dy + innerR * sin(endA));
        final p2 = Offset(center.dx + outerR * cos(endA), center.dy + outerR * sin(endA));
        canvas.drawLine(p1, p2, wallPaint);
      }

      // Counter-clockwise radial wall line
      if (cell.counterClockwise) {
        final p1 = Offset(center.dx + innerR * cos(startA), center.dy + innerR * sin(startA));
        final p2 = Offset(center.dx + outerR * cos(startA), center.dy + outerR * sin(startA));
        canvas.drawLine(p1, p2, wallPaint);
      }
    }

    // 2. Draw Start "A" and End "B"
    final startOffset = getCellCenter(mazeData.startId);
    final endOffset = getCellCenter(mazeData.endId);
    final markerRadius = ringRadiusStep * 0.35;

    _drawMarker(canvas, startOffset, 'A', const Color(0xFF4CAF50), markerRadius);
    _drawMarker(canvas, endOffset, 'B', const Color(0xFFFF5252), markerRadius);

    // 3. Draw Solution Path
    if (showSolution && mazeData.solutionPath.length > 1) {
      final solutionPaint = Paint()
        ..color = Colors.amber.withOpacity(0.85)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(startOffset.dx, startOffset.dy);
      final visibleCount = (mazeData.solutionPath.length * solutionAnimationProgress).clamp(1, mazeData.solutionPath.length).toInt();
      for (var i = 1; i < visibleCount; i++) {
        final pt = getCellCenter(mazeData.solutionPath[i]);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, solutionPaint);
    }

    // 4. Draw Traveled Trail
    if (traveledPath.length > 1) {
      final trailPaint = Paint()
        ..color = primaryColor.withOpacity(0.4)
        ..strokeWidth = ringRadiusStep * 0.25
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final trailPath = Path();
      final pStart = getCellCenter(traveledPath.first);
      trailPath.moveTo(pStart.dx, pStart.dy);
      for (var i = 1; i < traveledPath.length; i++) {
        final pt = getCellCenter(traveledPath[i]);
        trailPath.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(trailPath, trailPaint);
    }

    // 5. Draw Player Node
    final playerPos = getCellCenter(currentCellId);
    final playerRadius = ringRadiusStep * 0.3;

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
  bool shouldRepaint(covariant CircularMazePainter oldDelegate) {
    return oldDelegate.currentCellId != currentCellId ||
        oldDelegate.traveledPath.length != traveledPath.length ||
        oldDelegate.showSolution != showSolution ||
        oldDelegate.solutionAnimationProgress != solutionAnimationProgress ||
        oldDelegate.mazeData != mazeData;
  }
}
