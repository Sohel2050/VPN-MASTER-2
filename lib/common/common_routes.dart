import 'package:go_router/go_router.dart';
import 'package:vpn_master/common/pages/legal_page.dart';
import 'package:vpn_master/common/pages/webview_page.dart';
import 'package:vpn_master/config/routes/router_transition.dart';


class CommonRouter {
  CommonRouter._();

  static final List<GoRoute> routes = [

    /// Legal (Privacy Policy / Terms & Conditions) Page Route
    GoRoute(
        path: LegalPage.path,
        name: LegalPage.name,
        pageBuilder: (context, state){
          return CustomTransitionPage(
              key: state.pageKey,
              child: LegalPage(
                type: LegalPage.typeFromQuery(state.uri.queryParameters["type"]),
              ),
              transitionsBuilder: routerTransition
          );
        }
    ),

    /// Webview Page Route
    GoRoute(
        path: WebViewPage.path,
        name: WebViewPage.name,
        pageBuilder: (context, state){
          return CustomTransitionPage(
              key: state.pageKey,
              child: WebViewPage(
                title: state.uri.queryParameters["title"] ?? "",
                url: state.uri.queryParameters["url"] ?? "",
              ),
              transitionsBuilder: routerTransition
          );
        }
    ),


  ];

}