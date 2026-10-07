import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:winsguard/core/helpers/helpers.dart';
import 'package:winsguard/core/utils/extensions/status_extension.dart';
import 'package:winsguard/features/speed_test/presentation/bloc/speed_test_bloc.dart';
import 'package:winsguard/features/speed_test/presentation/widgets/speed_statistic_widget.dart';

/// A widget that displays detailed information about the speed test results,
/// including download, upload, ping, and network quality.
class SpeedInfoWidget extends StatelessWidget {
  const SpeedInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Builds the UI based on the state of the SpeedTestBloc.
    return BlocBuilder<SpeedTestBloc, SpeedTestState>(
      builder: (context, state) {
        return Column(
          children: [

            // Shows a skeleton loader for download/upload stats while the test is in progress.
            Skeletonizer(
              enabled: state.status.isLoading,
              child: Row(
                mainAxisAlignment: .spaceEvenly,
                children: [
                  // Displays download speed.
                  SpeedStatisticWidget(
                      icon: Icons.arrow_downward,
                      title: "DOWNLOAD",
                      speed: (state.downloadSpeed?.transferRate ?? 0).toStringAsFixed(2),
                      unit: state.downloadSpeed?.unit.name ?? "N/A",
                      background: const Color(0xFFD4AF37) // Gold
                  ),
                  // Displays upload speed.
                  SpeedStatisticWidget(
                      icon: Icons.arrow_upward,
                      title: "UPLOAD",
                      speed: (state.uploadSpeed?.transferRate ?? 0).toStringAsFixed(2),
                      unit: state.uploadSpeed?.unit.name ?? "N/A",
                      background: const Color(0xFFD4AF37) // Gold
                  ),
                ],
              ),
            ),

            // Shows a skeleton loader for ping/quality stats until both tests are complete.
            Skeletonizer(
              enabled: !(state.downloadStatus.isSuccess && state.uploadStatus.isSuccess),
              child: Row(
                mainAxisAlignment: .spaceEvenly,
                children: [
                  // Displays ping time.
                  SpeedStatisticWidget(
                      icon: Icons.timer_outlined,
                      title: "PING",
                      speed: (state.ping ?? 0).toString(),
                      unit: "ms",
                      background: const Color(0xFFD4AF37) // Gold
                  ),
                  // Displays the overall network quality score and rating.
                  SpeedStatisticWidget(
                      icon: Icons.network_check,
                      title: "QUALITY",
                      speed: Helpers.calculateNetworkScorePercentage(
                        download: state.downloadSpeed?.transferRate ?? 0,
                        upload:  state.uploadSpeed?.transferRate ?? 0,
                        unit: state.downloadSpeed?.unit.name ?? ""
                      ),
                      unit: Helpers.getNetworkQuality(
                          download: state.downloadSpeed?.transferRate ?? 0,
                          upload:  state.uploadSpeed?.transferRate ?? 0,
                          unit: state.downloadSpeed?.unit.name ?? ""
                      ),
                      background: const Color(0xFFD4AF37) // Gold
                  ),
                ],
              ),
            ),

          ],
        );
      },
    );
  }
}