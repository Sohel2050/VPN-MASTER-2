import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/features/onboarding/domain/usecases/already_onboarded_usecase.dart';
import 'package:vpn_master/features/onboarding/domain/usecases/user_onboarded_usecase.dart';

/// Manages the onboarding state of the application.
class OnboardingCubit extends Cubit<bool>{
  /// Initializes the cubit with an initial state of `false` (not onboarded).
  OnboardingCubit(): super(false);

  /// Marks the user as having completed the onboarding process.
  Future<void> userIsOnboarded() async {
    var result = await sl<UserOnboardedUseCase>().call();
    result.fold(
            (error)=> emit(false),
            (data)=> emit(data)
    );
  }


  /// Checks if the user has already completed the onboarding process.
  Future<void> userAlreadyOnboarded() async {
    var result = await sl<AlreadyOnboardedUseCase>().call();
    result.fold(
            (error)=> emit(false),
            (data)=> emit(data)
    );
  }


}
