/// Custom exceptions cho database operations

/// Exception cho authentication errors
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, [this.code]);

  @override
  String toString() => 'AuthException: $message';
}

/// Exception cho Firestore errors
class FirestoreException implements Exception {
  final String message;
  final String? code;

  const FirestoreException(this.message, [this.code]);

  @override
  String toString() => 'FirestoreException: $message';
}

/// Exception cho network errors
class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
