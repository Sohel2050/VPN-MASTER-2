import 'package:go_router/go_router.dart';
import 'package:vpn_master/config/routes/router_transition.dart';
import 'package:vpn_master/features/bottom_navigation/presentation/pages/bottom_navigation_page.dart';
import 'package:vpn_master/features/home/home_routes.dart';
import 'package:vpn_master/features/network_info/network_info_routes.dart';
import 'package:vpn_master/features/speed_test/speed_test_routes.dart';

class BottomNavigationRouter {
  const BottomNavigationRouter._();

  static final List<ShellRoute> routes = [

    /// Bottom Navigation page routes
    ShellRoute(
        pageBuilder: (context, state, child){
          return CustomTransitionPage(
              key: state.pageKey,
              child: BottomNavigationPage(child: child),
              transitionsBuilder: routerTransition
          );
        },
        routes: [

          /// Home Routes
          ...HomeRouter.routes,

          /// Network Info Route
          ...NetworkInfoRouter.routes,

          /// Speed Test Routes
          ...SpeedTestRouter.routes,

        ]
    )

  ];

}