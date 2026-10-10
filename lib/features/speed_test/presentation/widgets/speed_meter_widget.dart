import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:vpn_master/core/utils/extensions/status_extension.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/styles/app_text_styles.dart';
import 'package:vpn_master/core/utils/ui_helpers/neon.dart';
import 'package:vpn_master/features/speed_test/presentation/bloc/speed_test_bloc.dart';
import 'package:vpn_master/features/speed_test/presentation/bloc/speed_test_event.dart';

/// The speed test hero: a glowing gauge with a gradient arc, a moving dot and a big
/// live speed number, with the current phase and a "Test again" button below.
class SpeedMeterWidget extends StatelessWidget {
  const SpeedMeterWidget({super.key});

  static const gold = Color(0xFFFFC21A);
  static const orange = Color(0xFFFF7A18);
  static const red = Color(0xFFFF3D3D);

  /// The gauge scale grows with the speed so the arc never looks empty or full.
  static double _scaleFor(double rate) {
    if (rate <= 10) return 10;
    if (rate <= 50) return 50;
    if (rate <= 100) return 100;
    if (rate <= 500) return 500;
    return 1000;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpeedTestBloc, SpeedTestState>(
      builder: (context, state) {
        final size = math.min(310.w, MediaQuery.of(context).size.width - 32);
        final rate = state.speed?.transferRate ?? 0;
        final unit = state.speed?.unit.name ?? "Mbps";
        final max = _scaleFor(rate);
        final running = state.status.isLoading;
        final phase = state.uploadStatus.isSuccess
            ? "TEST COMPLETE"
            : state.downloadStatus.isSuccess
                ? "TESTING UPLOAD"
                : running
                    ? "TESTING DOWNLOAD"
                    : "READY";

        return Column(
          children: [
            Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(14),
              decoration: neonDecoration(context, circle: true),
              child: SfRadialGauge(axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: max,
                  startAngle: 140,
                  endAngle: 40,
                  radiusFactor: 0.98,
                  showLastLabel: true,
                  interval: max / 5,
                  minorTicksPerInterval: 3,
                  majorTickStyle: const MajorTickStyle(length: 8, color: gold),
                  minorTickStyle: MinorTickStyle(length: 4, color: gold.withValues(alpha: 0.4)),
                  axisLabelStyle: GaugeTextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 10,
                  ),
                  offsetUnit: GaugeSizeUnit.factor,
                  labelOffset: 0.12,
                  // Dark track behind the colored arc.
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.1,
                    thicknessUnit: GaugeSizeUnit.factor,
                    color: gold.withValues(alpha: 0.12),
                    cornerStyle: CornerStyle.bothCurve,
                  ),
                  pointers: <GaugePointer>[
                    // Gradient arc that fills up with the speed.
                    RangePointer(
                      value: rate.clamp(0, max).toDouble(),
                      width: 0.1,
                      sizeUnit: GaugeSizeUnit.factor,
                      cornerStyle: CornerStyle.bothCurve,
                      enableAnimation: true,
                      animationDuration: 600,
                      animationType: AnimationType.easeOutBack,
                      gradient: const SweepGradient(
                        colors: [gold, orange, red],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                    // Glowing dot at the end of the arc.
                    MarkerPointer(
                      value: rate.clamp(0, max).toDouble(),
                      markerType: MarkerType.circle,
                      markerHeight: 16,
                      markerWidth: 16,
                      color: Colors.white,
                      borderColor: gold,
                      borderWidth: 3,
                      enableAnimation: true,
                      animationDuration: 600,
                      animationType: AnimationType.easeOutBack,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      angle: 90,
                      positionFactor: 0.05,
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.downloadStatus.isSuccess
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: gold,
                            size: 22,
                          ),
                          Text(
                            rate.toStringAsFixed(1),
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 46.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            unit.toUpperCase(),
                            style: context.titleSmall.copyWith(
                              color: gold,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
            ),
            SizedBox(height: 14.h),
            // Current phase.
            Text(
              phase,
              style: context.caption.copyWith(letterSpacing: 4, color: gold),
            ),
            SizedBox(height: 12.h),
            // Test again button (disabled while a test is running).
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: running
                  ? null
                  : () => context.read<SpeedTestBloc>().add(StartSpeedTest()),
              child: Opacity(
                opacity: running ? 0.4 : 1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
                  decoration: neonDecoration(context, radius: 30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded, color: gold, size: 20),
                      SizedBox(width: 8.w),
                      Text(
                        running ? "TESTING..." : "TEST AGAIN",
                        style: context.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
