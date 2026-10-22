import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/generated_maze.dart';
import '../models/maze_type.dart';

class DirectionControls extends StatelessWidget {
  const DirectionControls({
    super.key,
    required this.type,
    required this.mazeData,
    required this.currentCellId,
    required this.onMove,
  });

  final MazeType type;
  final MazeGraphData mazeData;
  final String currentCellId;
  final void Function(String direction) onMove;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      MazeType.square => _buildSquareControls(context),
      MazeType.circular => _buildCircularControls(context),
      MazeType.triangle => _buildTriangleControls(context),
    };
  }

  Widget _buildSquareControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ControlButton(
            icon: Icons.keyboard_arrow_up,
            label: 'UP',
            onPressed: () => _handleMove('up'),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.keyboard_arrow_left,
                label: 'LEFT',
                onPressed: () => _handleMove('left'),
              ),
              const SizedBox(width: 40),
              _ControlButton(
                icon: Icons.keyboard_arrow_right,
                label: 'RIGHT',
                onPressed: () => _handleMove('right'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _ControlButton(
            icon: Icons.keyboard_arrow_down,
            label: 'DOWN',
            onPressed: () => _handleMove('down'),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularControls(BuildContext context) {
    final validDirs = mazeData.getValidDirections(currentCellId);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _CircularButton(
            icon: Icons.south,
            label: 'IN',
            enabled: validDirs.contains('in'),
            onPressed: () => _handleMove('in'),
          ),
          _CircularButton(
            icon: Icons.north,
            label: 'OUT',
            enabled: validDirs.contains('out'),
            onPressed: () => _handleMove('out'),
          ),
          _CircularButton(
            icon: Icons.rotate_right,
            label: 'CW ↻',
            enabled: validDirs.contains('cw'),
            onPressed: () => _handleMove('cw'),
          ),
          _CircularButton(
            icon: Icons.rotate_left,
            label: 'CCW ↺',
            enabled: validDirs.contains('ccw'),
            onPressed: () => _handleMove('ccw'),
          ),
        ],
      ),
    );
  }

  Widget _buildTriangleControls(BuildContext context) {
    final validDirs = mazeData.getValidDirections(currentCellId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TriangleContextButton(
            label: 'LEFT',
            icon: Icons.arrow_back,
            isOpen: validDirs.contains('left'),
            onPressed: () => _handleMove('left'),
          ),
          _TriangleContextButton(
            label: 'BASE',
            icon: Icons.swap_vert,
            isOpen: validDirs.contains('base'),
            onPressed: () => _handleMove('base'),
          ),
          _TriangleContextButton(
            label: 'RIGHT',
            icon: Icons.arrow_forward,
            isOpen: validDirs.contains('right'),
            onPressed: () => _handleMove('right'),
          ),
        ],
      ),
    );
  }

  void _handleMove(String dir) {
    HapticFeedback.selectionClick();
    onMove(dir);
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 58,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _CircularButton extends StatelessWidget {
  const _CircularButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? const Color(0xFF6C5CE7) : Colors.white10,
        foregroundColor: enabled ? Colors.white : Colors.white38,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _TriangleContextButton extends StatelessWidget {
  const _TriangleContextButton({
    required this.label,
    required this.icon,
    required this.isOpen,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isOpen ? const Color(0xFF00CEC9) : Colors.white10,
        foregroundColor: isOpen ? Colors.black87 : Colors.white30,
        elevation: isOpen ? 4 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: isOpen ? onPressed : null,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
