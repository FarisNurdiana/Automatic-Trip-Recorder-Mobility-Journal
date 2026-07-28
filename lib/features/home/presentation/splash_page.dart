import 'package:flutter/material.dart';

import '../../../shared/widgets/ruteku_logo.dart';

/// Simple splash shown while the router decides where to go.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RutekuLogo(size: 96),
            const SizedBox(height: 16),
            Text(
              'Ruteku',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
