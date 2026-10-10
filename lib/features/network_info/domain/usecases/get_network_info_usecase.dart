import 'package:dartz/dartz.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/core/usecase/no_params.dart';
import 'package:vpn_master/core/usecase/usecase.dart';
import 'package:vpn_master/features/network_info/domain/entities/network_info_entity.dart';
import 'package:vpn_master/features/network_info/domain/repositories/network_info_repositories.dart';

/// A use case for fetching the user's current network information.
class GetNetworkInfoUseCase extends UseCase<NetworkInfoEntity, NoParams> {

  /// Executes the use case to get the network information from the repository.
  @override
  Future<Either<Failure, NetworkInfoEntity>> call({NoParams? params}) async =>
      await sl<NetworkInfoRepositories>().getNetworkInfo();


}
