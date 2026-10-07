import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:winsguard/core/utils/styles/app_text_styles.dart';
import 'package:winsguard/core/utils/ui_helpers/spacing.dart';

/// A widget that displays a single connection statistic, such as download or upload speed.
class ConnectionStatisticWidget extends StatelessWidget {
  /// The title of the statistic (e.g., "Download").
  final String title;
  /// The value of the statistic (e.g., "12 Mbps").
  final String value;
  /// The icon representing the statistic.
  final IconData icon;
  /// The background color of the icon's circle.
  final Color backgroundColor;

  /// Creates a [ConnectionStatisticWidget].
  const ConnectionStatisticWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25.sp,
          backgroundColor: backgroundColor,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        gap6,
        Text(
          title,
          style: context.titleMedium
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: context.caption,
        ),
      ],
    );
  }
}
