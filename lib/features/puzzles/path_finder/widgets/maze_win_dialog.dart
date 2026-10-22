import 'package:flutter/material.dart';

class MazeWinDialog extends StatelessWidget {
  const MazeWinDialog({
    super.key,
    required this.elapsedSeconds,
    required this.moveCount,
    required this.optimalMoves,
    required this.stars,
    required this.onRetry,
    required this.onContinue,
  });

  final int elapsedSeconds;
  final int moveCount;
  final int optimalMoves;
  final int stars;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 MAZE ESCAPED!',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Icon(
                  index < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFFFFD700),
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _StatRow(
                    label: 'Time Taken',
                    value: '${elapsedSeconds}s',
                    icon: Icons.timer,
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  _StatRow(
                    label: 'Moves',
                    value: '$moveCount',
                    icon: Icons.directions_walk,
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  _StatRow(
                    label: 'Optimal Path',
                    value: '$optimalMoves steps',
                    icon: Icons.route,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Replay'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: onContinue,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
