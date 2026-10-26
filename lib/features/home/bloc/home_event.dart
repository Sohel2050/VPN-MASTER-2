import 'package:equatable/equatable.dart';
import 'package:oneconnect_flutter/openvpn_flutter.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';
/// The base class for all events related to the home screen and VPN connection.
sealed class HomeEvent extends Equatable{}

/// Dispatched to initialize and start listening to VPN status and stage streams.
class StartVpnTracking extends HomeEvent{
  @override
  List<Object?> get props => [];
}

/// Dispatched to check the current VPN connection status.
class VpnConnectionStatus extends HomeEvent{
  @override
  List<Object?> get props => [];
}

/// Dispatched to connect to a VPN server.
class ConnectVpn extends HomeEvent{
  /// The OpenVPN configuration data.
  final String config;
  /// The name of the country for the server.
  final String country;
  /// Login for servers that need one (your own VPS). Optional.
  final String? username;
  /// Password for servers that need one. Optional.
  final String? password;
  /// The protocol of the server (OpenVPN or WireGuard).
  final VpnProtocol protocol;

  /// Creates a [ConnectVpn] event.
  ConnectVpn({
    required this.config,
    required this.country,
    this.username,
    this.password,
    this.protocol = VpnProtocol.openvpn,
  });

  @override
  List<Object?> get props => [
    config,
    country,
    username,
    password,
    protocol,
  ];
}

/// Dispatched to disconnect from the current VPN session.
class DisconnectVpn extends HomeEvent{
  @override
  List<Object?> get props => [];
}

/// Dispatched internally to update the BLoC with the latest [VpnStatus].
class TrackVpnStatus extends HomeEvent{
  /// The latest status from the VPN service.
  final VpnStatus? status;
  /// Creates a [TrackVpnStatus] event.
  TrackVpnStatus({required this.status});

  @override
  List<Object?> get props => [status];
}


/// Dispatched internally to update the BLoC with the latest [VPNStage].
class TrackVpnStage extends HomeEvent{
  /// The latest stage from the VPN service.
  final VPNStage? stage;
  /// Creates a [TrackVpnStage] event.
  TrackVpnStage({required this.stage});

  @override
  List<Object?> get props => [stage];
}


/// Dispatched when a connection attempt failed or timed out.
class ConnectionFailed extends HomeEvent{
  /// Short text that tells why it failed (shown in the error message).
  final String reason;
  ConnectionFailed({this.reason = ""});
  @override
  List<Object?> get props => [reason];
}
