import 'package:go_router/go_router.dart';
import 'package:vpn_master/config/routes/router_transition.dart';
import 'package:vpn_master/features/network_info/presentation/pages/network_info_page.dart';


class NetworkInfoRouter {
  NetworkInfoRouter._();

  static final List<GoRoute> routes = [


    /// NetworkInfo Page Route
    GoRoute(
        path: NetworkInfoPage.path,
        name: NetworkInfoPage.name,
        pageBuilder: (context, state){
          return CustomTransitionPage(
              key: state.pageKey,
              child: NetworkInfoPage(),
              transitionsBuilder: routerTransition
          );
        }
    ),


  ];

}