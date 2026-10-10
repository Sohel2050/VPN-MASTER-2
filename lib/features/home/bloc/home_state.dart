
part of 'home_bloc.dart';

/// Represents the state of the home screen, including VPN connection status.
class HomeState extends Equatable{

  /// An optional message, typically for errors or status updates.
  final String? message;
  /// The overall status of operations on the home screen.
  final Status status;
  /// Indicates whether the VPN is currently connected.
  final bool vpnIsConnected;
  /// Detailed status of the VPN connection from the 'openvpn_flutter' package.
  final VpnStatus? vpnStatus;
  /// The current stage in the VPN connection lifecycle (e.g., connecting, connected).
  final VPNStage? vpnStage;
  /// True when the last connection attempt failed.
  final bool connectionFailed;

  /// Creates a [HomeState].
  const HomeState({
    required this.message,
    required this.status,
    required this.vpnIsConnected,
    required this.vpnStatus,
    required this.vpnStage,
    this.connectionFailed = false,
  });

  /// Creates the initial state for the home screen.
  factory HomeState.initial() => const HomeState(
    message: null,
    status: Status.initial,
    vpnIsConnected: false,
    vpnStatus: null,
    vpnStage: null
  );

  /// Creates a copy of the current state with updated values.
  HomeState copyWith({
    String? message,
    Status? status,
    bool? vpnIsConnected,
    VpnStatus? vpnStatus,
    VPNStage? vpnStage,
    bool? connectionFailed,
  }) => HomeState(
    message: message ?? this.message,
    status: status ?? this.status,
    vpnIsConnected: vpnIsConnected ?? this.vpnIsConnected,
    vpnStatus: vpnStatus ?? this.vpnStatus,
    vpnStage: vpnStage ?? this.vpnStage,
    connectionFailed: connectionFailed ?? this.connectionFailed,
  );

  @override
  List<Object?> get props => [
    message,
    status,
    vpnIsConnected,
    vpnStatus,
    vpnStage,
    connectionFailed
  ];

}
