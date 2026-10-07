
import 'package:oneconnect_flutter/openvpn_flutter.dart';

extension VpnStageExtensionX on VPNStage? {

  bool get isPrepare => this == VPNStage.prepare;

  bool get isAuthenticating => this == VPNStage.authenticating;

  bool get isConnecting => this == VPNStage.connecting;

  bool get isAuthentication => this == VPNStage.authentication;

  bool get isConnected => this == VPNStage.connected;

  bool get isDisconnected => this == VPNStage.disconnected;

  bool get isDisconnecting => this == VPNStage.disconnecting;

  bool get isDenied => this == VPNStage.denied;

  bool get isError => this == VPNStage.error;

  bool get isWaitConnection => this == VPNStage.wait_connection;

  bool get isVpnGenerateConfig => this == VPNStage.vpn_generate_config;

  bool get isGetConfig => this == VPNStage.get_config;

  bool get isTcpConnect => this == VPNStage.tcp_connect;

  bool get isUdpConnect => this == VPNStage.udp_connect;

  bool get isAssignIp => this == VPNStage.assign_ip;

  bool get isResolve => this == VPNStage.resolve;

  bool get isExiting => this == VPNStage.exiting;

  bool get isUnknown => this == VPNStage.unknown;

  String get toName {
    switch (this ?? VPNStage.unknown) {
      case VPNStage.prepare:
        return "Preparing";
      case VPNStage.authenticating:
        return "Authenticating";
      case VPNStage.connecting:
        return "Connecting";
      case VPNStage.authentication:
        return "Authentication";
      case VPNStage.connected:
        return "Connected";
      case VPNStage.disconnected:
        return "Disconnected";
      case VPNStage.disconnecting:
        return "Disconnecting";
      case VPNStage.denied:
        return "Denied";
      case VPNStage.error:
        return "Error";
      case VPNStage.wait_connection:
        return "Waiting Connection";
      case VPNStage.vpn_generate_config:
        return "Generating Config";
      case VPNStage.get_config:
        return "Getting Config";
      case VPNStage.tcp_connect:
        return "TCP Connecting";
      case VPNStage.udp_connect:
        return "UDP Connecting";
      case VPNStage.assign_ip:
        return "Assigning IP";
      case VPNStage.resolve:
        return "Resolving";
      case VPNStage.exiting:
        return "Exiting";
      case VPNStage.unknown:
        return "Unknown";
    }
  }

}
