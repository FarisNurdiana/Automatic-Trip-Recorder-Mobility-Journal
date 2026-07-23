import '../../../core/constants/enums.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Localized label for every recording state — single source for all pages.
String tripStateLabel(AppLocalizations l10n, TripRecordingState state) =>
    switch (state) {
      TripRecordingState.idle => l10n.stateIdle,
      TripRecordingState.possibleTrip => l10n.statePossibleTrip,
      TripRecordingState.recording => l10n.stateRecording,
      TripRecordingState.shortStop => l10n.stateShortStop,
      TripRecordingState.temporarilyStopped => l10n.stateTemporarilyStopped,
      TripRecordingState.restStopCandidate => l10n.stateRestStopCandidate,
      TripRecordingState.destinationCandidate =>
        l10n.stateDestinationCandidate,
      TripRecordingState.finishing => l10n.stateFinishing,
      TripRecordingState.finished => l10n.stateFinished,
      TripRecordingState.cancelled => l10n.stateCancelled,
    };
