import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vpn_master/features/home/presentation/pages/home_page.dart';
import 'package:vpn_master/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:vpn_master/features/onboarding/presentation/pages/onboarding_page.dart';

/// Displays a splash screen and navigates to the correct page based on onboarding status.
class SplashPage extends HookWidget {
  /// Route path for this page.
  static String get path => "/";
  /// Route name for this page.
  static String get name => "splash";

  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {

    // Navigates to home or onboarding page.
    void checkingOnboard(bool alreadyOnboarded) {
      if(alreadyOnboarded){
        context.go(HomePage.path);
      }else{
        context.go(OnboardingPage.path);
      }
      // Hides the native splash screen.
      FlutterNativeSplash.remove();
    }

    // Navigates when onboarding state changes.
    return BlocListener<OnboardingCubit, bool>(
      listener: (context, state)=> checkingOnboard(state),
      child: Scaffold(
        body: Container(
          width: 1.sw,
          height: 1.sh,
          color: const Color(0xff04123F),
          child: Image.asset(
            "assets/icons/splash_icon.png",
            width: 512.w,
            height: 512.w,
          ),
        ),
      )
    );
  }
}
