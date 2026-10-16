import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';

/// Warning shown before connecting to a third party (VPN Gate) server.
/// Returns true when the user taps "Connect anyway", false for "Close".
Future<bool> showThirdPartyServerDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final bodyStyle = TextStyle(
        color: dialogContext.colors.textSecondary,
        fontSize: 14.sp,
        height: 1.35,
      );
      return AlertDialog(
        backgroundColor: dialogContext.colors.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        icon: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 44.w),
        title: const Text("Third-party server", textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "This server is run by an independent volunteer (VPN Gate), not by us.",
                style: bodyStyle,
              ),
              SizedBox(height: 8.h),
              Text(
                "The operator may be able to see or log your traffic. Do not use it for banking, passwords or other sensitive activity.",
                style: bodyStyle,
              ),
              SizedBox(height: 8.h),
              Text("Speed and stability can vary.", style: bodyStyle),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Close"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text("Connect anyway"),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
