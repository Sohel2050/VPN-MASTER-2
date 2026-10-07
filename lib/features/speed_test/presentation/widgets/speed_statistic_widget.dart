import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/styles/app_text_styles.dart';
import 'package:winsguard/core/utils/ui_helpers/margins.dart';
import 'package:winsguard/core/utils/ui_helpers/paddings.dart';
import 'package:winsguard/core/utils/ui_helpers/radius.dart';
import 'package:winsguard/core/utils/ui_helpers/spacing.dart';

/// A widget for displaying a single speed statistic, such as download or upload speed.
class SpeedStatisticWidget extends StatelessWidget {

  /// The icon representing the statistic type.
  final IconData icon;
  /// The title of the statistic.
  final String title;
  /// The speed value to display.
  final String speed;
  /// The unit of the speed (e.g., Mbps).
  final String unit;
  /// The background color for the widget.
  final Color background;

  /// Creates a [SpeedStatisticWidget].
  const SpeedStatisticWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.speed,
    required this.unit,
    required this.background
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: 1.sw,
        padding: padding12,
        margin: margin12,
        decoration: BoxDecoration(
            color: background.withValues(alpha: 0.2),
            borderRadius: radius12,
            border: Border.all(
                width: 1.w,
                color: background
            )
        ),
        child: Column(
          crossAxisAlignment: .center,
          children: [
            // Header row with icon and title.
            Row(
              mainAxisAlignment: .center,
              children: [
                Icon(
                    icon,
                    color: context.colors.iconPrimary,
                    size: 18.sp
                ),
                gap4,
                Text(
                  title,
                  style: context.titleSmall,
                ),
              ],
            ),
            gap4,
            // The speed value.
            Text(
              speed,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            // The speed unit.
            Text(
              unit,
              style: context.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
