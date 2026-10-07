part of 'network_info_bloc.dart';

/// Represents the state of the network information feature.
class NetworkInfoState extends Equatable{
  /// An optional message, typically for errors.
  final String? message;
  /// The overall status of the network info request.
  final Status status;
  /// The network information data.
  final NetworkInfoEntity? networkInfoEntity;

  /// Creates a [NetworkInfoState].
  const NetworkInfoState({
    required this.message,
    required this.status,
    required this.networkInfoEntity,
  });

  /// Creates the initial state for the network info feature.
  factory NetworkInfoState.initial() => const NetworkInfoState(
    message: null,
    status: Status.initial,
    networkInfoEntity: null,
  );

  /// Creates a copy of the current state with the given values.
  NetworkInfoState copyWith({
    String? message,
    Status? status,
    NetworkInfoEntity? networkInfoEntity
  })=> NetworkInfoState(
    message: message ?? this.message,
    status: status ?? this.status,
    networkInfoEntity: networkInfoEntity ?? this.networkInfoEntity,
  );

  @override
  List<Object?> get props => [
    message,
    status,
    networkInfoEntity,
  ];

}
