import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/helpers/blocked_countries.dart';
import 'package:vpn_master/core/helpers/failed_servers.dart';
import 'package:vpn_master/core/helpers/helpers.dart';
import 'package:vpn_master/core/helpers/server_probe.dart';
import 'package:vpn_master/core/services/vpn/vpn_service.dart';
import 'package:vpn_master/core/utils/enums/enums.dart';
import 'package:vpn_master/core/utils/extensions/status_extension.dart';
import 'package:vpn_master/features/servers/data/own_servers_source.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';
import 'package:vpn_master/features/servers/domain/usecases/get_connected_server_usecase.dart';
import 'package:vpn_master/features/servers/domain/usecases/get_vpn_servers_usecase.dart';
import 'package:vpn_master/features/servers/domain/usecases/save_connected_server_usecase.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_event.dart';

part 'servers_state.dart';


/// Handles the business logic for the servers feature.
class ServersBloc extends Bloc<ServersEvent, ServersState>{

  /// Initializes the BLoC and registers event handlers.
  ServersBloc(): super(ServersState.initial()){
    on<GetVpnServers>(_onGetServers);
    on<DefaultServer>(_onDefaultServer);
    on<SelectServer>(_onSelectServer);
    on<SaveConnectedServer>(_onSaveConnectedServer);
    on<GetConnectedServer>(_onGetConnectedServer);
    on<MarkServerFailed>(_onMarkServerFailed);
    on<ProbeServers>(_onProbeServers);
    on<LoadOwnServers>(_onLoadOwnServers);
    // Load your private servers as soon as the app starts.
    add(LoadOwnServers());
  }

  /// Handles the [GetVpnServers] event, fetching the list of available VPN servers.
  bool _fetching = false;

  /// Every server of the last download that is not known to be dead. Only the ones
  /// that really answered (see ServerProbe) are shown in the list.
  List<VpnServerEntity> _candidates = [];

  Future<void> _onGetServers(GetVpnServers event, Emitter<ServersState> emit) async{
    // A refresh is already running: do not start another one.
    if (_fetching) return;
    _fetching = true;
    if (!event.silent) emit(state.copyWith(status: Status.loading));
    var result = await sl<GetVpnServersUseCase>().call();
    _fetching = false;
    result.fold(
            (error) {
              // A silent refresh that fails keeps the old list on screen.
              if (event.silent && state.vpnServers != null) return;
              emit(state.copyWith(status: Status.error, message: error.message));
              // The third party list could not be loaded: use our own server so the
              // user can still connect.
              if (state.selectedServer == null && state.ownServers.isNotEmpty) {
                emit(state.copyWith(selectedServer: state.ownServers.first));
              }
            },
            (data){
              // Hide servers that failed before and servers without a valid ping.
              var list = data
                  .where((s) => !FailedServers.isFailed(s.ip) &&
                      ServerProbe.knownResult(s.ip) != false &&
                      int.tryParse(s.ping ?? "") != null &&
                      (s.speed ?? 0) > 0)
                  .toList();
              if (list.isEmpty) {
                list = data.where((s) => !FailedServers.isFailed(s.ip)).toList();
              }
              _candidates = list;
              // Show ONLY active servers: the ones that answered the test, and the ones
              // already on screen that were not proven dead (so the list does not blink).
              final shownBefore = (state.vpnServers ?? <VpnServerEntity>[]).map((s) => s.ip).toSet();
              final active = list.where((s) {
                final r = ServerProbe.knownResult(s.ip);
                return r == true || (r == null && shownBefore.contains(s.ip));
              }).toList();
              if (active.isEmpty) {
                // Nothing verified yet: keep the loading animation until the first
                // test results arrive (see _onProbeServers).
                if (!event.silent || (state.vpnServers ?? []).isEmpty) {
                  emit(state.copyWith(status: Status.loading));
                }
              } else {
                emit(state.copyWith(status: Status.success, vpnServers: active));
              }
              // Test the servers in the background and hide the dead ones.
              add(ProbeServers());
            }
    );
  }

  /// Loads the private servers; they are selected by default when you have any.
  Future<void> _onLoadOwnServers(LoadOwnServers event, Emitter<ServersState> emit) async {
    final own = await OwnServersSource.load();
    if (isClosed) return;
    // Our servers are only listed here. The default server comes from the third party
    // list (see _onDefaultServer); our server is used only when that list is not available.
    emit(state.copyWith(ownServers: own));
  }

