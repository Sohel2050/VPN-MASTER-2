import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:winsguard/core/services/monetization/monetization_service.dart';
import 'package:winsguard/core/utils/extensions/vpn_stage_extension.dart';
import 'package:winsguard/features/home/bloc/home_bloc.dart';
import 'package:winsguard/features/home/bloc/home_event.dart';
import 'package:winsguard/features/servers/presentation/bloc/servers_bloc.dart';
import 'package:winsguard/features/servers/presentation/bloc/servers_event.dart';

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
      if(selectedServer != null){
        context.read<HomeBloc>().add(
            ConnectVpn(
              config: selectedServer.openVPNConfig ?? "",
              country: selectedServer.countryLong ?? "",
            )
        );
        serversBloc.add(SaveConnectedServer(connectServer: selectedServer));
      }
    }

    /// Disconnects from the current VPN session.
    void disconnectVpn() async {
      context.read<HomeBloc>().add(DisconnectVpn());
    }

    // Listens for VPN connection state changes to show ads and rebuilds the UI.
    return BlocConsumer<HomeBloc, HomeState>(
      // Shows an interstitial ad only after the VPN disconnects (never while connecting).
      listenWhen: (previous, current) => previous.vpnStage.isConnected && !current.vpnStage.isConnected,
      listener: (context, state) => showInterstitial(),
      builder: (context, state) {
        // A widget that provides a glowing effect around the connection button.
        const gold = Color(0xFFD4AF37);
        const obsidian = Color(0xFF0C0C0E);
        final connected = state.vpnStage.isConnected;
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
            // Toggles between connecting and disconnecting the VPN on tap.
            onTap: () => !connected ? connectVpn() : disconnectVpn(),
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
