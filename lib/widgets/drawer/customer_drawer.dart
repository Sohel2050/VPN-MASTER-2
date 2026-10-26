import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vpn_master/common/pages/legal_page.dart';
import 'package:vpn_master/core/constants/text_constants.dart';
import 'package:vpn_master/core/helpers/helpers.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/styles/app_text_styles.dart';
import 'package:vpn_master/core/utils/ui_helpers/paddings.dart';
import 'package:vpn_master/core/utils/ui_helpers/neon.dart';
import 'package:vpn_master/core/utils/ui_helpers/radius.dart';
import 'package:vpn_master/core/utils/ui_helpers/spacing.dart';
import 'package:vpn_master/widgets/drawer/drawer_tile/drawer_option_tile.dart';

// The main navigation drawer for the application.
class CustomSideDrawer extends HookWidget {
  // Creates a [CustomSideDrawer].
  const CustomSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    // State for holding application package information.
    final appName = useState<String?>(null);
    final projectVersion = useState<String?>(null);
    final packageName = useState<String?>(null);

    // Loads package information from the platform.
    Future<void> getAppInfo() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appName.value = packageInfo.appName;
      projectVersion.value = packageInfo.version;
      packageName.value = packageInfo.packageName;
    }

    // Fetches package info when the widget is initialized.
    useEffect(() {
      getAppInfo();
      return null;
    }, []);

    // Defines the overall structure and appearance of the drawer.
    // Full height drawer (the banner and the navigation bar hide while it is open).
    return Drawer(
      backgroundColor: context.colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: .only(
          topRight: .circular(20.r),
          bottomRight: .circular(20.r),
        ),
      ),
      shadowColor: Colors.black,
      child: SafeArea(
        child: Container(
          width: 1.sw * 0.75, // Drawer width is 75% of the screen.
          padding: padding20,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              // --- Drawer Header ---
              // Displays the app logo, name, and tagline.
              Container(
                width: 1.sw,
                height: 100.h,
                padding: padding18,
                decoration: neonDecoration(context),
                child: Row(
                  crossAxisAlignment: .center,
                  children: [
                    ClipRRect(
                      borderRadius: radius16,
                      child: Image.asset(
                        "assets/images/app_logo.png",
                        width: 50.w,
                      ),
                    ),
                    gap12,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            appName.value ?? "VPN Master",
                            maxLines: 2,
                            overflow: .ellipsis,
                            style: context.titleMedium.copyWith(
                                color: context.colors.primary
                            ),
                          ),
                          Text(
                            "Your Secure Network",
                            style: context.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              gap20,

              // --- Drawer Options ---
              // A scrollable list of actions.
              Expanded(
                child: ListView(
                  children: [
                    gap12,
                    // Opens the developer page on Google Play to show more apps.
                    DrawerOptionTile(
                      icon: Icons.apps_rounded,
                      title: "More Apps",
                      subtitle: "Discover our other apps",
                      onTap: () {
                        Navigator.pop(context);
                        Helpers.launchUri(uri: TextConstants.moreAppsUrl);
                      },
                    ),
                    // Opens the in-app Privacy Policy.
                    DrawerOptionTile(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      subtitle: "Protecting personal data",
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(
                          LegalPage.name,
                          queryParameters: {"type": "privacy"},
                        );
                      },
                    ),
                    // Opens the in-app Terms & Conditions.
                    DrawerOptionTile(
                      leadingAsset: "assets/icons/terms_icon.svg",
                      title: "Terms & Conditions",
                      subtitle: "Guidelines for app usage",
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(
                          LegalPage.name,
                          queryParameters: {"type": "terms"},
                        );
                      },
                    ),
                    // Opens the native share sheet to share the app.
                    DrawerOptionTile(
                      icon: Icons.share,
                      title: "Share App",
                      subtitle: "Share with friends",
                      onTap: () {
                        final name = appName.value ?? "VPN Master";
                        final uri = "${TextConstants.playStore}${packageName.value ?? "com.albonik.vpnapp"}";
                        Navigator.pop(context);
                        SharePlus.instance.share(ShareParams(
                          title: "$name - Your Secure Network",
                          subject: "Check out $name App!",
                          text: "Check out $name, your shield for online privacy. Get it on Google Play: $uri",
                        ));
                      },
                    ),
                    // Launches the Play Store for rating the app.
                    DrawerOptionTile(
                      icon: Icons.star_rate_rounded,
                      title: "Rate Us",
                      subtitle: "Share your experience",
                      onTap: () {
                        final uri =
                            "${TextConstants.playStore}${packageName.value ?? "com.albonik.vpnapp"}";
                        Navigator.pop(context);
                        Helpers.launchUri(uri: uri);
                      },
                    ),
                    gap24,
                    // Displays the current application version.
                    Text(
                      "Version\n${projectVersion.value ?? "0.0.0"}",
                      textAlign: .center,
                      style: context.caption,
                    ),
                    gap48,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