  /// Sets the default server: the best third party server. When there is none,
  /// the first of our own servers is used.
  void _onDefaultServer(DefaultServer event, Emitter<ServersState> emit){
    if (event.servers.isEmpty) {
      if (state.ownServers.isNotEmpty) {
        emit(state.copyWith(selectedServer: state.ownServers.first));
      }
      return;
    }
    Helpers.sortServerList(event.servers);
    emit(state.copyWith(selectedServer: event.servers.first));
  }

  /// Sets the selected server in the state.
  void _onSelectServer(SelectServer event, Emitter<ServersState> emit){
    emit(state.copyWith(selectedServer: event.server));
  }

  /// Fetches the currently connected server.
  Future<void> _onGetConnectedServer(GetConnectedServer event, Emitter<ServersState> emit) async {
    if(!await VpnService.instance.isConnected()) return;
    var result = await sl<GetConnectedServerUseCase>().call();
    // Only restore the selected server; the servers list status stays untouched.
    result.fold(
            (error)=> null,
            (data){
              // A saved server from a blocked country (see BlockedCountries) is ignored.
              if(data != null &&
                  !BlockedCountries.isBlocked(code: data.countryShort, name: data.countryLong)) {
                emit(state.copyWith(selectedServer: data));
              }
            }
    );
  }

  bool _probing = false;

  /// Tests servers in groups of 25 (best servers first). Only servers that answered
  /// are shown, and they appear in the list as soon as each group is finished.
  Future<void> _onProbeServers(ProbeServers event, Emitter<ServersState> emit) async {
    if (_probing) return;
    // While the VPN is on, the tests would go through the tunnel and be unreliable.
    if (await VpnService.instance.isConnected()) {
      // Cannot test now: make sure the list is not stuck on the loading animation.
      if ((state.vpnServers ?? []).isEmpty && _candidates.isNotEmpty) {
        emit(state.copyWith(status: Status.success, vpnServers: _candidates));
      }
      return;
    }
    _probing = true;
    try {
      final sorted = List<VpnServerEntity>.from(_candidates);
      Helpers.sortServerList(sorted);
      final todo = ServerProbe.pending(sorted);
      for (var i = 0; i < todo.length; i += 25) {
        if (isClosed) return;
        await ServerProbe.probeBatch(todo.skip(i).take(25).toList());
        if (isClosed || emit.isDone) return;
        final current = state.vpnServers ?? <VpnServerEntity>[];
        final alive = sorted.where((s) => ServerProbe.knownResult(s.ip) == true).toList();
        if (alive.isEmpty) continue;
        final sameList = alive.length == current.length &&
            alive.every((s) => current.any((c) => c.ip == s.ip));
        if (sameList && state.status.isSuccess) continue;
        var next = state.selectedServer;
        if (next != null && !next.isOwn && ServerProbe.knownResult(next.ip) == false) {
          next = alive.first;
        }
        emit(ServersState(
          message: state.message,
          status: Status.success,
          selectedServer: next,
          vpnServers: alive,
          ownServers: state.ownServers,
        ));
      }
      // No server answered at all (the phone may be offline or blocks the test):
      // show the downloaded list anyway, so the screen is never empty.
      if (!isClosed && !emit.isDone && (state.vpnServers ?? []).isEmpty && sorted.isNotEmpty) {
        emit(state.copyWith(status: Status.success, vpnServers: sorted));
      }
    } finally {
      _probing = false;
    }
  }

  /// Hides a server that failed to connect and selects the next best one.
  void _onMarkServerFailed(MarkServerFailed event, Emitter<ServersState> emit){
    final failed = event.server;
    if (failed == null) return;
    // Your own servers are never hidden or replaced automatically.
    if (failed.isOwn) return;
    FailedServers.add(failed.ip);
    final remaining = (state.vpnServers ?? <VpnServerEntity>[])
        .where((s) => s.ip != failed.ip)
        .toList();
    var next = state.selectedServer;
    if (next?.ip == failed.ip) {
      Helpers.sortServerList(remaining);
      next = remaining.isNotEmpty ? remaining.first : null;
    }
    emit(ServersState(
      message: state.message,
      status: state.status,
      selectedServer: next,
      vpnServers: remaining,
      ownServers: state.ownServers,
    ));
    // Nothing left to select: use our own server or reload, so Connect keeps working.
    if (next == null) {
      if (state.ownServers.isNotEmpty) {
        emit(state.copyWith(selectedServer: state.ownServers.first));
      } else {
        add(GetVpnServers());
      }
    }
  }

  /// Saves the currently connected server for future sessions.
  Future<void> _onSaveConnectedServer(SaveConnectedServer event, Emitter<ServersState> emit) async {
    var result = await sl<SaveConnectedServerUseCase>().call(params: event.connectServer);
    // Saving is best-effort and must not change the servers list status.
    result.fold((error)=> null, (data)=> null);
  }

}
