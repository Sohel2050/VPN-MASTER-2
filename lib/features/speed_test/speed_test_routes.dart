import 'package:go_router/go_router.dart';
import 'package:winsguard/config/routes/router_transition.dart';
import 'package:winsguard/features/speed_test/presentation/pages/speed_test_page.dart';


class SpeedTestRouter {
  SpeedTestRouter._();

  static final List<GoRoute> routes = [

    /// Speed Test Page Route
    GoRoute(
        path: SpeedTestPage.path,
        name: SpeedTestPage.name,
        pageBuilder: (context, state){
          return CustomTransitionPage(
              key: state.pageKey,
              child: SpeedTestPage(),
              transitionsBuilder: routerTransition
          );
        }
    ),


  ];

}