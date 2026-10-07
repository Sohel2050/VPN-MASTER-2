import 'package:flutter/material.dart';

@immutable
class ThemeColors extends ThemeExtension<ThemeColors> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color secondaryBackground;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color disabled;
  final Color textPrimary;
  final Color textSecondary;
  final Color iconPrimary;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.secondaryBackground,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.disabled,
    required this.textPrimary,
    required this.textSecondary,
    required this.iconPrimary,
  });

  @override
  ThemeColors copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? secondaryBackground,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
    Color? disabled,
    Color? textPrimary,
    Color? textSecondary,
    Color? iconPrimary,
  }) {
    return ThemeColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      disabled: disabled ?? this.disabled,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      iconPrimary: iconPrimary ?? this.iconPrimary,
    );
  }

  @override
  ThemeColors lerp(ThemeExtension<ThemeColors>? other, double t) {
    if (other is! ThemeColors) return this;
    return ThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      secondaryBackground: Color.lerp(secondaryBackground, other.secondaryBackground, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
    );
  }
}
