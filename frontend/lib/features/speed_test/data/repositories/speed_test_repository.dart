import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/config/websocket_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/exceptions/speed_test_exception.dart';
import '../../domain/models/speed_test_result.dart';

/// Repository responsible for managing speed test operations through WebSocket
typedef WebSocketFactory = WebSocketChannel Function(Uri uri);

class SpeedTestRepository {
  final WebSocketFactory _createWebSocket;
  WebSocketChannel? _channel;
  StreamController<SpeedTestResult>? _controller;
  Timer? _pingTimer;
  Timer? _connectionTimeout;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;

  SpeedTestRepository({WebSocketFactory? createWebSocket})
    : _createWebSocket = createWebSocket ?? WebSocketChannel.connect;

  /// Initializes WebSocket connection with proper error handling and reconnection logic
  Future<void> _initializeWebSocket() async {
    if (_isDisposed) return;

    _channel?.sink.close();
    await _controller?.close();
    _pingTimer?.cancel();
    _connectionTimeout?.cancel();

    try {
      _controller = StreamController<SpeedTestResult>.broadcast();

      // Set connection timeout
      _connectionTimeout = Timer(
        Duration(milliseconds: WebSocketConfig.connectionTimeout),
        () {
          if (_channel == null || _controller == null) {
            _handleError(
              const WebSocketConnectionException(
                message: 'Connection attempt timed out',
              ),
            );
          }
        },
      );

      _channel = _createWebSocket(
        Uri.parse('${ApiConstants.wsUrl}/${ApiConstants.speedTest}'),
      );

      // Start ping timer to keep connection alive
      _startPingTimer();

      await _channel!.ready;
      _connectionTimeout?.cancel();
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
        cancelOnError: false,
      );
    } catch (error) {
      _handleError(
        WebSocketConnectionException(
          message: 'Failed to establish WebSocket connection',
          originalError: error,
        ),
      );
    }
  }

  /// Handles incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      if (message is! String) {
        throw const InvalidSpeedTestDataException(
          message: 'Invalid message format: expected String',
        );
      }

      final data = jsonDecode(message);
      if (data is! Map<String, dynamic>) {
        throw const InvalidSpeedTestDataException(
          message: 'Invalid JSON format: expected object',
        );
      }

      final result = SpeedTestResult(
        ping: (data['ping'] as num?)?.toDouble() ?? 0.0,
        download: (data['download'] as num?)?.toDouble() ?? 0.0,
        upload: (data['upload'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.now(),
      );

      _controller?.add(result);
    } catch (error) {
      _handleError(
        InvalidSpeedTestDataException(
          message: 'Failed to parse speed test data',
          originalError: error,
        ),
      );
    }
  }

  /// Handles WebSocket errors with reconnection logic
  void _handleError(dynamic error) {
    if (_isDisposed) return;

    _controller?.addError(error);

    if (_reconnectAttempts < WebSocketConfig.maxReconnectAttempts) {
      _reconnectAttempts++;
      Future.delayed(
        Duration(
          milliseconds: WebSocketConfig.reconnectDelay * _reconnectAttempts,
        ),
        _initializeWebSocket,
      );
    } else {
      _controller?.addError(
        const WebSocketConnectionException(
          message: 'Maximum reconnection attempts reached',
        ),
      );
    }
  }

  /// Handles WebSocket disconnection
  void _handleDisconnection() {
    if (_isDisposed) return;
    _handleError(
      const WebSocketConnectionException(
        message: 'WebSocket connection closed unexpectedly',
      ),
    );
  }

  /// Starts a timer to send periodic ping messages
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      Duration(milliseconds: WebSocketConfig.pingInterval),
      (_) => _channel?.sink.add(jsonEncode({'type': 'ping'})),
    );
  }

  /// Starts the speed test and returns a stream of results
  Future<Stream<SpeedTestResult>> startSpeedTest() async {
    if (_isDisposed) {
      throw const SpeedTestException(message: 'Repository has been disposed');
    }

    await _initializeWebSocket();
    _channel?.sink.add(jsonEncode({'action': 'start_test'}));

    // Set timeout for speed test
    Future.delayed(
      Duration(milliseconds: WebSocketConfig.speedTestTimeout),
      () {
        if (_controller?.isClosed == false) {
          _handleError(const SpeedTestTimeoutException());
        }
      },
    );

    return _controller!.stream;
  }

  /// Stops the current speed test
  void stopSpeedTest() {
    _channel?.sink.add(jsonEncode({'action': 'stop_test'}));
  }

  /// Disposes of all resources
  Future<void> dispose() async {
    _isDisposed = true;
    _pingTimer?.cancel();
    _connectionTimeout?.cancel();
    await _controller?.close();
    await _channel?.sink.close();
  }
}
