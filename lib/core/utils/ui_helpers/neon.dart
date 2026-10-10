import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';

/// Neon glow card style: dark fill, thin bright border and a soft glow.
BoxDecoration neonDecoration(
  BuildContext context, {
  Color? color,
  double radius = 12,
  bool circle = false,
}) {
  final glow = color ?? context.colors.primary;
  return BoxDecoration(
    color: context.colors.secondaryBackground,
    shape: circle ? BoxShape.circle : BoxShape.rectangle,
    borderRadius: circle ? null : BorderRadius.circular(radius.r),
    border: Border.all(color: glow, width: 1),
    boxShadow: [
      BoxShadow(color: glow.withValues(alpha: 0.55), blurRadius: 10),
      BoxShadow(color: glow.withValues(alpha: 0.20), blurRadius: 22, spreadRadius: 1),
    ],
  );
}
