import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vpn_master/core/helpers/helpers.dart';
import 'package:vpn_master/core/utils/extensions/null_empty_extension.dart';
import 'package:vpn_master/core/utils/extensions/status_extension.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/ui_helpers/paddings.dart';
import 'package:vpn_master/features/home/bloc/home_bloc.dart';
import 'package:vpn_master/features/home/bloc/home_event.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_bloc.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_event.dart';
import 'package:vpn_master/features/servers/presentation/widgets/item_view/server_item_view.dart';
import 'package:vpn_master/features/servers/presentation/widgets/server_loading_widget.dart';
import 'package:vpn_master/widgets/app_bar/secondary_app_bar.dart';
import 'package:vpn_master/widgets/ad_slot_widget.dart';
import 'package:vpn_master/widgets/earth_map_widget.dart';
import 'package:vpn_master/widgets/empty_widget.dart';
import 'package:vpn_master/widgets/error_widget/error_widget.dart';

/// A page that displays a list of available VPN servers for the user to select from.
class ServersPage extends HookWidget {

  /// The route path for this page.
  static String get path => "/servers";

  /// The route name for this page.
  static String get name => "servers";

  /// Creates a [ServersPage].
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context) {

    // BLoC instances for managing server and home state.
    final serversBloc = context.read<ServersBloc>();
    final homeBloc = context.read<HomeBloc>();

    /// Fetches the list of VPN servers.
    void getVpnServers() {
      serversBloc.add(GetVpnServers());
    }

    /// Connects to the selected VPN server.
    void connectVpn(VpnServerEntity vpnServer){

      // Selects and saves the chosen server.
      serversBloc.add(SelectServer(server: vpnServer));
      serversBloc.add(SaveConnectedServer(connectServer: vpnServer));

      // Disconnects from any existing connection before establishing a new one.
      homeBloc.add(DisconnectVpn());
      // A delay to allow the disconnection to complete before initiating a new connection.
      Future.delayed(const Duration(seconds: 1),(){
        homeBloc.add(
            ConnectVpn(
              config: vpnServer.activeConfig ?? "",
              country: vpnServer.countryLong ?? "",
              username: vpnServer.username,
              password: vpnServer.password,
              protocol: vpnServer.protocol,
            )
        );
      });

      // Returns to the previous page.
      context.pop();
    }

    // Refreshes the server list as soon as the page opens, then every 10 seconds.
    useEffect((){
      // Empty list: normal load. Otherwise refresh in the background.
      serversBloc.add(GetVpnServers(silent: !serversBloc.state.vpnServers.isNullOrEmpty));
      final timer = Timer.periodic(const Duration(seconds: 10), (_) {
        serversBloc.add(GetVpnServers(silent: true));
      });
      return timer.cancel;
    },[]);

    // Tabs: "My Servers" (your own VPS, first) and "Public" (volunteer servers).
    final tabController = useTabController(
      initialLength: 2,
      initialIndex: serversBloc.state.ownServers.isNotEmpty ? 0 : 1,
    );

    /// The list of your own private servers.
    Widget ownTab(ServersState state){
      final list = state.ownServers;
      if (list.isEmpty) {
        return const EmptyWidget(
          title: "No private servers",
          description: "Add your own servers in own_servers.json",
        );
      }
      return RefreshIndicator(
        onRefresh: () async => serversBloc.add(LoadOwnServers()),
        child: ListView.builder(
          itemCount: list.length,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: paddingBottom12,
          itemBuilder: (context, index) {
            final server = list[index];
            return GestureDetector(
              onTap: () => connectVpn(server),
              child: ServerItemView(
                isOwn: true,
                isSelected: state.selectedServer?.ip == server.ip,
                flag: "assets/flags/${server.countryShort?.toLowerCase()}.png",
                country: server.hostname ?? server.countryLong ?? "Private server",
                speed: "",
                ping: "",
                users: "",
              ),
            );
          },
        ),
      );
    }

    // The main layout of the page.
    return Scaffold(
      appBar: const SecondaryAppBar(title: "Servers Location"),
      backgroundColor: context.colors.secondaryBackground,
      body: Stack(
        alignment: .center,
        children: [

          // Animated Earth map in the background.
          const EarthMapWidget(alignment: .bottomCenter),

          Column(
            children: [
              TabBar(
                controller: tabController,
                indicatorColor: context.colors.primary,
                labelColor: context.colors.primary,
                unselectedLabelColor: context.colors.textSecondary,
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: "My Servers"), Tab(text: "Public")],
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    BlocBuilder<ServersBloc, ServersState>(
                      builder: (context, state) => Padding(
                        padding: paddingH12,
                        child: ownTab(state),
                      ),
                    ),
                    Container(
                  width: 1.sw,
                  height: 1.sh,
                  padding: paddingH12,
                  // Builds the UI based on the state of the ServersBloc.
                  child: BlocBuilder<ServersBloc, ServersState>(
                    builder: (context, state) {
                      // Shows a loading animation while fetching servers.
                      if(state.status.isLoading || state.status.isInitial){
                        return const ServerLoadingWidget();
                      } // If server fetch is successful, display the list.
                      else if(state.status.isSuccess){
                        // If servers are available, show them in a ListView.
                        if(state.vpnServers.isNotNullAndNotEmpty){

                          final vpnServers = state.vpnServers!;

                          // Allows the user to pull-to-refresh the server list.
                          return RefreshIndicator(
                            onRefresh: () async => getVpnServers(),
                            child: ListView.builder(
                                // One extra row for the ad slot after the 3rd server.
                                itemCount: vpnServers.length + (vpnServers.length > 3 ? 1 : 0),
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: paddingBottom12,
                                itemBuilder: (context, index) {

                                  const adIndex = 3;
                                  if (vpnServers.length > 3 && index == adIndex) {
                                    return const AdSlotWidget();
                                  }
                                  final serverIndex = (vpnServers.length > 3 && index > adIndex) ? index - 1 : index;
                                  final vpnServer = vpnServers[serverIndex];

                                  // Handles taps on a server item to initiate connection.
                                  return GestureDetector(
                                    onTap: ()=> connectVpn(vpnServer),
                                    child: ServerItemView(
                                      isSelected: state.selectedServer?.ip == vpnServer.ip,
                                      flag: "assets/flags/${vpnServer.countryShort?.toLowerCase()}.png",
                                      country: vpnServer.countryLong ?? "N/A",
                                      speed: Helpers.speedFromBitsPerSecond(vpnServer.speed ?? 0),
                                      ping: vpnServer.ping ?? "N/A",
                                      users: (vpnServer.numVpnSessions ?? 0).toString(),
                                    ),
                                  );

                                }
                            ),
                          );
                        } // If no servers are found, show an empty state widget.
                        else{
                          return const EmptyWidget(
                              title: "No Servers Found",
                              description: "No servers found in the list"
                          );
                        }

                      }// If there was an error, show an error widget.
                      else{
                        return ApiErrorWidget(
                          errorMessage: state.message ?? "Something went wrong",
                          onRetry: getVpnServers,
                        );
                      }
                    },
                  ),
                ),
                  ],
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }
}
