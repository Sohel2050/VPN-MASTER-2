import 'package:dartz/dartz.dart';
import 'package:winsguard/config/service_locator/service_locator.dart';
import 'package:winsguard/core/error/failure.dart';
import 'package:winsguard/features/network_info/data/datasource/remote_datasource/network_info_remote_datasource.dart';
import 'package:winsguard/features/network_info/domain/entities/network_info_entity.dart';
import 'package:winsguard/features/network_info/domain/repositories/network_info_repositories.dart';

/// Implementation of the [NetworkInfoRepositories] interface.
class NetworkInfoRepositoriesImpl implements NetworkInfoRepositories {
  /// Fetches the user's current network information from the remote data source.
  @override
  Future<Either<Failure, NetworkInfoEntity>> getNetworkInfo() async =>
      await sl<NetworkInfoRemoteDatasource>().getNetworkInfo();
}
