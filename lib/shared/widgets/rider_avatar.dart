import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';

/// Chibi rider marker for the trip playback animation, rendered from the
/// user-provided character art (assets/branding/rider_*.png): a chibi
/// driver on a mini-moto, one sprite per selectable style —
/// normal (green helmet), cute (pink, bow), fierce (black helmet, devil
/// horns). The sprite gently bobs and rocks while riding and always faces
/// the direction of travel.
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

  /// Travel direction (0 = north, clockwise); the rider is flipped so it
  /// never drives backwards.
  final double bearingRadians;

  final bool animate;

  static String assetFor(RiderStyle style) =>
      'assets/branding/rider_${style.name}.png';

  @override
  State<RiderAvatar> createState() => _RiderAvatarState();
}

class _RiderAvatarState extends State<RiderAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _t.repeat();
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The art faces east; flip when heading west.
    final headingWest = math.sin(widget.bearingRadians) < 0;
    final sprite = Image.asset(
      RiderAvatar.assetFor(widget.style),
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) =>
          Icon(Icons.two_wheeler, size: widget.size * 0.7),
    );
    if (!widget.animate) {
      return Transform.flip(flipX: headingWest, child: sprite);
    }
    return Transform.flip(
      flipX: headingWest,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, child) {
          final phase = _t.value * 2 * math.pi;
          // Suspension bob + a subtle rocking lean, like riding over asphalt.
          return Transform.translate(
            offset: Offset(0, math.sin(phase) * widget.size * 0.03),
            child: Transform.rotate(
              angle: math.sin(phase + math.pi / 3) * 0.045,
              child: child,
            ),
          );
        },
        child: sprite,
      ),
    );
  }
}
