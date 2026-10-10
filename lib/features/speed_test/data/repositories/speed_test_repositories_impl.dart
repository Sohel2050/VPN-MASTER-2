import 'package:dartz/dartz.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/features/speed_test/data/datasource/remote_datasource/speed_test_remote_datasource.dart';
import 'package:vpn_master/features/speed_test/domain/repositoires/speed_test_repositories.dart';

/// Implementation of the [SpeedTestRepositories] interface.
class SpeedTestRepositoriesImpl implements SpeedTestRepositories{

  /// Fetches the ping time from the remote data source.
  @override
  Future<Either<Failure, int>> getPing() async =>
      await sl<SpeedTestRemoteDatasource>().getPing();

}
