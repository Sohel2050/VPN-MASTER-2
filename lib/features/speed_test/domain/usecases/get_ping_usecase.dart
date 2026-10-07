import 'package:dartz/dartz.dart';
import 'package:winsguard/config/service_locator/service_locator.dart';
import 'package:winsguard/core/error/failure.dart';
import 'package:winsguard/core/usecase/no_params.dart';
import 'package:winsguard/core/usecase/usecase.dart';
import 'package:winsguard/features/speed_test/domain/repositoires/speed_test_repositories.dart';

/// A use case for fetching the ping time.
class GetPingUseCase extends UseCase<int, NoParams>{

  /// Executes the use case to get the ping time from the repository.
  @override
  Future<Either<Failure, int>> call({NoParams? params}) async =>
      await sl<SpeedTestRepositories>().getPing();

}
