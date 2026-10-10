import 'package:vpn_master/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:go_router/go_router.dart';
import 'package:vpn_master/config/routes/router_transition.dart';

class OnboardingRouter {
  const OnboardingRouter._();

  static final List<GoRoute> routes = [

    /// Onboarding Page Route
    GoRoute(
      path: OnboardingPage.path,
      name: OnboardingPage.name,
      pageBuilder: (context,state ){
        return CustomTransitionPage<void>(
            key: state.pageKey,
            child: OnboardingPage(),
            transitionsBuilder: routerTransition
        );
      },
    ),

  ];

}