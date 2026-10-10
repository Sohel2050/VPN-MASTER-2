import 'package:dartz/dartz.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';

/// Abstract definition for the servers repository.
abstract class ServersRepositories {
  /// Fetches the list of available VPN servers.
  Future<Either<Failure, List<VpnServerEntity>>> getVpnServers();
  /// Saves the currently connected server.
  Future<Either<Failure, bool>> saveConnectedServer({required VpnServerEntity connectedServer});
  /// Fetches the currently connected server.
  Future<Either<Failure, VpnServerEntity?>> getConnectedServer();
}
