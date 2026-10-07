import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:winsguard/widgets/app_bar/secondary_app_bar.dart';
import 'package:winsguard/widgets/circle_loading.dart';

/// A page that displays web content from a given URL within a WebView.
class WebViewPage extends HookWidget {

  /// The route path for this page.
  static String get path => "/webview";
  /// The route name for this page.
  static String get name => "webview";

  /// The title displayed in the app bar.
  final String title;
  /// The URL of the web page to load.
  final String url;

  /// Creates a [WebViewPage].
  const WebViewPage({
    super.key,
    required this.title,
    required this.url
  });

  @override
  Widget build(BuildContext context) {

    // Tracks the page loading state.
    final isLoading = useState<bool>(true);
    // Memoizes the controller to avoid re-creating it on each build.
    final webViewController = useMemoized(() => WebViewController());

    // Initializes the WebView controller with the necessary settings.
    void webViewInitializing(){
      webViewController
        ..setBackgroundColor(Colors.white)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => webViewController.clearCache(),
            onProgress: (value){
              // When the page is fully loaded, hide the loading indicator.
              if(value >= 100) isLoading.value = false;
            }
          ),
        )
        ..loadRequest(Uri.parse(url)); // Load the specified URL.
    }

    // Runs the initialization function once when the widget is first built.
    useEffect(() {
      Future.microtask(()=> webViewInitializing());
      return null;
    }, [webViewController]);

    return Scaffold(
      appBar: SecondaryAppBar(title: title),
      body: Visibility(
        // Shows the WebView when loading is complete, otherwise shows a loading circle.
        visible: !isLoading.value,
        replacement: const CircleLoadingWidget(),
        child: WebViewWidget(
          controller: webViewController
        ),
      ),
    );
  }
}
