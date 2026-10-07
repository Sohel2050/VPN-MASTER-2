import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';

class CircleLoadingWidget extends StatelessWidget {
  const CircleLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 35.w,
        height: 35.w,
        child: CircularProgressIndicator(
          color: context.colors.primary,
        ),
      ),
    );
  }
}
