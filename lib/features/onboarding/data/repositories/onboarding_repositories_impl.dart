import 'package:dartz/dartz.dart';
import 'package:winsguard/config/service_locator/service_locator.dart';
import 'package:winsguard/core/error/failure.dart';
import 'package:winsguard/features/onboarding/data/datasource/local_datasource/onboarding_local_datasource.dart';
import 'package:winsguard/features/onboarding/domain/repositories/onboarding_repositories.dart';

/// Implementation of the [OnboardingRepositories] interface.
class OnboardingRepositoriesImpl implements OnboardingRepositories{

  /// Marks the user as having completed the onboarding process.
  @override
  Future<Either<Failure, bool>> userIsOnboarded() async =>
      await sl<OnboardingLocalDatasource>().userIsOnboarded();

  /// Checks if the user has already completed the onboarding process.
  @override
  Future<Either<Failure, bool>> alreadyOnboarded() async =>
      await sl<OnboardingLocalDatasource>().alreadyOnboarded();

}
