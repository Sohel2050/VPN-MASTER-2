import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:skeletonizer/skeletonizer.dart";
import "package:winsguard/core/utils/extensions/null_empty_extension.dart";
import "package:winsguard/core/utils/extensions/status_extension.dart";
import "package:winsguard/core/utils/extensions/theme_extension.dart";
import "package:winsguard/core/utils/ui_helpers/paddings.dart";
import "package:winsguard/features/network_info/presentation/bloc/network_info_bloc.dart";
import "package:winsguard/features/network_info/presentation/bloc/network_info_event.dart";
import "package:winsguard/features/network_info/presentation/widgets/cards/network_info_card.dart";
import "package:winsguard/widgets/app_bar/primary_app_bar.dart";
import "package:winsguard/widgets/banner_ad_widget.dart";
import "package:winsguard/widgets/drawer/customer_drawer.dart";
import "package:winsguard/widgets/earth_map_widget.dart";
import "package:winsguard/widgets/error_widget/error_widget.dart";

/// A page that displays the user's current network information.
class NetworkInfoPage extends HookWidget {
  /// The route path for this page.
  static String get path => "/network-info";

  /// The route name for this page.
  static String get name => "network-info";

  /// Creates a [NetworkInfoPage].
  const NetworkInfoPage({super.key});

  @override
  Widget build(BuildContext context) {

    // Dispatches an event to fetch network information.
    void getNetworkInfo() {
      context.read<NetworkInfoBloc>().add(GetNetworkInfo());
    }

    // Fetches network info when the widget is first built.
    useEffect(() {
      getNetworkInfo();
      return null;
    }, []);

    return Scaffold(
      drawer: CustomSideDrawer(),
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Stack(
          alignment: .topCenter,
          children: [

            EarthMapWidget(),

            Column(
              children: [
                PrimaryAppBar(),

                Expanded(
                  // Enables pull-to-refresh functionality.
                  child: RefreshIndicator(
                    onRefresh: () async => getNetworkInfo(),
                    color: context.colors.primary,
                    child: SingleChildScrollView(
                      child: Container(
                        width: 1.sw,
                        height: 1.sh,
                        padding: padding12,
                        // Builds the UI based on the network info state.
                        child: BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
                          builder: (context, state) {
                             if (state.status.isLoading || state.networkInfoEntity.isNotNullAndNotEmpty) {

                              final networkInfo = state.networkInfoEntity  ;

                              // Displays a skeleton loading effect while data is being fetched.
                              return Skeletonizer(
                                enabled: state.status.isLoading,
                                child: Column(
                                  spacing: 12.h,
                                  children: [

                                    // Displays Ip Address cards.
                                    NetworkInfoCard(
                                      icon: Icons.location_on_outlined,
                                      title: "IP Address",
                                      subtitle: networkInfo?.query ?? "N/A",
                                      iconColor: context.colors.primary,
                                    ),
                                    // Displays Internet Service Providers ISP.
                                    NetworkInfoCard(
                                      icon: Icons.business,
                                      title: "Internet Provider",
                                      subtitle: networkInfo?.isp ?? "N/A",
                                      iconColor: context.colors.primary,
                                    ),
                                    // Displays Network Location
                                    NetworkInfoCard(
                                      icon: Icons.public,
                                      title: "Location",
                                      subtitle: "${networkInfo?.city ?? "N/A"}, ${networkInfo?.regionName ?? "N/A"}, ${networkInfo?.country ?? "N/A"}",
                                      iconColor: context.colors.primary,
                                    ),
                                    // Displays Location Pin/Zip code
                                    NetworkInfoCard(
                                      icon: Icons.pin_drop_outlined,
                                      title: "Pin Code",
                                      subtitle: networkInfo?.zip ?? "N/A",
                                      iconColor: context.colors.primary,
                                    ),
                                    // Displays Location Time Zone
                                    NetworkInfoCard(
                                      icon: Icons.access_time_rounded,
                                      title: "Timezone",
                                      subtitle: networkInfo?.timezone ?? "N/A",
                                      iconColor: context.colors.primary,
                                    ),

                                    // Showing Banner Ads
                                    BannerAdWidget(),


                                  ],
                                ),
                              );
                            } else {
                              // Displays an error widget if fetching fails.
                              return ApiErrorWidget(
                                errorMessage:
                                    state.message ?? "Something went wrong",
                                onRetry: getNetworkInfo,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
