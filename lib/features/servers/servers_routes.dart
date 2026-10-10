import 'package:go_router/go_router.dart';
import 'package:vpn_master/config/routes/router_transition.dart';
import 'package:vpn_master/features/servers/presentation/page/servers_page.dart';


class ServersRouter {
  ServersRouter._();

  static final List<GoRoute> routes = [

    /// Servers Page Route
    GoRoute(
        path: ServersPage.path,
        name: ServersPage.name,
        pageBuilder: (context, state){
          return CustomTransitionPage(
              key: state.pageKey,
              child: ServersPage(),
              transitionsBuilder: routerTransition
          );
        }
    ),


  ];

}