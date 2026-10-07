import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oneconnect_flutter/openvpn_flutter.dart';import 'package:winsguard/core/services/vpn/vpn_service.dart';
import 'package:winsguard/core/utils/enums/enums.dart';
import 'package:winsguard/features/home/bloc/home_event.dart';


part 'home_state.dart';

/// Handles the business logic for the home screen, including VPN connection management.
class HomeBloc extends Bloc<HomeEvent, HomeState>{
  /// Initializes the BLoC and registers event handlers.
  HomeBloc(): super(HomeState.initial()){
    on<StartVpnTracking>(_onStartVpnTracking);
    on<VpnConnectionStatus>(_onVpnConnectionStatus);
    on<TrackVpnStatus>(_onTrackVpnStatus);
    on<TrackVpnStage>(_onTrackVpnStage);
    on<ConnectVpn>(_onConnectVpn);
    on<DisconnectVpn>(_onDisconnectVpn);
  }

  /// Sets up listeners for VPN status and stage changes.
  Future<void> _onStartVpnTracking(StartVpnTracking event, Emitter<HomeState> emit) async {
    // Checks the initial connection status.
    add(VpnConnectionStatus());
    // Listens for real-time status updates from the VPN service.
    VpnService.instance.statusStream.listen((status) => add(TrackVpnStatus(status: status)));
    // Listens for real-time stage updates from the VPN service.
    VpnService.instance.stageStream.listen((stage) => add(TrackVpnStage(stage: stage)));
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
    emit(state.copyWith(vpnStage: event.stage));
  }


  /// Initiates a VPN connection with the provided configuration.
  Future<void> _onConnectVpn(ConnectVpn event, Emitter<HomeState> emit) async {
    VpnService.instance.connect(
        config: event.config,
        country: event.country
    );
  }


  /// Disconnects from the current VPN session.
  Future<void> _onDisconnectVpn(DisconnectVpn event, Emitter<HomeState> emit) async {
    VpnService.instance.disconnect();
    emit(state.copyWith(
      vpnStage: VPNStage.disconnected,
      vpnIsConnected: false
    ));
  }

}