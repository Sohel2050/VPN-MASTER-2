import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';

class EarthMapWidget extends StatelessWidget {
  final Alignment? alignment;
  const EarthMapWidget({
    super.key,
    this.alignment
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment ?? .bottomCenter,
      child: Image.asset(
        "assets/images/earth_map.png",
        width: 1.sw,
        color: context.colors.secondary,
      ),
    );
  }
}
