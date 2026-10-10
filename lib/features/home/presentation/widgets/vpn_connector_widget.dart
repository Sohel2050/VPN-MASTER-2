import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/helpers/toast_notification/toast_notifications.dart';
import 'package:vpn_master/core/services/monetization/monetization_service.dart';
import 'package:vpn_master/core/utils/extensions/vpn_stage_extension.dart';
import 'package:vpn_master/features/home/bloc/home_bloc.dart';
import 'package:vpn_master/features/home/bloc/home_event.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_bloc.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_event.dart';

/// A widget that displays the main VPN connection button and handles connection logic.
class VpnConnectorWidget extends HookWidget {
  /// Creates a [VpnConnectorWidget].
  const VpnConnectorWidget({super.key});

  @override
  Widget build(BuildContext context) {

    /// Shows an interstitial ad (Unity LevelPlay) if one is ready.
    void showInterstitial(){
      MonetizationService.showInterstitial();
    }

    /// Connects to the selected VPN server.
    void connectVpn() async {
      final serversBloc = context.read<ServersBloc>();
      final selectedServer = serversBloc.state.selectedServer;
      if(selectedServer == null){
        // No server yet (list not loaded): tell the user and try loading again.
        ToastNotifications.showErrorToast(
          title: "No server selected",
          message: "Loading servers, please try again in a moment.",
        );
        serversBloc.add(GetVpnServers());
        return;
      }
      context.read<HomeBloc>().add(
          ConnectVpn(
            config: selectedServer.openVPNConfig ?? "",
            country: selectedServer.countryLong ?? "",
          )
      );
      serversBloc.add(SaveConnectedServer(connectServer: selectedServer));
    }

    /// Disconnects from the current VPN session.
    void disconnectVpn() async {
      context.read<HomeBloc>().add(DisconnectVpn());
    }

    // Listens for VPN connection state changes to show ads and rebuilds the UI.
    return BlocConsumer<HomeBloc, HomeState>(
      // Shows an interstitial ad only after the VPN disconnects (never while connecting).
      listenWhen: (previous, current) =>
          (previous.vpnStage.isConnected && !current.vpnStage.isConnected) ||
          (!previous.connectionFailed && current.connectionFailed),
      listener: (context, state) {
        if (state.connectionFailed) {
          // This server did not connect: hide it and select the next server.
          final serversBloc = context.read<ServersBloc>();
          serversBloc.add(MarkServerFailed(server: serversBloc.state.selectedServer));
        } else {
          showInterstitial();
        }
      },
      builder: (context, state) {
        // A widget that provides a glowing effect around the connection button.
        const gold = Color(0xFFD4AF37);
        const obsidian = Color(0xFF0C0C0E);
        final connected = state.vpnStage.isConnected;
        // While connecting, a tap cancels the attempt.
        final busy = state.vpnStage.isConnecting || state.vpnStage.isPrepare ||
            state.vpnStage.isAuthenticating || state.vpnStage.isWaitConnection ||
            state.vpnStage.isTcpConnect || state.vpnStage.isUdpConnect ||
            state.vpnStage.isAssignIp || state.vpnStage.isResolve ||
            state.vpnStage.isGetConfig || state.vpnStage.isVpnGenerateConfig ||
            state.vpnStage.isAuthentication;
        // Soft gold glow around the connection button.
        return AvatarGlow(
          animate: true,
          startDelay: const Duration(milliseconds: 500),
          glowColor: gold,
          glowShape: BoxShape.circle,
          curve: Curves.fastOutSlowIn,
          glowRadiusFactor: 0.25,
          glowCount: 2,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Toggles between connecting and disconnecting the VPN on tap.
            onTap: () => (connected || busy) ? disconnectVpn() : connectVpn(),
            // Outer thin gold ring.
            child: Container(
              width: 170.w,
              height: 170.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 1.5),
              ),
              // Inner button: dark when disconnected, solid gold when secured.
              child: Container(
                width: 136.w,
                height: 136.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: connected ? gold : const Color(0xFF17150F),
                  border: Border.all(
                    color: connected ? gold : const Color(0xFF3A3220),
                  ),
                ),
                child: Icon(
                  connected ? Icons.verified_user_rounded : Icons.shield_outlined,
                  size: 64.w,
                  color: connected ? obsidian : gold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
