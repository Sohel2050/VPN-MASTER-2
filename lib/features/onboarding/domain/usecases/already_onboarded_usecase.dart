import 'package:dartz/dartz.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/core/usecase/usecase.dart';
import 'package:vpn_master/features/onboarding/domain/repositories/onboarding_repositories.dart';

/// A use case for checking if the user has already completed the onboarding process.
class AlreadyOnboardedUseCase extends UseCase<bool,dynamic>{
  /// Executes the use case to check the onboarding status.
  @override
  Future<Either<Failure, bool>> call({params}) async =>
      sl<OnboardingRepositories>().alreadyOnboarded();
}
