import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:winsguard/core/services/app_update/app_update_service.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/ui_helpers/paddings.dart';
import 'package:winsguard/core/utils/ui_helpers/spacing.dart';
import 'package:winsguard/features/home/bloc/home_bloc.dart';
import 'package:winsguard/features/home/bloc/home_event.dart';
import 'package:winsguard/features/home/presentation/widgets/connection_info_widget.dart';
import 'package:winsguard/features/home/presentation/widgets/connection_timer_widget.dart';
import 'package:winsguard/features/home/presentation/widgets/selected_server_widget.dart';
import 'package:winsguard/features/home/presentation/widgets/vpn_connector_widget.dart';
import 'package:winsguard/features/servers/presentation/bloc/servers_bloc.dart';
import 'package:winsguard/features/servers/presentation/bloc/servers_event.dart';
import 'package:winsguard/widgets/app_bar/primary_app_bar.dart';
import 'package:winsguard/widgets/banner_ad_widget.dart';
import 'package:winsguard/widgets/drawer/customer_drawer.dart';
import 'package:winsguard/widgets/earth_map_widget.dart';

/// The main home screen of the application, displaying VPN connection controls and status.
class HomePage extends HookWidget {
  /// The route path for this page.
  static String get path => "/home";
  /// The route name for this page.
  static String get name => "home";

  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    /// Fetches the list of VPN servers if no server is currently selected.
    void getServers(){
      if(context.read<ServersBloc>().state.selectedServer == null){
        context.read<ServersBloc>().add(GetVpnServers());
      }
    }

    /// Initializes listeners and fetches initial data when the widget is first built.
    useEffect((){
      getServers();
      context.read<HomeBloc>().add(StartVpnTracking());
      // Checks the remote update_config.json (force / optional update).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) AppUpdateService.check(context);
      });
      return null;
    },[]);

    return Scaffold(
      drawer: CustomSideDrawer(),
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Stack(
          alignment: .center,
          children: [

            // Animated Earth map background.
            EarthMapWidget(alignment: .center),

            Column(
              children: [

                const PrimaryAppBar(),

                Expanded(
                  child: Container(
                    width: 1.sw,
                    height: 1.sh,
                    padding: paddingH24,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: .center,
                        children: [

                          gap36,
                          // Displays the currently selected server.
                          const SelectedServerWidget(),
                          gap24,
                          // Shows the connection timer and status.
                          const ConnectionTimerWidget(),
                          gap72,
                          // The main button for connecting/disconnecting the VPN.
                          const VpnConnectorWidget(),
                          gap72,
                          // Displays connection statistics (download/upload/ping).
                          ConnectionInfoWidget(),
                          gap24,
                          // Banner ad, kept away from the connect button.
                          const BannerAdWidget(),
                          // Leaves room for the floating bottom navigation bar.
                          SizedBox(height: 100.h),

                        ],
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
