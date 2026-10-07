import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/styles/app_text_styles.dart';
import 'package:winsguard/core/utils/ui_helpers/paddings.dart';
import 'package:winsguard/core/utils/ui_helpers/spacing.dart';
import 'package:winsguard/features/home/presentation/pages/home_page.dart';
import 'package:winsguard/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:winsguard/widgets/buttons/primary_button.dart';

/// A page that introduces the user to the app and its features for the first time.
class OnboardingPage extends HookWidget {
  /// The route path for this page.
  static String get path => "/onboarding";
  /// The route name for this page.
  static String get name => "onboarding";

  /// Creates an [OnboardingPage].
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {

    final appName = useState<String?>(null);

    /// Marks onboarding as complete and navigates to the home page.
    void completeOnboarding() {
      context.read<OnboardingCubit>().userIsOnboarded();
      context.pushReplacementNamed(HomePage.name);
    }

    void getAppInfo() async {
      final packageInfo = await PackageInfo.fromPlatform();
      appName.value = packageInfo.appName;
    }

    useEffect((){
      getAppInfo();
      return null;
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Container(
          width: 1.sw,
          height: 1.sh,
          padding: padding24,
          child: Column(
            children: [

              gap60,

              // Onboarding illustration.
              Image.asset(
                "assets/images/onboarding_img.png",
                width: 300.w,
                height: 300.w,
              ),

              gap60,

              // Main headline.
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Browse the ",
                      style: context.titleLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          color: context.colors.primary
                      ),
                      children: [
                        TextSpan(
                          text: "Internet with More Privacy and Freedom",
                          style: context.titleLarge.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.colors.textPrimary
                          ),
                        )
                      ]
                  )
              ),

              gap24,

              // Description text.
              Text(
                "${appName.value} VPN keeps your connection private and secure, so you can browse, stream, and connect with total peace of mind.",
                textAlign: TextAlign.center,
                style: context.caption,
              ),

              const Spacer(),

              // Action button to complete onboarding.
              PrimaryButton(
                onPressed: completeOnboarding,
                background: context.colors.primary,
                text: "Let’s Get Started",
              ),

              gap36

            ],
          ),
        ),
      ),
    );
  }
}
