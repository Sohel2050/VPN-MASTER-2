import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/ui_helpers/paddings.dart';
import 'package:winsguard/core/utils/ui_helpers/radius.dart';
import 'package:winsguard/features/home/presentation/pages/home_page.dart';
import 'package:winsguard/features/network_info/presentation/pages/network_info_page.dart';
import 'package:winsguard/features/speed_test/presentation/pages/speed_test_page.dart';

/// A page that provides a scaffold with a bottom navigation bar.
/// It wraps a child widget which is the content of the current page.
class BottomNavigationPage extends HookWidget {
  /// The widget to display as the main content of the page.
  final Widget child;

  /// Creates a [BottomNavigationPage].
  const BottomNavigationPage({
    super.key,
    required this.child
  });

  @override
  Widget build(BuildContext context) {

    /// Determines the currently selected index of the bottom navigation bar based on the route.
    int calculateCurrentIndex() {
      final location = GoRouter.of(context).state.uri.toString();
      if (location == SpeedTestPage.path) {
        return 0;
      } else if (location == HomePage.path) {
        return 1;
      } else if (location == NetworkInfoPage.path) {
        return 2;
      }
      return 0; // Default index.
    }

    /// Navigates to the corresponding page when a bottom navigation item is tapped.
    void onTap(int index){
      switch (index) {
        case 0:
          context.go(SpeedTestPage.path);
          break;
        case 1:
          context.go(HomePage.path);
          break;
        case 2:
          context.go(NetworkInfoPage.path);
          break;
      }
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          // The main page content, provided by the router.
          child,

          // The bottom navigation bar.
          Padding(
            padding: padding24,
            child: ClipRRect(
              borderRadius: radius12,
              child: BottomBar(
                backgroundColor: context.colors.secondaryBackground,
                selectedIndex: calculateCurrentIndex(),
                onTap: onTap,
                items: <BottomBarItem>[

                  BottomBarItem(
                    icon: const Icon(Icons.speed_rounded),
                    title: const Text("Speed"),
                    activeColor: context.colors.primary,
                  ),
                  BottomBarItem(
                    icon: const Icon(Icons.home_rounded),
                    title: const Text("Home"),
                    activeColor: context.colors.primary,
                  ),
                  BottomBarItem(
                    icon: const Icon(Icons.signal_cellular_alt_rounded),
                    title: const Text("Network"),
                    activeColor: context.colors.primary,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
