import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oneconnect_flutter/openvpn_flutter.dart';
import 'package:vpn_master/core/helpers/toast_notification/toast_notifications.dart';
import 'package:vpn_master/core/services/vpn/vpn_service.dart';
import 'package:vpn_master/core/utils/enums/enums.dart';
import 'package:vpn_master/features/home/bloc/home_event.dart';


part 'home_state.dart';

/// Handles the business logic for the home screen, including VPN connection management.
class HomeBloc extends Bloc<HomeEvent, HomeState>{
  StreamSubscription<VpnStatus?>? _statusSub;
  StreamSubscription<VPNStage>? _stageSub;

  Timer? _connectTimeout;

  @override
  Future<void> close() {
    _connectTimeout?.cancel();
    _statusSub?.cancel();
    _stageSub?.cancel();
    return super.close();
  }

  /// Initializes the BLoC and registers event handlers.
  HomeBloc(): super(HomeState.initial()){
    on<StartVpnTracking>(_onStartVpnTracking);
    on<VpnConnectionStatus>(_onVpnConnectionStatus);
    on<TrackVpnStatus>(_onTrackVpnStatus);
    on<TrackVpnStage>(_onTrackVpnStage);
    on<ConnectVpn>(_onConnectVpn);
    on<DisconnectVpn>(_onDisconnectVpn);
    on<ConnectionFailed>(_onConnectionFailed);
  }

  /// Sets up listeners for VPN status and stage changes.
  Future<void> _onStartVpnTracking(StartVpnTracking event, Emitter<HomeState> emit) async {
    // Checks the initial connection status.
    add(VpnConnectionStatus());
    // Listens for real-time status updates from the VPN service.
    _statusSub?.cancel();
    _stageSub?.cancel();
    _statusSub = VpnService.instance.statusStream.listen((status) => add(TrackVpnStatus(status: status)));
    // Listens for real-time stage updates from the VPN service.
    _stageSub = VpnService.instance.stageStream.listen((stage) => add(TrackVpnStage(stage: stage)));
  }


  /// Checks and updates the VPN connection status.
  Future<void> _onVpnConnectionStatus(VpnConnectionStatus event, Emitter<HomeState> emit) async {
    final vpnIsConnected = await VpnService.instance.isConnected();
    emit(state.copyWith(
        vpnIsConnected: vpnIsConnected,
        vpnStage: vpnIsConnected ? VPNStage.connected : VPNStage.disconnected
    ));
  }


  /// Updates the state with the latest VPN status from the stream.
  Future<void> _onTrackVpnStatus(TrackVpnStatus event, Emitter<HomeState> emit) async {
    emit(state.copyWith(vpnStatus: event.status));
  }

  /// Updates the state with the latest VPN stage from the stream.
  Future<void> _onTrackVpnStage(TrackVpnStage event, Emitter<HomeState> emit) async {
    if (event.stage == VPNStage.connected) {
      _connectTimeout?.cancel();
      emit(state.copyWith(vpnStage: event.stage, connectionFailed: false));
    } else if (event.stage == VPNStage.error || event.stage == VPNStage.denied) {
      _connectTimeout?.cancel();
      add(ConnectionFailed());
    } else if (state.connectionFailed && event.stage != VPNStage.connecting) {
      // Stages that arrive after a failure must not hide the "Failed" label.
      emit(state.copyWith(vpnStage: event.stage));
    } else {
      emit(state.copyWith(vpnStage: event.stage));
    }
  }


  /// Initiates a VPN connection with the provided configuration.
  Future<void> _onConnectVpn(ConnectVpn event, Emitter<HomeState> emit) async {
    emit(state.copyWith(vpnStage: VPNStage.connecting, connectionFailed: false));
    final error = await VpnService.instance.connect(
        config: event.config,
        country: event.country,
        username: event.username,
        password: event.password
    );
    if (error != null) {
      emit(state.copyWith(vpnStage: VPNStage.disconnected, message: error, connectionFailed: true));
      ToastNotifications.showErrorToast(title: "Connection failed", message: error);
      return;
    }
    // Many free servers are offline: stop waiting after 40 seconds.
    _connectTimeout?.cancel();
    _connectTimeout = Timer(const Duration(seconds: 40), () {
      if (state.vpnStage != VPNStage.connected) add(ConnectionFailed());
    });
  }


  /// A connection attempt failed (error, denied or timeout): stop it and show "Failed".
  Future<void> _onConnectionFailed(ConnectionFailed event, Emitter<HomeState> emit) async {
    if (state.vpnStage == VPNStage.connected || state.connectionFailed) return;
    _connectTimeout?.cancel();
    VpnService.instance.disconnect();
    emit(state.copyWith(
      vpnStage: VPNStage.disconnected,
      vpnIsConnected: false,
      connectionFailed: true,
    ));
    ToastNotifications.showErrorToast(
      title: "Server failed",
      message: "This server did not connect. The next server was selected.",
    );
  }


  /// Disconnects from the current VPN session.
  Future<void> _onDisconnectVpn(DisconnectVpn event, Emitter<HomeState> emit) async {
    _connectTimeout?.cancel();
    VpnService.instance.disconnect();
    emit(state.copyWith(
      vpnStage: VPNStage.disconnected,
      vpnIsConnected: false,
      connectionFailed: false,
    ));
  }

}