import 'package:vpn_master/core/services/monetization/ad_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/constants/monetization_manager.dart';
import 'package:vpn_master/widgets/banner_ad_widget.dart';
import 'package:vpn_master/core/utils/ui_helpers/radius.dart';
import 'package:vpn_master/features/home/presentation/pages/home_page.dart';
import 'package:vpn_master/features/network_info/presentation/pages/network_info_page.dart';
import 'package:vpn_master/features/speed_test/presentation/pages/speed_test_page.dart';

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

    final selected = calculateCurrentIndex();

    // One nav item. Flexible + FittedBox: it can never overflow on small screens.
    Widget navItem(int index, IconData icon, String label) {
      final active = selected == index;
      final color = active ? context.colors.primary : context.colors.textSecondary;
      return Expanded(
        child: InkWell(
          borderRadius: radius12,
          onTap: () => onTap(index),
          child: Container(
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: active ? context.colors.primary.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: radius12,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 24),
                    if (active) ...[
                      const SizedBox(width: 6),
                      Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          // The main page content, provided by the router.
          child,

          // Bottom navigation bar. It hides while the drawer is open so the drawer
          // can use the full screen height.
          ValueListenableBuilder<bool>(
            valueListenable: AdVisibility.drawerOpen,
            builder: (context, drawerOpen, _) => drawerOpen
                ? const SizedBox.shrink()
                : SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: ClipRRect(
                        borderRadius: radius12,
                        child: Container(
                          color: context.colors.secondaryBackground,
                          child: Row(
                            children: [
                              navItem(0, Icons.speed_rounded, "Speed"),
                              navItem(1, Icons.home_rounded, "Home"),
                              navItem(2, Icons.signal_cellular_alt_rounded, "Network"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
