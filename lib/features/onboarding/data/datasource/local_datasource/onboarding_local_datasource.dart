import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:vpn_master/core/constants/local_database_keys.dart';
import 'package:vpn_master/core/error/failure.dart';

/// Abstract definition for the local data source of the onboarding feature.
sealed class OnboardingLocalDatasource {
  /// Marks the user as having completed the onboarding process in local storage.
  Future<Either<Failure, bool>> userIsOnboarded();
  /// Checks if the user has already completed the onboarding process from local storage.
  Future<Either<Failure, bool>> alreadyOnboarded();
}

/// Implementation of the [OnboardingLocalDatasource].
class OnboardingLocalDatasourceImpl extends OnboardingLocalDatasource{


  @override
  Future<Either<Failure, bool>> userIsOnboarded() async {
    try{
      // Access the local database box.
      Box box = Hive.box(LocalDatabaseKeys.database);
      // Set the onboarding flag to true.
      box.put(LocalDatabaseKeys.onboard, true);
      log("User viewed onboard.");
      return const Right(true);
    }catch(error,stackTrace){
      log(
          "Onboard Local Datasource",
          error: error,
          stackTrace: stackTrace
      );
      return Left(LocalDatabaseFailure(error.toString()));
    }
  }


  @override
  Future<Either<Failure, bool>> alreadyOnboarded() async {
    try{
      // Access the local database box.
      Box box = Hive.box(LocalDatabaseKeys.database);
      // Retrieve the onboarding flag.
      bool? alreadyOnboarded = box.get(LocalDatabaseKeys.onboard);
      log("Onboarded User");
      // Return the stored value, or false if it's null.
      return Right(alreadyOnboarded ?? false);
    }catch(error,stackTrace){
      log(
          "Onboard Local Datasource",
          error: error,
          stackTrace: stackTrace
      );
      return Left(LocalDatabaseFailure(error.toString()));
    }
  }


}
