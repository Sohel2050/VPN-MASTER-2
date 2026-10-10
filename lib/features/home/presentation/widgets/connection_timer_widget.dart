import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/extensions/vpn_stage_extension.dart';
import 'package:vpn_master/core/utils/styles/app_text_styles.dart';
import 'package:vpn_master/features/home/bloc/home_bloc.dart';

/// A widget that displays the VPN connection duration and the current connection stage.
class ConnectionTimerWidget extends StatelessWidget {
  /// Creates a [ConnectionTimerWidget].
  const ConnectionTimerWidget({super.key});

  /// Short, simple status: Connecting until it is Connected or Failed.
  String _label(HomeState state) {
    final stage = state.vpnStage;
    if (stage.isConnected) return "Connected";
    if (state.connectionFailed) return "Failed";
    if (stage.isDisconnecting) return "Disconnecting";
    if (stage.isPrepare || stage.isAuthenticating || stage.isConnecting ||
        stage.isAuthentication || stage.isWaitConnection || stage.isVpnGenerateConfig ||
        stage.isGetConfig || stage.isTcpConnect || stage.isUdpConnect ||
        stage.isAssignIp || stage.isResolve) {
      return "Connecting";
    }
    return "Not connected";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Column(
          children: [
            // Displays the connection timer.
            Text(
              state.vpnStatus?.duration ?? "00:00:00",
              style: context.headlineLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            // Displays the current VPN connection stage (e.g., "Connecting", "Connected").
            Text(
              _label(state).toUpperCase(),
              style: context.caption.copyWith(
                letterSpacing: 2,
                color: context.colors.primary,
              ),
            ),
          ],
        );
      },
    );
  }
}
