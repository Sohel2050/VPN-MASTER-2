import 'package:dartz/dartz.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/core/usecase/usecase.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';
import 'package:vpn_master/features/servers/domain/repositories/servers_repositories.dart';

/// A use case for saving the currently connected server.
class SaveConnectedServerUseCase extends UseCase<bool, VpnServerEntity>{

  /// Executes the use case to save the connected server.
  @override
  Future<Either<Failure, bool>> call({VpnServerEntity? params}) async =>
      await sl<ServersRepositories>().saveConnectedServer(connectedServer: params!);

}
