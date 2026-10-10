import 'package:dartz/dartz.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/core/usecase/no_params.dart';
import 'package:vpn_master/core/usecase/usecase.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';
import 'package:vpn_master/features/servers/domain/repositories/servers_repositories.dart';

/// A use case for fetching the currently connected server.
class GetConnectedServerUseCase extends UseCase<VpnServerEntity?, NoParams>{

  /// Executes the use case to get the connected server from the repository.
  @override
  Future<Either<Failure, VpnServerEntity?>> call({NoParams? params}) async =>
      await sl<ServersRepositories>().getConnectedServer();

}
