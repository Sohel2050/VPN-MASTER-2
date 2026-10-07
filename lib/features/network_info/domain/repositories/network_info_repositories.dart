import 'package:dartz/dartz.dart';
import 'package:winsguard/core/error/failure.dart';
import 'package:winsguard/features/network_info/domain/entities/network_info_entity.dart';

/// Abstract definition for the network information repository.
abstract class NetworkInfoRepositories {
  /// Fetches the user's current network information.
  Future<Either<Failure, NetworkInfoEntity>> getNetworkInfo();
}
