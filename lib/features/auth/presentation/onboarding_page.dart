import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/brand_logo.dart';

/// Staged permission onboarding: every permission is explained before it is
/// requested, one at a time — never all at once.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _PermissionStep {
  const _PermissionStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.request,
  });

  final IconData icon;
  final String title;
  final String description;
  final Future<bool> Function() request;
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsControllerProvider.notifier).completeOnboarding();
    if (mounted) context.go('/login');
  }

  void _next(int total) {
    if (_index >= total - 1) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final permissions = ref.read(permissionsServiceProvider);

    final steps = <Widget>[
      _IntroStep(
        title: l10n.onboardingWelcomeTitle,
        description: l10n.onboardingWelcomeDesc,
      ),
      _IntroStep(
        icon: Icons.verified_user_outlined,
        title: l10n.onboardingPermissionsTitle,
        description: l10n.onboardingPermissionsDesc,
      ),
      for (final step in [
        _PermissionStep(
          icon: Icons.directions_walk,
          title: l10n.permActivityRecognition,
          description: l10n.permActivityRecognitionDesc,
          request: permissions.requestActivityRecognition,
        ),
        _PermissionStep(
          icon: Icons.location_on_outlined,
          title: l10n.permLocation,
          description: l10n.permLocationDesc,
          request: permissions.requestLocation,
        ),
        _PermissionStep(
          icon: Icons.my_location,
          title: l10n.permBackgroundLocation,
          description: l10n.permBackgroundLocationDesc,
          request: permissions.requestBackgroundLocation,
        ),
        _PermissionStep(
          icon: Icons.notifications_outlined,
          title: l10n.permNotifications,
          description: l10n.permNotificationsDesc,
          request: permissions.requestNotifications,
        ),
      ])
        _PermissionStepView(step: step),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _index = i),
                children: steps,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  TextButton(onPressed: _finish, child: Text(l10n.commonSkip)),
                  const Spacer(),
                  Row(
                    children: [
                      for (var i = 0; i < steps.length; i++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => _next(steps.length),
                    child: Text(
                      _index >= steps.length - 1
                          ? l10n.onboardingStart
                          : l10n.commonNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({this.icon, required this.title, required this.description});

  /// Material icon for the step; null shows the Motivox logo instead.
  final IconData? icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon == null)
            const BrandLogo(size: 96)
          else
            Icon(icon, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _PermissionStepView extends StatefulWidget {
  const _PermissionStepView({required this.step});

  final _PermissionStep step;

  @override
  State<_PermissionStepView> createState() => _PermissionStepViewState();
}

class _PermissionStepViewState extends State<_PermissionStepView> {
  bool? _granted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.step.icon, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            widget.step.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            widget.step.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (_granted == true)
            Chip(
              avatar: const Icon(Icons.check, size: 18),
              label: Text(l10n.permGranted),
            )
          else
            FilledButton.tonal(
              onPressed: () async {
                final ok = await widget.step.request();
                if (mounted) setState(() => _granted = ok);
              },
              child: Text(l10n.permRequest),
            ),
        ],
      ),
    );
  }
}
