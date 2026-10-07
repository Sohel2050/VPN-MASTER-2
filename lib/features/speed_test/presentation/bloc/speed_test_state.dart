part of 'speed_test_bloc.dart';


/// Represents the state of the speed test feature.
class SpeedTestState extends Equatable{

  /// An optional message, typically for errors.
  final String? message;
  /// The overall status of the speed test.
  final Status status;
  /// The status of the download speed test.
  final Status downloadStatus;
  /// The status of the upload speed test.
  final Status uploadStatus;
  /// The current speed test result.
  final TestResult? speed;
  /// The final download speed test result.
  final TestResult? downloadSpeed;
  /// The final upload speed test result.
  final TestResult? uploadSpeed;
  /// The ping time in milliseconds.
  final int? ping;

  /// Creates a [SpeedTestState].
  const SpeedTestState({
    required this.message,
    required this.status,
    required this.downloadStatus,
    required this.uploadStatus,
    required this.speed,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.ping,
  });

  /// Creates the initial state for the speed test.
  factory SpeedTestState.initial() => const SpeedTestState(
    message: null,
    status: Status.initial,
    downloadStatus: Status.initial,
    uploadStatus: Status.initial,
    speed: null,
    downloadSpeed: null,
    uploadSpeed: null,
    ping: null,
  );

  /// Creates a copy of the current state with the given values.
  SpeedTestState copyWith({
    String? message,
    Status? status,
    Status? downloadStatus,
    Status? uploadStatus,
    TestResult? speed,
    TestResult? downloadSpeed,
    TestResult? uploadSpeed,
    int? ping
  }) => SpeedTestState(
    message: message ?? this.message,
    status: status ?? this.status,
    downloadStatus: downloadStatus ?? this.downloadStatus,
    uploadStatus: uploadStatus ?? this.uploadStatus,
    speed: speed ?? this.speed,
    downloadSpeed: downloadSpeed ?? this.downloadSpeed,
    uploadSpeed: uploadSpeed ?? this.uploadSpeed,
    ping: ping ?? this.ping,
  );

  @override
  List<Object?> get props => [
    message,
    status,
    downloadStatus,
    uploadStatus,
    speed,
    downloadSpeed,
    uploadSpeed,
    ping
  ];

}
