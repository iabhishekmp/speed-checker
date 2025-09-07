import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/exceptions/speed_test_exception.dart';
import '../../data/repositories/speed_test_repository.dart';
import '../../domain/models/speed_test_result.dart';

/// Events for the SpeedTestBloc
sealed class SpeedTestEvent extends Equatable {
  const SpeedTestEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start a speed test
final class StartSpeedTest extends SpeedTestEvent {
  const StartSpeedTest();
}

/// Event to stop a speed test
final class StopSpeedTest extends SpeedTestEvent {
  const StopSpeedTest();
}

/// States for the SpeedTestBloc
sealed class SpeedTestState extends Equatable {
  const SpeedTestState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any speed test
final class SpeedTestInitial extends SpeedTestState {
  const SpeedTestInitial();
}

/// State when speed test is in progress
final class SpeedTestInProgress extends SpeedTestState {
  const SpeedTestInProgress();
}

/// State when speed test completes successfully
final class SpeedTestComplete extends SpeedTestState {
  final SpeedTestResult result;

  const SpeedTestComplete(this.result);

  @override
  List<Object?> get props => [result];
}

/// State when speed test encounters an error
final class SpeedTestError extends SpeedTestState {
  final String message;
  final String? code;
  final bool canRetry;

  const SpeedTestError({
    required this.message,
    this.code,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, code, canRetry];

  /// Creates an error state from a SpeedTestException
  factory SpeedTestError.fromException(SpeedTestException exception) {
    return SpeedTestError(
      message: exception.message,
      code: exception.code,
      canRetry:
          exception is! WebSocketConnectionException ||
          exception.code != 'WEBSOCKET_CONNECTION_ERROR',
    );
  }
}

/// BLoC for managing speed test operations
class SpeedTestBloc extends Bloc<SpeedTestEvent, SpeedTestState> {
  final SpeedTestRepository _repository;
  StreamSubscription<SpeedTestResult>? _speedTestSubscription;

  SpeedTestBloc({required SpeedTestRepository repository})
    : _repository = repository,
      super(const SpeedTestInitial()) {
    on<StartSpeedTest>(_onStartSpeedTest);
    on<StopSpeedTest>(_onStopSpeedTest);
  }

  Future<void> _onStartSpeedTest(
    StartSpeedTest event,
    Emitter<SpeedTestState> emit,
  ) async {
    try {
      emit(const SpeedTestInProgress());
      await _speedTestSubscription?.cancel();

      final stream = await _repository.startSpeedTest();
      _speedTestSubscription = stream.listen(
        (result) => emit(SpeedTestComplete(result)),
        onError: (error) {
          if (error is SpeedTestException) {
            emit(SpeedTestError.fromException(error));
          } else {
            emit(
              SpeedTestError(
                message: 'An unexpected error occurred',
                code: 'UNKNOWN_ERROR',
              ),
            );
          }
        },
      );
    } on SpeedTestException catch (e) {
      emit(SpeedTestError.fromException(e));
    } catch (e) {
      emit(
        SpeedTestError(
          message: 'Failed to start speed test',
          code: 'START_TEST_ERROR',
        ),
      );
    }
  }

  void _onStopSpeedTest(StopSpeedTest event, Emitter<SpeedTestState> emit) {
    try {
      _repository.stopSpeedTest();
      _speedTestSubscription?.cancel();
      emit(const SpeedTestInitial());
    } catch (e) {
      emit(
        SpeedTestError(
          message: 'Failed to stop speed test',
          code: 'STOP_TEST_ERROR',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _speedTestSubscription?.cancel();
    await _repository.dispose();
    return super.close();
  }
}
