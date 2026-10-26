
import 'dart:async';

import 'package:oneconnect_flutter/openvpn_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';

/// A service that manages the VPN connection (OpenVPN and WireGuard).
class VpnService {

  // Private constructor for the singleton instance.
  VpnService._(){initEngine();}

  // Singleton instance of the VpnService.
  static final VpnService instance = VpnService._();

  // The OpenVPN engine instance.
  late OpenVPN engine;

  /// The last stage text sent by the OpenVPN engine (used to explain a failure).
  String lastRawStage = "";

  /// Where the last connect() call is: permission / engine / started (used to explain a failure).
  String connectPhase = "";

  // The WireGuard engine instance.
  final _wireguard = WireGuardFlutter.instance;

  // The protocol of the connection that was started last.
  VpnProtocol _active = VpnProtocol.openvpn;

  // The package name, used as the iOS provider bundle id for WireGuard.
  String _packageName = '';

  // Stream controller for broadcasting VPN status updates.
  final StreamController<VpnStatus?> _statusController = StreamController.broadcast();
  // Stream controller for broadcasting VPN stage changes.
  final StreamController<VPNStage> _stageController = StreamController.broadcast();


  /// Initializes the OpenVPN engine and its listeners.
  void initEngine(){
    engine = OpenVPN(
      onVpnStatusChanged: (status) => _statusController.add(status),
      onVpnStageChanged: (stage, rawStage) {
        lastRawStage = rawStage;
        _stageController.add(stage);
      },
    );
  }


  /// Initializes the VPN engines with app-specific identifiers.
  Future<void> initialize() async {
    // Fetches package information to dynamically set iOS-specific identifiers.
    await PackageInfo.fromPlatform().then((packageInfo) async {
      _packageName = packageInfo.packageName;
      await engine.initialize(
        groupIdentifier: "group.${packageInfo.packageName}", // iOS App Group
        providerBundleIdentifier: packageInfo.packageName, // iOS VPN extension bundle ID
        localizedDescription: packageInfo.appName, // Shown in VPN permission dialog
      );
    });
    // WireGuard is NOT started here: its initialize() asks for the Android VPN
    // permission, and that dialog must only appear when the user taps Connect.
  }

  // True after WireGuard was initialized successfully (done on the first WireGuard connect).
  bool _wireguardReady = false;
  StreamSubscription? _wireguardSub;

  /// Starts the WireGuard engine once, right before the first WireGuard connection.
  /// The VPN permission was already granted by [requestPermission] at that point,
  /// so no second dialog appears. A failure here must never break OpenVPN.
  Future<void> _ensureWireGuard() async {
    if (_wireguardReady) return;
    try {
      await _wireguard.initialize(interfaceName: 'wg0');
      _wireguardSub ??= _wireguard.vpnStageSnapshot.listen((stage) {
        final mapped = _mapWireGuardStage(stage.name);
        if (mapped != null) _stageController.add(mapped);
      });
      _wireguardReady = true;
    } catch (_) {}
  }

  /// Converts a WireGuard stage name to the app's [VPNStage].
  static VPNStage? _mapWireGuardStage(String name) {
    switch (name) {
      case 'connected':
        return VPNStage.connected;
      case 'connecting':
      case 'waitingConnection':
      case 'preparing':
      case 'authenticating':
      case 'reconnect':
        return VPNStage.connecting;
      case 'disconnecting':
        return VPNStage.disconnecting;
      case 'disconnected':
      case 'noConnection':
      case 'exiting':
        return VPNStage.disconnected;
      case 'denied':
        return VPNStage.denied;
      default:
        return null;
    }
  }

  /// Reads "Endpoint = host:port" from a WireGuard config.
  static String? _wireGuardEndpoint(String config) {
    for (final raw in config.split(RegExp(r'\r?\n'))) {
      final line = raw.trim();
      if (line.toLowerCase().startsWith('endpoint')) {
        final index = line.indexOf('=');
        if (index != -1) return line.substring(index + 1).trim();
      }
    }
    return null;
  }


  /// Connects to the VPN using the provided config and credentials.
  /// Returns an error message when the connection could not be started, otherwise null.
  Future<String?> connect({
    required String config,
    required String country,
    String? username,
    String? password,
    VpnProtocol protocol = VpnProtocol.openvpn,
  }) async {
    if (config.trim().isEmpty) {
      return "This server has no valid configuration. Please choose another server.";
    }
    try {
      lastRawStage = "";
      connectPhase = "permission";
      // Requests necessary permissions before attempting to connect.
      if (!await requestPermission()) {
        return "VPN permission was not granted. Please allow it to connect.";
      }
      _active = protocol;
      if (protocol == VpnProtocol.wireguard) {
        await _ensureWireGuard();
        final endpoint = _wireGuardEndpoint(config);
        if (endpoint == null || endpoint.isEmpty) {
          return "This WireGuard server has no Endpoint. Please choose another server.";
        }
        await _wireguard.startVpn(
          serverAddress: endpoint,
          wgQuickConfig: config,
          providerBundleIdentifier: _packageName,
        );
        return null;
      }
      connectPhase = "engine";
      await engine.connect(
          config,
          country,
          username: (username == null || username.isEmpty) ? "vpn" : username,
          password: (password == null || password.isEmpty) ? "vpn" : password,
          certIsRequired: true
      );
      connectPhase = "started";
      return null;
    } catch (e) {
      return "Could not start the VPN connection. Please try another server.";
    }
  }

  /// Disconnects from the current VPN session.
  void disconnect() {
    if (_active == VpnProtocol.wireguard) {
      _wireguard.stopVpn().catchError((_) {});
    } else {
      engine.disconnect();
    }
  }

  /// Checks if the VPN is currently connected.
  Future<bool> isConnected() async {
    if (await engine.isConnected()) return true;
    try {
      final stage = await _wireguard.stage();
      if (stage.name == 'connected') {
        _active = VpnProtocol.wireguard;
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Requests the required Android permissions for the VPN service.
  Future<bool> requestPermission() async => await engine.requestPermissionAndroid();


  /// Exposes the stream of VPN status updates.
  Stream<VpnStatus?> get statusStream => _statusController.stream;
  /// Exposes the stream of VPN connection stage changes.
  Stream<VPNStage> get stageStream => _stageController.stream;

}
