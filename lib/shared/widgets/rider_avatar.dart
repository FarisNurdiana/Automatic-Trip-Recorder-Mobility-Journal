import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';

/// Emoji pair making up one chibi rider: the vehicle body and the face
/// peeking above it.
({String face, String vehicle}) riderEmoji(RiderStyle style) => switch (style) {
  RiderStyle.normal => (face: '😎', vehicle: '🛵'),
  RiderStyle.cute => (face: '🐥', vehicle: '🛵'),
  RiderStyle.fierce => (face: '😈', vehicle: '🏍️'),
};

/// Chibi rider marker for the trip playback animation: a big-headed driver
/// on a scooter/motorbike that bobs while riding, leaves exhaust puffs
/// behind, and faces the direction of travel. Style is user-selectable
/// (normal / cute / fierce).
class RiderAvatar extends StatefulWidget {
  const RiderAvatar({
    super.key,
    required this.style,
    this.size = 56,
    this.bearingRadians = 0,
    this.animate = true,
  });

  final RiderStyle style;
  final double size;

  /// Travel direction (0 = north, clockwise); used to flip the rider so it
  /// always faces where it's going, plus a slight forward lean.
  final double bearingRadians;

  final bool animate;

  @override
  State<RiderAvatar> createState() => _RiderAvatarState();
}

class _RiderAvatarState extends State<RiderAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _bob.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emoji = riderEmoji(widget.style);
    final size = widget.size;
    // Emoji face east by default; flip when traveling west so the rider
    // never drives backwards.
    final headingWest = math.sin(widget.bearingRadians) < 0;

    return AnimatedBuilder(
      animation: _bob,
      builder: (context, child) {
        final bob = widget.animate ? (_bob.value - 0.5) * 3.0 : 0.0;
        return Transform.translate(offset: Offset(0, bob), child: child);
      },
      child: Transform.flip(
        flipX: headingWest,
        child: Transform.rotate(
          angle: 0.06,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Exhaust puffs trailing behind the vehicle.
                if (widget.animate)
                  Positioned(
                    left: -size * 0.16,
                    bottom: size * 0.12,
                    child: _ExhaustPuffs(controller: _bob, size: size * 0.13),
                  ),
                // Soft halo keeps the emoji readable over any map tile.
                Container(
                  width: size * 0.92,
                  height: size * 0.92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.85),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 8),
                    ],
                  ),
                ),
                // Vehicle body.
                Positioned(
                  bottom: size * 0.08,
                  child: Text(
                    emoji.vehicle,
                    style: TextStyle(fontSize: size * 0.5, height: 1),
                  ),
                ),
                // Chibi head peeking above the handlebar.
                Positioned(
                  top: size * 0.02,
                  left: size * 0.16,
                  child: Text(
                    emoji.face,
                    style: TextStyle(fontSize: size * 0.34, height: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three fading smoke circles behind the exhaust, phased off the bob
/// animation so everything runs from one controller.
class _ExhaustPuffs extends StatelessWidget {
  const _ExhaustPuffs({required this.controller, required this.size});

  final Animation<double> controller;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.only(right: size * 0.25),
                child: Container(
                  width: size * (1 - i * 0.22),
                  height: size * (1 - i * 0.22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade400.withValues(
                      alpha: (0.7 - i * 0.2) * (1 - (t + i * 0.3) % 1.0),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
