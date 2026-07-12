class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({this.message = 'Server error', this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error'});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Network error'});
}

class AuthException implements Exception {
  final String message;
  const AuthException({this.message = 'Authentication error'});
}

class ValidationException implements Exception {
  final String message;
  const ValidationException({this.message = 'Validation error'});
}
