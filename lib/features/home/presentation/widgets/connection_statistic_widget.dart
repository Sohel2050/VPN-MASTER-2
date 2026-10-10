import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/utils/styles/app_text_styles.dart';
import 'package:vpn_master/core/utils/ui_helpers/neon.dart';

/// A neon tile that displays a single connection statistic (download, upload, ping).
class ConnectionStatisticWidget extends StatelessWidget {
  /// The title of the statistic (e.g., "Download").
  final String title;
  /// The value of the statistic (e.g., "12 Mbps").
  final String value;
  /// The icon representing the statistic.
  final IconData icon;
  /// The glow / accent color of the tile.
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
      decoration: neonDecoration(context, color: backgroundColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: backgroundColor, size: 22.sp),
          SizedBox(height: 6.h),
          // The value never overflows: it shrinks to fit the tile.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title.toUpperCase(),
            maxLines: 1,
            style: context.caption.copyWith(letterSpacing: 1.5, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}
