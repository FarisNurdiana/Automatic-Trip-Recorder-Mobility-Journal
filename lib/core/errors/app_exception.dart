/// Typed application errors. UI layers map these to localized messages;
/// the technical detail goes to the local log for debugging.
sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  /// Technical (English) message for logs.
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message${cause == null ? '' : ' ($cause)'}';
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message, [super.cause]);
}

class LocationUnavailableException extends AppException {
  const LocationUnavailableException(super.message, [super.cause]);
}

class ActivityRecognitionUnavailableException extends AppException {
  const ActivityRecognitionUnavailableException(super.message, [super.cause]);
}

class SensorUnavailableException extends AppException {
  const SensorUnavailableException(super.message, [super.cause]);
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.cause]);
}

class SyncException extends AppException {
  const SyncException(super.message, [super.cause]);
}

class AuthException extends AppException {
  const AuthException(super.message, [super.cause]);
}

class InvalidTripException extends AppException {
  const InvalidTripException(super.message, [super.cause]);
}
