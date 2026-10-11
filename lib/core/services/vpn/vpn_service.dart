
import 'dart:async';

import 'package:oneconnect_flutter/openvpn_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A service that manages the VPN connection using the OpenVPN library.
class VpnService {

  // Private constructor for the singleton instance.
  VpnService._(){initEngine();}

  // Singleton instance of the VpnService.
  static final VpnService instance = VpnService._();

  // The OpenVPN engine instance.
  late OpenVPN engine;

  // Stream controller for broadcasting VPN status updates.
  final StreamController<VpnStatus?> _statusController = StreamController.broadcast();
  // Stream controller for broadcasting VPN stage changes.
  final StreamController<VPNStage> _stageController = StreamController.broadcast();


  /// Initializes the OpenVPN engine and its listeners.
  void initEngine(){
    engine = OpenVPN(
      onVpnStatusChanged: (status) => _statusController.add(status),
      onVpnStageChanged: (stage, rawStage) => _stageController.add(stage),
    );
  }


  /// Initializes the VPN engine with app-specific identifiers.
  Future<void> initialize() async {
    // Fetches package information to dynamically set iOS-specific identifiers.
    await PackageInfo.fromPlatform().then((packageInfo) async {
      await engine.initialize(
        groupIdentifier: "group.${packageInfo.packageName}", // iOS App Group
        providerBundleIdentifier: packageInfo.packageName, // iOS VPN extension bundle ID
        localizedDescription: packageInfo.appName, // Shown in VPN permission dialog
      );
    });
  }


  /// Connects to the VPN using the provided config and credentials.
  /// Returns an error message when the connection could not be started, otherwise null.
  Future<String?> connect({required String config, required String country, String? username, String? password}) async {
    if (config.trim().isEmpty) {
      return "This server has no valid configuration. Please choose another server.";
    }
    try {
      // Requests necessary permissions before attempting to connect.
      if (!await requestPermission()) {
        return "VPN permission was not granted. Please allow it to connect.";
      }
      await engine.connect(
          config,
          country,
          username: (username == null || username.isEmpty) ? "vpn" : username,
          password: (password == null || password.isEmpty) ? "vpn" : password,
          certIsRequired: true
      );
      return null;
    } catch (e) {
      return "Could not start the VPN connection. Please try another server.";
    }
  }

  /// Disconnects from the current VPN session.
  void disconnect() => engine.disconnect();

  /// Checks if the VPN is currently connected.
  Future<bool> isConnected() async => await engine.isConnected();

  /// Requests the required Android permissions for the VPN service.
  Future<bool> requestPermission() async => await engine.requestPermissionAndroid();


  /// Exposes the stream of VPN status updates.
  Stream<VpnStatus?> get statusStream => _statusController.stream;
  /// Exposes the stream of VPN connection stage changes.
  Stream<VPNStage> get stageStream => _stageController.stream;

}
