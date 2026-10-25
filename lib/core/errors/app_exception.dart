class AppException implements Exception {
  const AppException({
    required this.message,
    this.code = 'unknown',
    this.originalError,
  });

  final String message;
  final String code;
  final Object? originalError;

  @override
  String toString() => message;

  factory AppException.fromFirebase(Object error) {
    final str = error.toString().toLowerCase();
    if (str.contains('user-not-found')) {
      return const AppException(
        code: 'user-not-found',
        message: 'No account found with this email address.',
      );
    }
    if (str.contains('wrong-password') || str.contains('invalid-credential')) {
      return const AppException(
        code: 'invalid-credentials',
        message: 'Invalid email or password. Please try again.',
      );
    }
    if (str.contains('email-already-in-use')) {
      return const AppException(
        code: 'email-already-in-use',
        message: 'An account already exists with this email address.',
      );
    }
    if (str.contains('network-request-failed')) {
      return const AppException(
        code: 'network-error',
        message: 'Network error. Please check your internet connection.',
      );
    }
    if (str.contains('permission-denied')) {
      return const AppException(
        code: 'permission-denied',
        message: 'You do not have permission to perform this action.',
      );
    }
    if (str.contains('no-app') ||
        str.contains('not initialized') ||
        str.contains('no firebase app')) {
      return const AppException(
        code: 'firebase-not-initialized',
        message: 'Firebase service is initializing. Please try again in a moment.',
      );
    }
    return AppException(
      code: 'firebase-error',
      message: error.toString(),
      originalError: error,
    );
  }
}
