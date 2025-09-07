/// Custom exception for speed test related errors
class SpeedTestException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const SpeedTestException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() =>
      'SpeedTestException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Specific exceptions for different error cases
class WebSocketConnectionException extends SpeedTestException {
  const WebSocketConnectionException({
    required super.message,
    String? code,
    super.originalError,
  }) : super(code: code ?? 'WEBSOCKET_CONNECTION_ERROR');
}

class SpeedTestTimeoutException extends SpeedTestException {
  const SpeedTestTimeoutException({
    super.message = 'Speed test timed out',
    String? code,
    super.originalError,
  }) : super(code: code ?? 'SPEED_TEST_TIMEOUT');
}

class InvalidSpeedTestDataException extends SpeedTestException {
  const InvalidSpeedTestDataException({
    required super.message,
    String? code,
    super.originalError,
  }) : super(code: code ?? 'INVALID_SPEED_TEST_DATA');
}
