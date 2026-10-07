import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:winsguard/common/pages/webview_page.dart';
import 'package:winsguard/core/constants/text_constants.dart';
import 'package:winsguard/core/helpers/helpers.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/styles/app_text_styles.dart';
import 'package:winsguard/core/utils/ui_helpers/paddings.dart';
import 'package:winsguard/core/utils/ui_helpers/radius.dart';
import 'package:winsguard/core/utils/ui_helpers/spacing.dart';
import 'package:winsguard/widgets/drawer/drawer_tile/drawer_option_tile.dart';

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
                decoration: BoxDecoration(
                    borderRadius: radius12,
                    color: context.colors.secondaryBackground,
                    border: Border.all(color: context.colors.primary, width: 0.5),
                ),
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
                            "${appName.value} VPN",
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
                    // Navigates to the Privacy Policy web page.
                    DrawerOptionTile(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      subtitle: "Protecting personal data",
                      onTap: () {
                        Map<String, dynamic> queryParameters = {
                          "title": "Privacy Policy",
                          "url": TextConstants.privacyPolicyUrl
                        };
                        context.pushNamed(WebViewPage.name, queryParameters: queryParameters);
                        Navigator.pop(context);
                      },
                    ),
                    // Navigates to the Terms & Conditions web page.
                    DrawerOptionTile(
                      leadingAsset: "assets/icons/terms_icon.svg",
                      title: "Terms & Conditions",
                      subtitle: "Guidelines for app usage",
                      onTap: () {
                        Map<String, dynamic> queryParameters = {
                          "title": "Terms & Conditions",
                          "url": TextConstants.termsAndConditionUrl
                        };
                        context.pushNamed(WebViewPage.name, queryParameters: queryParameters);
                        Navigator.pop(context);
                      },
                    ),
                    // Navigates to the About Us web page.
                    DrawerOptionTile(
                      leadingAsset: "assets/icons/about_icon.svg",
                      title: "About Us",
                      subtitle: "Learn about this app",
                      onTap: () {
                        Map<String, dynamic> queryParameters = {
                          "title": "About Us",
                          "url": TextConstants.aboutUsUrl
                        };
                        context.pushNamed(WebViewPage.name, queryParameters: queryParameters);
                        Navigator.pop(context);
                      },
                    ),
                    // Opens the native share sheet to share the app.
                    DrawerOptionTile(
                      icon: Icons.share,
                      title: "Share App",
                      subtitle: "Share with friends",
                      onTap: () {
                        if (appName.value != null && packageName.value != null) {
                          String uri = "${TextConstants.playStore}${packageName.value}";
                          SharePlus.instance.share(ShareParams(
                            title: "${appName.value} Vpn - Your Secure Network",
                            subject: "Check out ${appName.value} VPN App!",
                            text: "Check out ${appName.value} VPN, your shield for online privacy. Get it on Google Play: $uri",
                          ));
                        }
                        Navigator.pop(context);
                      },
                    ),
                    // Launches the Play Store for rating the app.
                    DrawerOptionTile(
                      icon: Icons.star_rate_rounded,
                      title: "Rate Us",
                      subtitle: "Share your experience",
                      onTap: () {
                        if (packageName.value != null) {
                          String uri =
                              "${TextConstants.playStore}${packageName.value}";
                          Helpers.launchUri(uri: uri);
                          Navigator.pop(context);
                        }
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
