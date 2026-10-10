import 'package:equatable/equatable.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';

/// The base class for all events related to the servers feature.
sealed class ServersEvent extends Equatable{}

/// Dispatched to fetch the list of available VPN servers.
class GetVpnServers extends ServersEvent{
  /// When true the list refreshes in the background (no loading animation).
  final bool silent;
  /// Creates a [GetVpnServers] event.
  GetVpnServers({this.silent = false});
  @override
  List<Object?> get props => [silent];
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


/// Dispatched when a server failed to connect: it is hidden and the next server is selected.
class MarkServerFailed extends ServersEvent{
  /// The server that failed.
  final VpnServerEntity? server;
  /// Creates a [MarkServerFailed] event.
  MarkServerFailed({required this.server});
  @override
  List<Object?> get props => [server];
}


/// Dispatched to test (in the background) which servers are really alive.
class ProbeServers extends ServersEvent{
  @override
  List<Object?> get props => [];
}
