import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:vpn_master/config/service_locator/service_locator.dart";
import "package:vpn_master/core/utils/enums/enums.dart";
import "package:vpn_master/features/network_info/domain/entities/network_info_entity.dart";
import "package:vpn_master/features/network_info/domain/usecases/get_network_info_usecase.dart";
import "package:vpn_master/features/network_info/presentation/bloc/network_info_event.dart";

part "network_info_state.dart";

/// Handles the business logic for the network information feature.
class NetworkInfoBloc extends Bloc<NetworkInfoEvent, NetworkInfoState> {
  /// Initializes the BLoC and registers event handlers.
  NetworkInfoBloc() : super(NetworkInfoState.initial()) {
    on<GetNetworkInfo>(_onGetNetworkInfo);
  }

  /// Handles the [GetNetworkInfo] event by fetching network information from the use case.
  Future<void> _onGetNetworkInfo(GetNetworkInfo event, Emitter<NetworkInfoState> emit) async {
    emit(state.copyWith(status: Status.loading));
    final result = await sl<GetNetworkInfoUseCase>().call();
    result.fold(
      (error) => emit(state.copyWith(
        status: Status.error,
        message: error.message
      )),
      (data) => emit(state.copyWith(
        status: Status.success,
        networkInfoEntity: data
      ))
    );
  }
}
