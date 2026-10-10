import 'package:dartz/dartz.dart';
import 'package:vpn_master/core/error/failure.dart';

/// Abstract definition for the speed test repository.
abstract class SpeedTestRepositories {
  /// Fetches the ping time.
  Future<Either<Failure, int>> getPing();
}
