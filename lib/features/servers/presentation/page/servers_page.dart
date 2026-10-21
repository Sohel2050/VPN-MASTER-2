import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vpn_master/core/helpers/helpers.dart';
import 'package:vpn_master/core/helpers/server_probe.dart';
import 'package:vpn_master/core/helpers/toast_notification/toast_notifications.dart';
import 'package:vpn_master/core/utils/extensions/null_empty_extension.dart';
import 'package:vpn_master/core/utils/extensions/status_extension.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/extensions/vpn_stage_extension.dart';
import 'package:vpn_master/core/utils/ui_helpers/paddings.dart';
import 'package:vpn_master/features/home/bloc/home_bloc.dart';
import 'package:vpn_master/features/home/bloc/home_event.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_bloc.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_event.dart';
import 'package:vpn_master/features/servers/presentation/widgets/item_view/server_item_view.dart';
import 'package:vpn_master/features/servers/presentation/widgets/server_loading_widget.dart';
import 'package:vpn_master/widgets/app_bar/secondary_app_bar.dart';
import 'package:vpn_master/features/servers/presentation/widgets/third_party_server_dialog.dart';
import 'package:vpn_master/widgets/banner_ad_widget.dart';
import 'package:vpn_master/widgets/mrec_ad_widget.dart';
import 'package:vpn_master/widgets/earth_map_widget.dart';
import 'package:vpn_master/widgets/empty_widget.dart';
import 'package:vpn_master/widgets/error_widget/error_widget.dart';

