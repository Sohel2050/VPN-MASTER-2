import 'package:dartz/dartz.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/features/servers/data/datasource/local_datasource/servers_local_datasource.dart';
import 'package:vpn_master/features/servers/data/datasource/remote_datasource/servers_remote_datasource.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';
import 'package:vpn_master/features/servers/domain/repositories/servers_repositories.dart';

/// Implementation of the [ServersRepositories] interface.
class ServersRepositoriesImpl implements ServersRepositories {
  /// Fetches the list of available VPN servers from the remote data source.
  @override
  Future<Either<Failure, List<VpnServerEntity>>> getVpnServers() async =>
      await sl<ServersRemoteDatasource>().getVpnServers();

  /// Fetches the currently connected server from the local data source.
  @override
  Future<Either<Failure, VpnServerEntity?>> getConnectedServer() async =>
      await sl<ServersLocalDatasource>().getConnectedServer();

  /// Saves the currently connected server to the local data source.
  @override
  Future<Either<Failure, bool>> saveConnectedServer(
          {required VpnServerEntity connectedServer}) async =>
      await sl<ServersLocalDatasource>()
          .saveConnectedServer(connectedServer: connectedServer);
}
