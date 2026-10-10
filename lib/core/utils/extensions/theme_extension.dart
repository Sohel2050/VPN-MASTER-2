import 'package:vpn_master/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

extension ThemeExtensionX on BuildContext {
  ThemeColors get colors => Theme.of(this).extension<ThemeColors>()!;
}