/// Marks an ad row (an MREC ad) between servers.
enum _AdRow { mrec }

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

    // True while a connection started from this page is in progress. The page stays
    // open until the VPN is connected (or every automatic attempt has failed).
    final waiting = useState(false);

    /// Fetches the list of VPN servers.
    void getVpnServers() {
      serversBloc.add(GetVpnServers());
    }

    /// Connects to the selected VPN server.
    void connectVpn(VpnServerEntity vpnServer){

      // Selects and saves the chosen server.
      serversBloc.add(SelectServer(server: vpnServer));
      serversBloc.add(SaveConnectedServer(connectServer: vpnServer));

      // Stay on this page and wait for the result.
      waiting.value = true;
      // Backstop only: the connection attempt itself stops after 15 seconds.
      Future.delayed(const Duration(seconds: 30), () {
        if (context.mounted) waiting.value = false;
      });

      // Disconnects from any existing connection before establishing a new one.
      homeBloc.add(DisconnectVpn());
      // A delay to allow the disconnection to complete before initiating a new connection.
      Future.delayed(const Duration(seconds: 1), () async {
        // Quick check right before connecting: a dead third party server is removed
        // and the user stays on the list to choose another one.
        if (!vpnServer.isOwn) {
          final alive = await ServerProbe.verify(vpnServer);
          if (!alive) {
            waiting.value = false;
            serversBloc.add(MarkServerFailed(server: vpnServer));
            ToastNotifications.showErrorToast(
              title: "Server not responding",
              message: "This server is offline. Please choose another server.",
            );
            return;
          }
        }
        if (!waiting.value) return; // the user pressed Cancel
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

    /// Shows a short "Refreshing" message.
    void showRefreshing(){
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text("Refreshing servers..."),
          duration: Duration(seconds: 1),
        ));
    }

    /// Manual refresh of "Our Servers".
    void refreshOwnServers(){
      showRefreshing();
      serversBloc.add(LoadOwnServers());
    }

    /// Manual refresh of "Third Party Servers".
    void refreshThirdPartyServers(){
      showRefreshing();
      // Forget all old test results: every server is tested again from zero.
      ServerProbe.reset();
      serversBloc.add(GetVpnServers());
    }

    /// A row with the text "Manual refresh" and a Refresh button, shown above each list.
    Widget refreshBar(VoidCallback onRefresh){
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Manual refresh",
                style: TextStyle(color: context.colors.textSecondary, fontSize: 13.sp),
              ),
            ),
            TextButton.icon(
              onPressed: onRefresh,
              icon: Icon(Icons.refresh, size: 18.w),
              label: const Text("Refresh"),
              style: TextButton.styleFrom(foregroundColor: context.colors.primary),
            ),
          ],
        ),
      );
    }

    // Tabs: "Third Party Servers" (volunteer servers, first and opened by default)
    // and "Our Servers" (your own VPS).
    final tabController = useTabController(initialLength: 2, initialIndex: 0);

    /// Mixes MREC ad rows into a server list: after the 3rd, 9th, 15th and 21st server
    /// (at most 4 ads).
    List<Object> withAds(List<VpnServerEntity> servers){
      final rows = <Object>[];
      var adCount = 0;
      for (var i = 0; i < servers.length; i++) {
        rows.add(servers[i]);
        final n = i + 1;
        if (n >= 3 && (n - 3) % 6 == 0 && adCount < 4 && i < servers.length - 1) {
          rows.add(_AdRow.mrec);
          adCount++;
        }
      }
      return rows;
    }

    /// The widget for one ad row.
    Widget adWidget(_AdRow row) => const MrecAdWidget();

    /// Shows the third party warning, then connects when the user accepts.
    Future<void> onThirdPartyTap(VpnServerEntity server) async {
      final accepted = await showThirdPartyServerDialog(context);
      if (accepted && context.mounted) connectVpn(server);
    }

    /// The notice shown above the third party list.
    Widget thirdPartyNotice(){
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.7)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                "These servers are run by independent volunteers (VPN Gate), not by us. They may log or inspect your traffic. Do not use them for banking or passwords. Speed and availability vary.",
                style: TextStyle(color: Colors.orange.shade200, fontSize: 12.sp, height: 1.3),
              ),
            ),
          ],
        ),
      );
    }

    /// The list of your own private servers.
    Widget ownTab(ServersState state){
      final list = state.ownServers;
      if (list.isEmpty) {
        return const EmptyWidget(
          title: "No servers available",
          description: "Please try again later.",
        );
      }
      return RefreshIndicator(
        onRefresh: () async => serversBloc.add(LoadOwnServers()),
        child: Builder(builder: (_) {
          final rows = withAds(list);
          return ListView.builder(
            itemCount: rows.length,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: paddingBottom12,
            itemBuilder: (context, index) {
              final row = rows[index];
              if (row is _AdRow) return adWidget(row);
              final server = row as VpnServerEntity;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => connectVpn(server),
                child: ServerItemView(
                  isOwn: true,
                  isSelected: state.selectedServer?.ip == server.ip,
                  flag: "assets/flags/${server.countryShort?.toLowerCase()}.png",
                  country: server.hostname ?? server.countryLong ?? "Our Server",
                  speed: "",
                  ping: "",
                  users: "",
                ),
              );
            },
          );
        }),
      );
    }

    // The main layout of the page.
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (p, c) =>
          p.vpnStage != c.vpnStage || p.connectionFailed != c.connectionFailed,
      listener: (context, state) {
        if (!waiting.value) return;
        if (state.vpnStage.isConnected) {
          // Connected: go back to the home screen.
          waiting.value = false;
          if (context.canPop()) context.pop();
        } else if (state.connectionFailed) {
          // The server did not connect within 15 seconds: stay on the list and ask the
          // user to choose another server.
          waiting.value = false;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Connection failed"),
              content: const Text("Try another server please."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
      appBar: const SecondaryAppBar(title: "Servers Location"),
      backgroundColor: context.colors.secondaryBackground,
      body: Stack(
        alignment: .center,
        children: [

          // Animated Earth map in the background.
          const EarthMapWidget(alignment: .bottomCenter),

          Column(
            children: [
              // Banner ad below the title and above the tabs.
              const BannerAdWidget(),
              TabBar(
                controller: tabController,
                indicatorColor: context.colors.primary,
                labelColor: context.colors.primary,
                unselectedLabelColor: context.colors.textSecondary,
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: "Third Party Servers"), Tab(text: "Our Servers")],
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    Container(
                  width: 1.sw,
                  height: 1.sh,
                  padding: paddingH12,
                  child: Column(children: [
                    refreshBar(refreshThirdPartyServers),
                    thirdPartyNotice(),
                    Expanded(
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
                            child: Builder(builder: (_) {
                              final rows = withAds(vpnServers);
                              return ListView.builder(
                                itemCount: rows.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: paddingBottom12,
                                itemBuilder: (context, index) {
                                  final row = rows[index];
                                  if (row is _AdRow) return adWidget(row);
                                  final vpnServer = row as VpnServerEntity;

                                  // A tap shows the third party warning first.
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => onThirdPartyTap(vpnServer),
                                    child: ServerItemView(
                                      isThirdParty: true,
                                      isSelected: state.selectedServer?.ip == vpnServer.ip,
                                      flag: "assets/flags/${vpnServer.countryShort?.toLowerCase()}.png",
                                      country: vpnServer.countryLong ?? "N/A",
                                      speed: Helpers.speedFromBitsPerSecond(vpnServer.speed ?? 0),
                                      ping: vpnServer.ping ?? "N/A",
                                      users: (vpnServer.numVpnSessions ?? 0).toString(),
                                    ),
                                  );
                                },
                              );
                            }),
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
                  ]),
                ),
                    BlocBuilder<ServersBloc, ServersState>(
                      builder: (context, state) => Padding(
                        padding: paddingH12,
                        child: Column(
                          children: [
                            refreshBar(refreshOwnServers),
                            Expanded(child: ownTab(state)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),

          // Shown while connecting: the user waits here until connected.
          if (waiting.value)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.65),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text(
                      "Connecting...",
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed: () {
                        waiting.value = false;
                        homeBloc.add(DisconnectVpn());
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ),
            ),

        ],
      ),
      ),
    );
  }
}
