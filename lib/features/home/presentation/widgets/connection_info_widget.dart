import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn_master/core/helpers/helpers.dart';
import 'package:vpn_master/features/home/bloc/home_bloc.dart';
import 'package:vpn_master/features/home/presentation/widgets/connection_statistic_widget.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_bloc.dart';

import '../../../../core/utils/styles/app_colors.dart';

/// A widget that displays real-time connection statistics like download, upload, and ping.
class ConnectionInfoWidget extends StatelessWidget {
  /// Creates a [ConnectionInfoWidget].
  const ConnectionInfoWidget({super.key});

  Widget _tile(Widget child) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Row(
          children: [
            // Displays the current download speed.
            _tile(ConnectionStatisticWidget(
              title: "Download",
              value: Helpers.speedFromBitsPerSecond(
                  int.tryParse(state.vpnStatus?.byteIn ?? "0") ?? 0),
              icon: Icons.arrow_downward_rounded,
              backgroundColor: AppColors.primaryColor,
            )),
            // Displays the current upload speed.
            _tile(ConnectionStatisticWidget(
              title: "Upload",
              value: Helpers.speedFromBitsPerSecond(
                  int.tryParse(state.vpnStatus?.byteOut ?? "0") ?? 0),
              icon: Icons.arrow_upward_rounded,
              backgroundColor: AppColors.greenColor,
            )),
            // Selects the currently chosen server from the ServersBloc to display its ping.
            BlocSelector<ServersBloc, ServersState, VpnServerEntity?>(
              selector: (state) => state.selectedServer,
              builder: (context, vpnServer) {
                return _tile(ConnectionStatisticWidget(
                  title: "Ping",
                  value: "${vpnServer?.ping ?? "0"} Ms",
                  icon: Icons.bar_chart_rounded,
                  backgroundColor: AppColors.deepOrange,
                ));
              },
            ),
          ],
        );
      },
    );
  }
}
