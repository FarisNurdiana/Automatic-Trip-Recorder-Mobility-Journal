import 'package:flutter/material.dart';

/// The MOTIVOX wordmark in the brand display font (Racing Sans One), used
/// on exports and headers. [light] renders white-with-shadow for photo
/// overlays; otherwise the current color scheme decides.
class MotivoxWordmark extends StatelessWidget {
  const MotivoxWordmark({
    super.key,
    this.size = 20,
    this.light = false,
    this.color,
  });

  final double size;
  final bool light;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'MOTIVOX',
      style: TextStyle(
        fontFamily: 'RacingSansOne',
        fontSize: size,
        letterSpacing: size * 0.09,
        height: 1,
        color:
            color ??
            (light ? Colors.white : Theme.of(context).colorScheme.onSurface),
        shadows: light
            ? const [
                Shadow(color: Colors.black54, blurRadius: 6),
                Shadow(color: Colors.black38, blurRadius: 16),
              ]
            : null,
      ),
    );
  }
}
