import 'package:go_router/go_router.dart';
import 'package:vpn_master/config/routes/router_transition.dart';
import 'package:vpn_master/features/home/presentation/pages/home_page.dart';


class HomeRouter {
  HomeRouter._();

  static final List<GoRoute> routes = [


    /// Home Page Route
    GoRoute(
        path: HomePage.path,
        name: HomePage.name,
        pageBuilder: (context, state){
          return CustomTransitionPage(
              key: state.pageKey,
              child: HomePage(),
              transitionsBuilder: routerTransition
          );
        },
    ),



  ];

}