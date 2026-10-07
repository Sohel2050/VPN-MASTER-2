import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/extensions/vpn_stage_extension.dart';
import 'package:winsguard/core/utils/styles/app_text_styles.dart';
import 'package:winsguard/features/home/bloc/home_bloc.dart';

/// A widget that displays the VPN connection duration and the current connection stage.
class ConnectionTimerWidget extends StatelessWidget {
  /// Creates a [ConnectionTimerWidget].
  const ConnectionTimerWidget({super.key});

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
              (state.vpnStage?.toName ?? "Not Connected").toUpperCase(),
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
