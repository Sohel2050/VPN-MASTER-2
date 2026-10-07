import 'package:equatable/equatable.dart';
import 'package:flutter_internet_speed_test_pro/flutter_internet_speed_test_pro.dart';

/// The base class for all events related to the speed test feature.
sealed class SpeedTestEvent extends Equatable{}

/// Dispatched to start the internet speed test.
class StartSpeedTest extends SpeedTestEvent {
  @override
  List<Object?> get props => [];
}

/// Dispatched during the download test with an updated test result.
class DownloadSpeed extends SpeedTestEvent{
  /// The current download test result.
  final TestResult speed;

  /// Creates a [DownloadSpeed] event.
  DownloadSpeed({required this.speed});

  @override
  List<Object?> get props => [speed];
}

/// Dispatched during the upload test with an updated test result.
class UploadSpeed extends SpeedTestEvent{

  /// The current upload test result.
  final TestResult speed;

  /// Creates an [UploadSpeed] event.
  UploadSpeed({required this.speed});

  @override
  List<Object?> get props => [speed];
}

/// Dispatched to fetch the ping time.
class GetPing extends SpeedTestEvent {
  @override
  List<Object?> get props => [];
}
