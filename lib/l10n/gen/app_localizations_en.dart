// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ruteku';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonEmpty => 'No data yet';

  @override
  String get commonOffline => 'No internet connection';

  @override
  String get commonOfflineBanner =>
      'Offline — data is stored locally and will sync later';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonNext => 'Next';

  @override
  String get commonDone => 'Done';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authRegisterTitle => 'Sign up';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authDisplayName => 'Display name';

  @override
  String get authLoginButton => 'Sign in';

  @override
  String get authRegisterButton => 'Sign up';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authResetPasswordButton => 'Send reset link';

  @override
  String get authResetPasswordSent =>
      'A reset link has been sent to your email.';

  @override
  String get authNoAccount => 'No account yet? Sign up';

  @override
  String get authHaveAccount => 'Already have an account? Sign in';

  @override
  String get authLogout => 'Sign out';

  @override
  String get authLocalMode => 'Continue without an account (local mode)';

  @override
  String get authLocalModeInfo =>
      'Trips are stored on this device only and are not synced.';

  @override
  String get authEmailInvalid => 'Invalid email format';

  @override
  String get authPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get authRegisterSuccess =>
      'Registration successful. Check your email for confirmation.';

  @override
  String get authLogoutUnsyncedWarning =>
      'There is still unsynced data. If you sign out now, that data stays on the device but will not be uploaded until you sign in again.';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeDetectionStatus => 'Detection status';

  @override
  String get homeStartTrip => 'Start trip';

  @override
  String get homeLastTrip => 'Last trip';

  @override
  String get homeTotalDistance => 'Total distance';

  @override
  String get homeTripCount => 'Trips';

  @override
  String get homePermissions => 'Permissions';

  @override
  String get homeSyncStatus => 'Sync';

  @override
  String get homeNoTrips => 'No trips recorded yet';

  @override
  String get homePermissionsIncomplete => 'Some permissions are missing';

  @override
  String get homePermissionsComplete => 'All permissions granted';

  @override
  String get stateIdle => 'Watching for activity';

  @override
  String get statePossibleTrip => 'Possible trip detected';

  @override
  String get stateRecording => 'Trip is being recorded';

  @override
  String get stateTemporarilyStopped => 'Temporarily stopped';

  @override
  String get stateFinishing => 'Finishing trip';

  @override
  String get stateFinished => 'Trip saved';

  @override
  String get stateCancelled => 'Trip cancelled';

  @override
  String get syncPending => 'Waiting to sync';

  @override
  String get syncSyncing => 'Syncing...';

  @override
  String get syncSynced => 'Synced';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncLocalOnly => 'Local mode — sync disabled';

  @override
  String get tripCurrentTitle => 'Current trip';

  @override
  String get tripPause => 'Pause';

  @override
  String get tripResume => 'Resume';

  @override
  String get tripFinish => 'Finish';

  @override
  String get tripCancel => 'Cancel trip';

  @override
  String get tripCancelConfirm => 'Cancel this trip? Its data will be deleted.';

  @override
  String get tripDistance => 'Distance';

  @override
  String get tripDuration => 'Duration';

  @override
  String get tripSpeed => 'Speed';

  @override
  String get tripMaxSpeed => 'Max speed';

  @override
  String get tripAvgSpeed => 'Average speed';

  @override
  String get tripMovingAvgSpeed => 'Moving average';

  @override
  String get tripMovingTime => 'Moving time';

  @override
  String get tripStoppedTime => 'Stopped time';

  @override
  String get tripDeparture => 'Departure';

  @override
  String get tripArrival => 'Arrival';

  @override
  String get tripStops => 'Stops';

  @override
  String get tripStopCount => 'Stop count';

  @override
  String get tripNoPoints => 'Trip does not have enough GPS points';

  @override
  String get tripTooShort => 'Trip is too short to be saved';

  @override
  String get tripPoints => 'GPS points';

  @override
  String get tripSpeedChart => 'Speed chart';

  @override
  String get tripFitRoute => 'Fit whole route';

  @override
  String get tripStart => 'Start';

  @override
  String get tripEnd => 'End';

  @override
  String get tripExportGpx => 'Export GPX';

  @override
  String get tripExportGpxDesc =>
      'Share the route as a GPX file (importable into Strava, Google Earth, etc.)';

  @override
  String get tripExportFailed =>
      'Export failed. This trip has no route points.';

  @override
  String get historyTitle => 'Trip history';

  @override
  String get historyEmpty =>
      'No trips yet. Start your first trip from the home screen.';

  @override
  String get vehicleConfirmTitle => 'Confirm vehicle';

  @override
  String get vehicleConfirmMessage => 'We detected a trip using a vehicle.';

  @override
  String get vehicleConfirmQuestion => 'Vehicle type:';

  @override
  String vehiclePrediction(String vehicle) {
    return 'Prediction: $vehicle';
  }

  @override
  String vehicleConfidence(String percent) {
    return 'Confidence: $percent%';
  }

  @override
  String get vehicleCar => 'Car';

  @override
  String get vehicleMotorcycle => 'Motorcycle';

  @override
  String get vehicleBus => 'Bus';

  @override
  String get vehicleTruck => 'Truck';

  @override
  String get vehicleTrain => 'Train';

  @override
  String get vehicleOther => 'Other';

  @override
  String get vehicleUnknown => 'Unknown';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAutoDetection => 'Automatic trip detection';

  @override
  String get settingsAutoDetectionDesc =>
      'Start and end recording automatically based on vehicle activity.';

  @override
  String get settingsSensorLogging => 'Sensor data logging';

  @override
  String get settingsSensorLoggingDesc =>
      'Records accelerometer and gyroscope during trips for future vehicle classification models.';

  @override
  String get settingsSensorLoggingWarning =>
      'Sensor logging increases battery usage.';

  @override
  String get settingsMountPosition => 'Phone position';

  @override
  String get settingsMountPositionDesc =>
      'Phone position affects sensor data characteristics.';

  @override
  String get mountDashboard => 'Dashboard holder';

  @override
  String get mountHandlebar => 'Motorcycle handlebar holder';

  @override
  String get mountPocket => 'Pocket';

  @override
  String get mountBag => 'Bag';

  @override
  String get mountCupHolder => 'Cup holder';

  @override
  String get mountUnknown => 'Unknown';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsPermissions => 'Permission diagnostics';

  @override
  String get settingsPrivacy => 'Privacy & security';

  @override
  String get privacyTitle => 'Privacy & security';

  @override
  String get privacyDeleteAllLocal => 'Delete all local data';

  @override
  String get privacyDeleteAllLocalConfirm =>
      'All trips and sensor data on this device will be permanently deleted. Continue?';

  @override
  String get privacyDeleteAllCloud => 'Delete all my cloud data';

  @override
  String get privacyDeleteAllCloudConfirm =>
      'All of your trips on the server will be permanently deleted. Continue?';

  @override
  String get privacyDeleteTrip => 'Delete trip';

  @override
  String get privacyDeleteTripConfirm => 'Permanently delete this trip?';

  @override
  String get privacyDataDeleted => 'Data deleted';

  @override
  String get permLocation => 'Location';

  @override
  String get permLocationDesc => 'Used to record your trip route.';

  @override
  String get permBackgroundLocation => 'Background location';

  @override
  String get permBackgroundLocationDesc =>
      'Used so trips keep recording when the screen is off or the app is minimized.';

  @override
  String get permActivityRecognition => 'Activity recognition';

  @override
  String get permActivityRecognitionDesc =>
      'Used to detect when a vehicle trip starts or ends.';

  @override
  String get permMotionFitness => 'Motion & fitness';

  @override
  String get permMotionFitnessDesc =>
      'Used to recognize activities such as walking, standing still, or riding a vehicle.';

  @override
  String get permNotifications => 'Notifications';

  @override
  String get permNotificationsDesc =>
      'Used to show that a trip is being recorded.';

  @override
  String get permBatteryOptimization => 'Battery optimization exemption';

  @override
  String get permBatteryOptimizationDesc =>
      'Prevents the system from killing background recording.';

  @override
  String get permGranted => 'Granted';

  @override
  String get permDenied => 'Denied';

  @override
  String get permActive => 'Active';

  @override
  String get permInactive => 'Inactive';

  @override
  String get permRequest => 'Request permission';

  @override
  String get permOpenSettings => 'Open settings';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Ruteku';

  @override
  String get onboardingWelcomeDesc =>
      'Record your trips automatically. Ruteku detects when you are in a vehicle, records the route, and creates a trip summary.';

  @override
  String get onboardingPermissionsTitle => 'Required permissions';

  @override
  String get onboardingPermissionsDesc =>
      'For automatic recording to work, Ruteku needs a few permissions. Each one is explained before it is requested.';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get errorPermissionDenied =>
      'Permission denied. Some features will not work.';

  @override
  String get errorGpsDisabled =>
      'GPS is off. Enable location services to record trips.';

  @override
  String get errorActivityUnavailable =>
      'Activity recognition is unavailable on this device. Use manual recording.';

  @override
  String get errorSupabaseUnavailable =>
      'Server is unreachable. Data is kept locally.';

  @override
  String get errorDatabase => 'A local storage error occurred.';

  @override
  String get errorSensorUnavailable =>
      'Sensors are unavailable on this device.';

  @override
  String get errorTripTooFewPoints =>
      'Trip was not saved because it has too few GPS points.';

  @override
  String get errorEnvMissing => 'Supabase configuration is missing';

  @override
  String get errorEnvMissingDesc =>
      'Copy .env.example to .env and fill SUPABASE_URL and SUPABASE_ANON_KEY. You can still use local mode without an account.';

  @override
  String get unitKm => 'km';

  @override
  String get unitKmh => 'km/h';

  @override
  String get unitHour => 'h';

  @override
  String get unitMinute => 'min';

  @override
  String get recoveredTripTitle => 'Trip recovered';

  @override
  String get recoveredTripMessage =>
      'An in-progress trip was found and resumed after the app was closed.';

  @override
  String get stateShortStop => 'Brief stop';

  @override
  String get stateRestStopCandidate => 'Stopped for a while';

  @override
  String get stateDestinationCandidate => 'Possibly arrived';

  @override
  String get stopQuestion30Title => 'You have been stopped for 30 minutes';

  @override
  String get stopQuestion30Body =>
      'Have you arrived at your destination, or are you resting?';

  @override
  String get stopQuestion5hTitle => 'The trip has probably finished';

  @override
  String get stopQuestion5hBody =>
      'You have been at the same location for more than 5 hours.';

  @override
  String get answerArrived => 'Arrived';

  @override
  String get answerResting => 'Resting';

  @override
  String get answerContinue => 'Continue trip';

  @override
  String get finishTripAction => 'Finish trip';

  @override
  String get keepTripAction => 'Keep going';

  @override
  String get finishedAutomaticallyBadge => 'Finished automatically';

  @override
  String get editArrivalTime => 'Correct arrival time';

  @override
  String get arrivalUpdated => 'Arrival time updated';

  @override
  String get mapPageTitle => 'Trip map';

  @override
  String get mapRecenter => 'Back to route';

  @override
  String get mapZoomIn => 'Zoom in';

  @override
  String get mapZoomOut => 'Zoom out';

  @override
  String get mapOpenFullscreen => 'Open full-screen map';

  @override
  String get gpsQuality => 'GPS quality';

  @override
  String get gpsGood => 'Good';

  @override
  String get gpsFair => 'Fair';

  @override
  String get gpsPoor => 'Poor';

  @override
  String stopSheetTitle(int number) {
    return 'Stop $number';
  }

  @override
  String get stopArrivalTime => 'Arrival time';

  @override
  String get stopDepartureTime => 'Departure time';

  @override
  String get stopDurationLabel => 'Duration';

  @override
  String get stopLocationLabel => 'Location';

  @override
  String get stopTypeLabel => 'Stop type';

  @override
  String get stopUnconfirmed => 'Not confirmed yet';

  @override
  String get stopTypeRest => 'Rest';

  @override
  String get stopTypeParking => 'Parking';

  @override
  String get stopTypeFood => 'Buying food';

  @override
  String get stopTypeFuel => 'Refueling';

  @override
  String get stopTypeVisit => 'Visiting a place';

  @override
  String get stopTypeTraffic => 'Traffic jam';

  @override
  String get stopTypeDestination => 'Destination';

  @override
  String get stopTypeOther => 'Other';

  @override
  String get stopLabelSaved => 'Stop label saved';

  @override
  String get vehicleBicycle => 'Bicycle';

  @override
  String vehicleQuestionHigh(String vehicle) {
    return 'Were you riding a $vehicle just now?';
  }

  @override
  String get vehiclePredictionInfo =>
      'Ruteku\'s prediction based on the trip pattern.';

  @override
  String vehicleConfidenceLabel(String percent) {
    return 'Confidence: $percent%';
  }

  @override
  String vehicleYes(String vehicle) {
    return 'Yes, $vehicle';
  }

  @override
  String get vehicleNo => 'No';

  @override
  String vehicleQuestionMedium(String vehicle) {
    return 'You probably used a $vehicle';
  }

  @override
  String get vehicleQuestionMediumAsk => 'Is this prediction correct?';

  @override
  String get vehicleCorrect => 'Correct';

  @override
  String get vehicleChange => 'Change vehicle';

  @override
  String get vehicleQuestionLow => 'Which vehicle did you use?';

  @override
  String get shareTripTitle => 'Share trip';

  @override
  String get sharePng => 'PNG image';

  @override
  String get shareGpx => 'GPX file';

  @override
  String get shareGeoJson => 'GeoJSON file';

  @override
  String get shareCopySummary => 'Copy summary';

  @override
  String get shareCopied => 'Summary copied to clipboard';

  @override
  String get sharePreparing => 'Preparing trip image...';

  @override
  String get sharePrivacyTitle => 'Privacy options';

  @override
  String get shareShowStart => 'Show start location';

  @override
  String get shareShowEnd => 'Show end location';

  @override
  String get shareShowUserName => 'Show user name';

  @override
  String get shareShowMaxSpeed => 'Show maximum speed';

  @override
  String get sharePrivacyMode => 'Privacy mode';

  @override
  String get sharePrivacyModeDesc =>
      'Trims ~300 m from the start and end of the route so home locations stay hidden.';

  @override
  String get shareContinue => 'Continue';
}
