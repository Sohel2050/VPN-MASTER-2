import 'package:go_router/go_router.dart';
import 'package:winsguard/common/pages/webview_page.dart';
import 'package:winsguard/config/routes/router_transition.dart';


class CommonRouter {
  CommonRouter._();

  static final List<GoRoute> routes = [

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