import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../data/models/puzzle_type.dart';

/// Tweak these values to nudge island positions manually.
abstract final class GameIslandLayout {
  /// Left islands horizontal inset (fraction of screen width).
  static const double leftMargin = 0.07;

  /// Right islands horizontal inset (fraction of screen width).
  static const double rightMargin = 0.07;

  /// Island image width & height (fraction of screen width).
  static const double islandSizeFactor = 0.35;

  /// Space reserved at the bottom so last islands sit above system / nav bar.
  /// Fraction of available body height — increase if bottom games are still too low.
  static const double bottomPaddingFactor = 0;

  /// Moves every island up (negative) or down (positive).
  /// Value is a fraction of one slot height.
  static const double globalVerticalNudge = 0.2;

  /// Extra up/down nudge per game, top → bottom (index 0–7).
  /// Each value is a fraction of one slot height.
  /// Example: `[0, -0.05, 0, 0.05, ...]` pulls Memory Flip up, Word Snap down.
  static const List<double> slotVerticalNudge = [
    0.2, // 0 Maths Blitz (left)
    0.1, // 1 Memory Flip (right)
    0, // 2 Pattern IQ (left)
    -0.3, // 3 Word Snap (right)
    -0.4, // 4 Focus Find (left)
    -0.6, // 5 Who Am I (right)
    -0.5, // 6 Science Snap (left)
    -0.9, // 7 Word Ladder (right)
  ];
}

/// Full-viewport wrapper so Practice and Daily use the same island coordinates.
class GameSelectionBody extends StatelessWidget {
  const GameSelectionBody({
    super.key,
    required this.itemBuilder,
    this.topOverlay,
  });

  final Widget Function(BuildContext context, int index, double islandSize)
      itemBuilder;
  final Widget? topOverlay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomInset =
            constraints.maxHeight * GameIslandLayout.bottomPaddingFactor;
        final layoutHeight = constraints.maxHeight - bottomInset;
        final width = constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: layoutHeight,
            width: width,
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                GameIslandZigzagLayout(
                  backgroundAsset: AppAssets.gameSelectionBackground,
                  itemBuilder: itemBuilder,
                ),
                if (topOverlay != null)
                  Positioned(
                    top: 0,
                    left: 12,
                    right: 12,
                    child: topOverlay!,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Non-scrollable zigzag layout for eight game islands on a single screen.
class GameIslandZigzagLayout extends StatelessWidget {
  const GameIslandZigzagLayout({
    super.key,
    required this.backgroundAsset,
    required this.itemBuilder,
    this.itemCount = 8,
  });

  final String backgroundAsset;
  final int itemCount;
  final Widget Function(BuildContext context, int index, double islandSize)
      itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final slotHeight = height / itemCount;
        final islandSize = width * GameIslandLayout.islandSizeFactor;

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              backgroundAsset,
              fit: BoxFit.cover,
              width: width,
              height: height,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            for (var index = 0; index < itemCount; index++)
              Positioned(
                top: slotHeight * index +
                    slotHeight * GameIslandLayout.globalVerticalNudge +
                    slotHeight *
                        (index < GameIslandLayout.slotVerticalNudge.length
                            ? GameIslandLayout.slotVerticalNudge[index]
                            : 0),
                left: index.isEven ? width * GameIslandLayout.leftMargin : null,
                right: index.isOdd ? width * GameIslandLayout.rightMargin : null,
                child: itemBuilder(context, index, islandSize),
              ),
          ],
        );
      },
    );
  }
}

/// Island image centered in a zigzag slot (labels are baked into the PNG assets).
class GameIslandSlot extends StatelessWidget {
  const GameIslandSlot({
    super.key,
    required this.type,
    required this.islandSize,
    this.onTap,
  });

  final PuzzleType type;
  final double islandSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        type.islandAsset,
        width: islandSize,
        height: islandSize,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset(
          type.iconAsset,
          width: islandSize,
          height: islandSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
