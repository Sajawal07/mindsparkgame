import 'package:flutter/material.dart';

/// Renders an Avatar image (bottom) with a Frame image overlaid on top.
///
/// Usage:
/// ```dart
/// PlayerAvatarView(
///   avatarPath: player.equippedAvatar,
///   framePath: player.equippedFrame,
///   size: 96,
/// )
/// ```
///
/// The frame is expected to be a transparent PNG that acts as a border overlay.
/// Avatar is clipped to a circle when no frame is equipped.
class PlayerAvatarView extends StatelessWidget {
  const PlayerAvatarView({
    super.key,
    required this.avatarPath,
    this.framePath,
    this.size = 80,
    this.fallbackInitial = 'P',
    this.fallbackColor,
  });

  final String avatarPath;
  final String? framePath;
  final double size;

  /// Shown as a letter avatar if the asset fails to load and no frame is set.
  final String fallbackInitial;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── AVATAR (bottom layer) ──────────────────────────────────────
          SizedBox(
            width: size,
            height: size,
            child: ClipOval(
              child: avatarPath.isNotEmpty
                  ? Image.asset(
                      avatarPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _Fallback(
                        initial: fallbackInitial,
                        color: fallbackColor ??
                            Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : _Fallback(
                      initial: fallbackInitial,
                      color: fallbackColor ??
                          Theme.of(context).colorScheme.primary,
                    ),
            ),
          ),

          if (framePath != null && framePath!.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: OverflowBox(
                  maxWidth: size * 1.45,
                  maxHeight: size * 1.45,
                  child: Image.asset(
                    framePath!,
                    width: size * 1.45,
                    height: size * 1.45,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.initial, required this.color});

  final String initial;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        initial.toUpperCase(),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
