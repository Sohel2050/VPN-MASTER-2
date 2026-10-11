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
  /// Your own (private) servers, shown first in the "My Servers" tab.
  final List<VpnServerEntity> ownServers;

  /// Creates a [ServersState].
  const ServersState({
    required this.message,
    required this.status,
    required this.selectedServer,
    required this.vpnServers,
    this.ownServers = const [],
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
    List<VpnServerEntity>? vpnServers,
    List<VpnServerEntity>? ownServers
  })=> ServersState(
    message: message ?? this.message,
    status: status ?? this.status,
    selectedServer: selectedServer ?? this.selectedServer,
    vpnServers: vpnServers ?? this.vpnServers,
    ownServers: ownServers ?? this.ownServers,
  );

  @override
  List<Object?> get props => [
    message,
    status,
    selectedServer,
    vpnServers,
    ownServers
  ];

}
