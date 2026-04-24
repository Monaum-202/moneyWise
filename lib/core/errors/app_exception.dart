class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message ${code != null ? "($code)" : ""}';
}

class DatabaseException extends AppException {
  DatabaseException(super.message, [super.code]);
}
