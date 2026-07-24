import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../../recording/presentation/state_labels.dart';

/// Read-only view of the state machine's diagnostics ring buffer so users
/// (and bug reports) can see *why* a trip did or did not start — previously
/// these decisions were invisible outside of adb logcat.
class DetectionLogPage extends ConsumerStatefulWidget {
  const DetectionLogPage({super.key});

  @override
  ConsumerState<DetectionLogPage> createState() => _DetectionLogPageState();
}

class _DetectionLogPageState extends ConsumerState<DetectionLogPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final machine = ref.watch(tripStateMachineProvider);
    final recording = ref.watch(tripRecordingControllerProvider);
    // Newest entries first.
    final entries = machine.diagnostics.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.detectionLogTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all_outlined),
            tooltip: l10n.shareCopySummary,
            onPressed: entries.isEmpty
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: entries.join('\n')));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.shareCopied)));
                  },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.radar, color: scheme.primary),
                title: Text(tripStateLabel(l10n, recording.machineState)),
                subtitle: Text(l10n.detectionLogDesc),
              ),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? EmptyStateView(
                    message: l10n.detectionLogEmpty,
                    icon: Icons.receipt_long_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) => DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          entries[index],
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
