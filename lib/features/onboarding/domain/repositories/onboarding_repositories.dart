import 'package:dartz/dartz.dart';
import 'package:vpn_master/core/error/failure.dart';

/// Abstract definition for the onboarding repository.
abstract class OnboardingRepositories {
  /// Checks if the user has already completed the onboarding process.
  Future<Either<Failure, bool>> alreadyOnboarded();
  /// Marks the user as having completed the onboarding process.
  Future<Either<Failure, bool>> userIsOnboarded();
}
