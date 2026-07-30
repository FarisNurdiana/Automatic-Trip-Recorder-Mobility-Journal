import 'package:flutter/material.dart';

/// The Motivox brand mark (angular M with a road sweep) rendered from
/// the bundled asset, so every screen shows the real logo instead of a
/// generic Material icon.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/motivox_logo.png',
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
