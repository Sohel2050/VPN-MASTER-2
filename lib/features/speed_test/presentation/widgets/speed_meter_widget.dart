import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:winsguard/core/utils/extensions/status_extension.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/styles/app_text_styles.dart';
import 'package:winsguard/core/utils/ui_helpers/spacing.dart';
import 'package:winsguard/features/speed_test/presentation/bloc/speed_test_bloc.dart';

/// A widget that displays a radial gauge to visualize internet speed.
class SpeedMeterWidget extends StatelessWidget {
  const SpeedMeterWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<SpeedTestBloc, SpeedTestState>(
      builder: (context, state) {
        return SizedBox(
          width: 300.w,
          height: 290.w,
          // The main radial gauge widget.
          child: SfRadialGauge(axes: <RadialAxis>[
            RadialAxis(
                minimum: 0,
                maximum: 100,
                showLastLabel: true,
                axisLabelStyle: GaugeTextStyle(
                    color: context.colors.textPrimary),
                // Defines the color ranges for different speed levels.
                ranges: <GaugeRange>[
                  GaugeRange(
                      startValue: 0,
                      endValue: 35,
                      color: const Color(0xFF6B5A1E)
                  ),
                  GaugeRange(
                      startValue: 35,
                      endValue: 70,
                      color: const Color(0xFFA8892B)
                  ),
                  GaugeRange(
                      startValue: 70,
                      endValue: 100,
                      color: const Color(0xFFD4AF37)
                  )
                ],
                // The needle that points to the current speed.
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: state.speed?.transferRate ?? 0,
                    needleColor: const Color(0xFFD4AF37)
                  ),
                ],
                // Annotations to display information on the gauge.
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                      widget: Column(
                        mainAxisAlignment: .center,
                        children: [

                          gap36,

                          // Displays "DOWNLOAD" or "UPLOAD" based on the current test status.
                          Text(
                              state.downloadStatus.isSuccess ? "UPLOAD" : "DOWNLOAD",
                              style: context.titleMedium.copyWith(
                                  fontWeight: .bold,
                                color: state.downloadStatus.isSuccess ?
                                  const Color(0xFFF2EBD8):
                                  const Color(0xFFD4AF37)
                              )
                          ),

                          // Displays the current speed and unit.
                          Text(
                              "${(state.speed?.transferRate ?? 0).toStringAsFixed(2)} ${state.speed?.unit.name ?? "N/A"}",
                              style: context.titleSmall
                          ),
                        ],
                      ),
                      angle: 90,
                      positionFactor: 0.5
                  )
                ]
            )
          ]),
        );
      },
    );
  }
}
