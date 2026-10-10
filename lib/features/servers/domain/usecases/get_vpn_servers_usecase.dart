import 'package:dartz/dartz.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/core/usecase/no_params.dart';
import 'package:vpn_master/core/usecase/usecase.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';
import 'package:vpn_master/features/servers/domain/repositories/servers_repositories.dart';

/// A use case for fetching the list of available VPN servers.
class GetVpnServersUseCase extends UseCase<List<VpnServerEntity>, NoParams>{

  /// Executes the use case to get the list of VPN servers from the repository.
  @override
  Future<Either<Failure, List<VpnServerEntity>>> call({NoParams? params}) async =>
      await sl<ServersRepositories>().getVpnServers();

}
