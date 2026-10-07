import 'package:equatable/equatable.dart';
import 'package:winsguard/features/servers/domain/entities/vpn_server_entity.dart';

/// The base class for all events related to the servers feature.
sealed class ServersEvent extends Equatable{}

/// Dispatched to fetch the list of available VPN servers.
class GetVpnServers extends ServersEvent{
  @override
  List<Object?> get props => [];
}

/// Dispatched to set the default server from a list of servers.
class DefaultServer extends ServersEvent{

  /// The list of servers to choose the default from.
  final List<VpnServerEntity> servers;
  /// Creates a [DefaultServer] event.
  DefaultServer({required this.servers});

  @override
  List<Object?> get props => [
    servers
  ];
}

/// Dispatched when a user selects a VPN server.
class SelectServer extends ServersEvent{

  /// The server that was selected.
  final VpnServerEntity server;
  /// Creates a [SelectServer] event.
  SelectServer({required this.server});

  @override
  List<Object?> get props => [
    server
  ];
}

/// Dispatched to get the currently connected server.
class GetConnectedServer extends ServersEvent{
  @override
  List<Object?> get props => [];
}

/// Dispatched to save the currently connected server for future sessions.
class SaveConnectedServer extends ServersEvent{
  /// The server to save.
  final VpnServerEntity connectServer;
  /// Creates a [SaveConnectedServer] event.
  SaveConnectedServer({required this.connectServer});
  @override
  List<Object?> get props => [
    connectServer
  ];
}
