/// Configuration for WebSocket connections
class WebSocketConfig {
  /// Maximum number of reconnection attempts
  static const int maxReconnectAttempts = 3;

  /// Delay between reconnection attempts (in milliseconds)
  static const int reconnectDelay = 2000;

  /// Timeout for connection attempts (in milliseconds)
  static const int connectionTimeout = 5000;

  /// Timeout for speed test operations (in milliseconds)
  static const int speedTestTimeout = 30000;

  /// Ping interval to keep connection alive (in milliseconds)
  static const int pingInterval = 10000;
}
