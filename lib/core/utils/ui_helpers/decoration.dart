
import 'package:flutter/material.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/ui_helpers/radius.dart';

BoxDecoration primaryDecoration(BuildContext context) => BoxDecoration(
  color: context.colors.secondaryBackground,
  borderRadius: radius18,
  boxShadow: [
    BoxShadow(
      color: Color(0x00000000),
      blurRadius: 12,
      offset: Offset(0, 6),
      spreadRadius: 0,
    )
  ],
  border: Border.all(
    width: 1,
    color: context.colors.secondaryBackground,
  ),
);
