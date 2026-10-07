import 'package:go_router/go_router.dart';
import 'package:winsguard/config/routes/router_transition.dart';

import 'presentation/pages/splash_page.dart';

class SplashRouter{
  const SplashRouter._();

  static final List<GoRoute> routes = [

    /// Splash Page Route
    GoRoute(
      path: SplashPage.path,
      name: SplashPage.name,
      pageBuilder: (context,state ){
        return CustomTransitionPage<void>(
            key: state.pageKey,
            child: SplashPage(),
            transitionsBuilder: routerTransition
        );
      },
    ),

  ];

}