import 'package:dartz/dartz.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/core/usecase/usecase.dart';
import 'package:vpn_master/features/onboarding/domain/repositories/onboarding_repositories.dart';

/// A use case for marking the user as having completed the onboarding process.
class UserOnboardedUseCase extends UseCase<bool,dynamic>{
  /// Executes the use case to set the onboarding status to complete.
  @override
  Future<Either<Failure, bool>> call({params}) async =>
      await sl<OnboardingRepositories>().userIsOnboarded();
}
