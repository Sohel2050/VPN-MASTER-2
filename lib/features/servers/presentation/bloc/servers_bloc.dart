import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:winsguard/config/service_locator/service_locator.dart';
import 'package:winsguard/core/helpers/helpers.dart';
import 'package:winsguard/core/services/vpn/vpn_service.dart';
import 'package:winsguard/core/utils/enums/enums.dart';
import 'package:winsguard/features/servers/domain/entities/vpn_server_entity.dart';
import 'package:winsguard/features/servers/domain/usecases/get_connected_server_usecase.dart';
import 'package:winsguard/features/servers/domain/usecases/get_vpn_servers_usecase.dart';
import 'package:winsguard/features/servers/domain/usecases/save_connected_server_usecase.dart';
import 'package:winsguard/features/servers/presentation/bloc/servers_event.dart';

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
  }

  /// Handles the [GetVpnServers] event, fetching the list of available VPN servers.
  Future<void> _onGetServers(GetVpnServers event, Emitter<ServersState> emit) async{
    emit(state.copyWith(status: Status.loading));
    var result = await sl<GetVpnServersUseCase>().call();
    result.fold(
            (error) => emit(state.copyWith(
                status: Status.error,
                message: error.message
            )),
            (data){
              emit(state.copyWith(
                  status: Status.success,
                  vpnServers: data,
              ));
            }
    );
  }

  /// Sets the default server from a list of servers.
  void _onDefaultServer(DefaultServer event, Emitter<ServersState> emit){
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
    result.fold(
            (error)=> emit(state.copyWith(status: Status.error, message: error.message)),
            (data)=> emit(state.copyWith(
                status: Status.success,
                selectedServer: data
            ))
    );
  }

  /// Saves the currently connected server for future sessions.
  Future<void> _onSaveConnectedServer(SaveConnectedServer event, Emitter<ServersState> emit) async {
    var result = await sl<SaveConnectedServerUseCase>().call(params: event.connectServer);
    result.fold(
        (error)=> emit(state.copyWith(status: Status.error, message: error.message)),
        (data)=> emit(state.copyWith(status: Status.success))
    );
  }

}
