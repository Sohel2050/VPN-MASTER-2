import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/helpers/blocked_countries.dart';
import 'package:vpn_master/core/helpers/failed_servers.dart';
import 'package:vpn_master/core/helpers/helpers.dart';
import 'package:vpn_master/core/helpers/server_probe.dart';
import 'package:vpn_master/core/services/vpn/vpn_service.dart';
import 'package:vpn_master/core/utils/enums/enums.dart';
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
              emit(state.copyWith(
                  status: Status.success,
                  vpnServers: list,
              ));
              // Test the servers in the background and hide the dead ones.
              add(ProbeServers());
            }
    );
  }

  /// Loads the private servers; they are selected by default when you have any.
  Future<void> _onLoadOwnServers(LoadOwnServers event, Emitter<ServersState> emit) async {
    final own = await OwnServersSource.load();
    if (isClosed) return;
    emit(state.copyWith(ownServers: own));
    if (state.selectedServer == null && own.isNotEmpty) {
      emit(state.copyWith(selectedServer: own.first));
    }
  }

  /// Sets the default server from a list of servers (your own server first).
  void _onDefaultServer(DefaultServer event, Emitter<ServersState> emit){
    if (state.ownServers.isNotEmpty) {
      emit(state.copyWith(selectedServer: state.ownServers.first));
      return;
    }
    if (event.servers.isEmpty) return;
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

  /// Tests servers in groups of 25 (best servers first) and removes dead ones.
  Future<void> _onProbeServers(ProbeServers event, Emitter<ServersState> emit) async {
    if (_probing) return;
    // While the VPN is on, the tests would go through the tunnel and be unreliable.
    if (await VpnService.instance.isConnected()) return;
    _probing = true;
    try {
      final sorted = List<VpnServerEntity>.from(state.vpnServers ?? []);
      Helpers.sortServerList(sorted);
      final todo = ServerProbe.pending(sorted);
      for (var i = 0; i < todo.length; i += 25) {
        if (isClosed) return;
        await ServerProbe.probeBatch(todo.skip(i).take(25).toList());
        if (isClosed || emit.isDone) return;
        final current = state.vpnServers ?? <VpnServerEntity>[];
        final alive = current.where((s) => ServerProbe.knownResult(s.ip) != false).toList();
        // Never empty the list (for example when the network blocks every probe).
        if (alive.isEmpty || alive.length == current.length) continue;
        var next = state.selectedServer;
        if (next != null && ServerProbe.knownResult(next.ip) == false) {
          Helpers.sortServerList(alive);
          next = alive.first;
        }
        emit(ServersState(
          message: state.message,
          status: state.status,
          selectedServer: next,
          vpnServers: alive,
          ownServers: state.ownServers,
        ));
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
  }

  /// Saves the currently connected server for future sessions.
  Future<void> _onSaveConnectedServer(SaveConnectedServer event, Emitter<ServersState> emit) async {
    var result = await sl<SaveConnectedServerUseCase>().call(params: event.connectServer);
    // Saving is best-effort and must not change the servers list status.
    result.fold((error)=> null, (data)=> null);
  }

}
