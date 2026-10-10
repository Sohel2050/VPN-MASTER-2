import 'package:vpn_master/core/constants/monetization_manager.dart';
import 'package:vpn_master/widgets/banner_ad_widget.dart';
import 'package:vpn_master/core/services/monetization/ad_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/ui_helpers/paddings.dart';
import 'package:vpn_master/core/utils/ui_helpers/spacing.dart';
import 'package:vpn_master/features/speed_test/presentation/bloc/speed_test_bloc.dart';
import 'package:vpn_master/features/speed_test/presentation/bloc/speed_test_event.dart';
import 'package:vpn_master/features/speed_test/presentation/widgets/speed_info_widget.dart';
import 'package:vpn_master/features/speed_test/presentation/widgets/speed_meter_widget.dart';
import 'package:vpn_master/widgets/app_bar/primary_app_bar.dart';
import 'package:vpn_master/core/utils/extensions/status_extension.dart';
import 'package:vpn_master/widgets/drawer/customer_drawer.dart';
import 'package:vpn_master/widgets/ad_slot_widget.dart';
import 'package:vpn_master/widgets/earth_map_widget.dart';

/// A page that allows users to test their internet speed, displaying download,
/// upload, and ping information.
class SpeedTestPage extends HookWidget {
  /// The route path for this page.
  static String get path => "/speed-test";
  /// The route name for this page.
  static String get name => "speed-test";

  /// Creates a [SpeedTestPage].
  const SpeedTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    // Dispatches an event to start the speed test.
    void startSpeedTest() async {
      context.read<SpeedTestBloc>().add(StartSpeedTest());
    }


    // Triggers the speed test when the widget is first built.
    useEffect((){
      Future.microtask(()=> startSpeedTest());
      return null;
    },[]);


    return Scaffold(
        drawer: const CustomSideDrawer(),
      onDrawerChanged: (open) => AdVisibility.drawerOpen.value = open,
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Stack(
            alignment: .topCenter,
            children: [
              Column(
                children: [
                  const PrimaryAppBar(),
                // Banner at the top of the page (hidden while the drawer is open).
                if (!MonetizationManager.hideBannerWhenMrec ||
                    !MonetizationManager.isMrecConfigured)
                  const BannerAdWidget(hideWhenDrawerOpen: true),
                  Expanded(
                    child: Container(
                      width: 1.sw,
                      height: 1.sh,
                      padding: padding12,
                      child: Column(
                        children: [
                          // Scrollable so small screens never overflow.
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: 110.h),
                              child: Column(
                                children: [
                                  const SpeedMeterWidget(),
                                  gap20,
                                  const SpeedInfoWidget(),
                                  gap12,
                                  // MREC ad (300x250) shown once the test is finished.
                                  BlocBuilder<SpeedTestBloc, SpeedTestState>(
                                    builder: (context, state) => state.uploadStatus.isSuccess
                                        ? const AdSlotWidget()
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // An animated Earth map displayed in the background.
              const EarthMapWidget()
            ],
          ),
        )
    );
  }
}
