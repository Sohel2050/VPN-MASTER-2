part of 'servers_bloc.dart';

/// Represents the state of the servers feature.
class ServersState extends Equatable{
  /// An optional message, typically for errors.
  final String? message;
  /// The overall status of server-related operations.
  final Status status;
  /// The currently selected VPN server.
  final VpnServerEntity? selectedServer;
  /// The list of available VPN servers.
  final List<VpnServerEntity>? vpnServers;

  /// Creates a [ServersState].
  const ServersState({
    required this.message,
    required this.status,
    required this.selectedServer,
    required this.vpnServers,
  });

  /// Creates the initial state for the servers feature.
  factory ServersState.initial() => const ServersState(
    message: null,
    status: Status.initial,
    selectedServer: null,
    vpnServers: null,
  );

  /// Creates a copy of the current state with the given values.
  ServersState copyWith({
    String? message,
    Status? status,
    VpnServerEntity? selectedServer,
    List<VpnServerEntity>? vpnServers
  })=> ServersState(
    message: message ?? this.message,
    status: status ?? this.status,
    selectedServer: selectedServer ?? this.selectedServer,
    vpnServers: vpnServers ?? this.vpnServers,
  );

  @override
  List<Object?> get props => [
    message,
    status,
    selectedServer,
    vpnServers
  ];

}
