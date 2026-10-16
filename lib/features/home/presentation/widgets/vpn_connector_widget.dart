import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/helpers/toast_notification/toast_notifications.dart';
import 'package:vpn_master/core/services/monetization/monetization_service.dart';
import 'package:vpn_master/core/services/vpn/vpn_service.dart';
import 'package:vpn_master/core/utils/extensions/vpn_stage_extension.dart';
import 'package:vpn_master/features/home/bloc/home_bloc.dart';
import 'package:vpn_master/features/home/bloc/home_event.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_bloc.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_event.dart';
import 'package:vpn_master/core/utils/extensions/status_extension.dart';

/// True while a connection attempt is in progress (not yet connected, not failed).
bool _isBusyStage(HomeState state) {
  final s = state.vpnStage;
  return s.isConnecting || s.isPrepare || s.isAuthenticating || s.isWaitConnection ||
      s.isTcpConnect || s.isUdpConnect || s.isAssignIp || s.isResolve ||
      s.isGetConfig || s.isVpnGenerateConfig || s.isAuthentication;
}

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

    // How many automatic retries (next server) were made after a failed attempt.
    // 99 means the user cancelled, so no more retries.
    final retries = useRef(0);

    /// Connects to the selected VPN server. [auto] is true for an automatic retry.
    void connectVpn({bool auto = false}) async {
      final serversBloc = context.read<ServersBloc>();
      final homeBloc = context.read<HomeBloc>();
      var selectedServer = serversBloc.state.selectedServer;
      if(selectedServer == null){
        // No server yet: load the list and wait for it, so the tap is never ignored.
        if (!auto) {
          ToastNotifications.showInfoToast(
            title: "Please wait",
            message: "Finding the best server...",
          );
        }
        serversBloc.add(GetVpnServers());
        try {
          await serversBloc.stream
              .firstWhere((s) => s.selectedServer != null || s.status.isError)
              .timeout(const Duration(seconds: 30));
        } catch (_) {}
        selectedServer = serversBloc.state.selectedServer ??
            (serversBloc.state.ownServers.isNotEmpty ? serversBloc.state.ownServers.first : null);
        if(selectedServer == null){
          ToastNotifications.showErrorToast(
            title: "No server available",
            message: "Check your internet connection and tap again.",
          );
          return;
        }
        serversBloc.add(SelectServer(server: selectedServer));
      }
      homeBloc.add(
          ConnectVpn(
            config: selectedServer.activeConfig ?? "",
            country: selectedServer.countryLong ?? "",
            username: selectedServer.username,
            password: selectedServer.password,
            protocol: selectedServer.protocol,
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
      // Interstitial rule: shown (1) when a connection attempt really ended in
      // "connected" and (2) when a connection that was really connected is disconnected.
      // Never on a failed or cancelled attempt.
      listenWhen: (previous, current) =>
          (_isBusyStage(previous) && current.vpnStage.isConnected) ||
          (previous.vpnStage.isConnected && !current.vpnStage.isConnected && !current.connectionFailed) ||
          (!previous.connectionFailed && current.connectionFailed),
      listener: (context, state) {
        if (state.connectionFailed) {
          // This server did not connect: hide it and select the next server.
          final serversBloc = context.read<ServersBloc>();
          final wasOwn = serversBloc.state.selectedServer?.isOwn ?? false;
          serversBloc.add(MarkServerFailed(server: serversBloc.state.selectedServer));
          // Try the next server automatically (up to 3 times), so the user does not
          // have to tap again and again. Our own server is not retried.
          if (!wasOwn && retries.value < 3) {
            retries.value++;
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (context.mounted && retries.value < 99) connectVpn(auto: true);
            });
          }
        } else if (state.vpnStage.isConnected) {
          // Wait a moment, then check that the VPN is still really connected.
          Future.delayed(const Duration(milliseconds: 1500), () async {
            if (!context.mounted) return;
            final stillConnected = context.read<HomeBloc>().state.vpnStage.isConnected &&
                await VpnService.instance.isConnected();
            if (stillConnected) showInterstitial();
          });
        } else {
          // A connection that was really connected has ended.
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
            onTap: () {
              // Instant feedback so the tap never feels ignored.
              HapticFeedback.mediumImpact();
              if (connected || busy) {
                retries.value = 99; // the user cancelled: no automatic retry
                disconnectVpn();
              } else {
                retries.value = 0;
                connectVpn();
              }
            },
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // A spinning ring while connecting.
                    if (busy)
                      SizedBox(
                        width: 136.w,
                        height: 136.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(gold),
                        ),
                      ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          connected ? Icons.verified_user_rounded : Icons.shield_outlined,
                          size: 52.w,
                          color: connected ? obsidian : gold,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          connected
                              ? "TAP TO DISCONNECT"
                              : busy
                                  ? "CONNECTING...\nTAP TO CANCEL"
                                  : "TAP TO CONNECT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: connected ? obsidian : gold,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
