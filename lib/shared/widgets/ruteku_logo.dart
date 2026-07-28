import 'package:flutter/material.dart';

/// The Ruteku brand mark (road-shaped "R" with a location pin) rendered from
/// the bundled asset, so every screen shows the real logo instead of a
/// generic Material icon.
class RutekuLogo extends StatelessWidget {
  const RutekuLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/ruteku_logo.png',
      height: size,
      fit: BoxFit.contain,
      // If the asset ever fails to load, degrade to the old brand icon
      // rather than crashing the layout.
      errorBuilder: (context, _, _) => Icon(
        Icons.route,
        size: size,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
