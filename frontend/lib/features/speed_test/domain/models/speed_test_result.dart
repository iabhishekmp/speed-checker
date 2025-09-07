import 'package:equatable/equatable.dart';

class SpeedTestResult extends Equatable {
  final double ping;
  final double download;
  final double upload;
  final DateTime timestamp;

  const SpeedTestResult({
    required this.ping,
    required this.download,
    required this.upload,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [ping, download, upload, timestamp];

  factory SpeedTestResult.initial() => SpeedTestResult(
    ping: 0,
    download: 0,
    upload: 0,
    timestamp: DateTime.now(),
  );

  SpeedTestResult copyWith({
    double? ping,
    double? download,
    double? upload,
    DateTime? timestamp,
  }) {
    return SpeedTestResult(
      ping: ping ?? this.ping,
      download: download ?? this.download,
      upload: upload ?? this.upload,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
