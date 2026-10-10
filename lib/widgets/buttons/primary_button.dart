
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/ui_helpers/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/utils/styles/app_text_styles.dart';
import 'package:vpn_master/core/utils/ui_helpers/paddings.dart';
import 'package:vpn_master/core/utils/ui_helpers/radius.dart';


/// A reusable primary button widget for the application.
class PrimaryButton extends StatelessWidget {
  /// Indicates whether the button is in a loading state.
  final bool? isLoading;
  /// The text to display on the button.
  final String? text;
  /// The width of the button.
  final double? width;
  /// The height of the button.
  final double? height;
  /// The alignment of the button's child content.
  final Alignment? alignment;
  /// The padding within the button.
  final EdgeInsets? padding;
  /// The border radius of the button.
  final BorderRadius? radius;
  /// The color of the button's text.
  final Color? textColor;
  /// The background color of the button.
  final Color? background;
  /// The color of the button's border.
  final Color? strokeColor;
  /// An optional icon to display before the text.
  final IconData? icon;
  /// The callback that is executed when the button is tapped.
  final VoidCallback? onPressed;

  /// Creates a [PrimaryButton].
  const PrimaryButton({
    super.key,
    this.isLoading,
    this.text,
    this.width,
    this.height,
    this.alignment,
    this.padding,
    this.radius,
    this.textColor,
    this.background,
    this.icon,
    this.onPressed,
    this.strokeColor
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width ?? 1.sw,
        height: height ?? 50.h,
        alignment: alignment ?? Alignment.center,
        padding: padding ?? paddingH16,
        decoration: ShapeDecoration(
          color: background ?? context.colors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: radius ?? radius8,
            side: strokeColor != null ? BorderSide(
              width: 1.w,
              color: strokeColor!
            ):BorderSide.none
          ),
        ),
        // Shows a loading indicator if isLoading is true, otherwise shows the button content.
        child: isLoading == true ?
        const Center(
            child: SizedBox(
                child: CircularProgressIndicator(
                    color: Color(0xFF0C0C0E)
                )
            )
        ) : Row(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [

            // Displays an icon if provided.
            if(icon != null)
            Row(
              children: [
                Icon(
                  icon,
                  color: textColor ?? const Color(0xFF0C0C0E),
                ),

                gap6,
              ],
            ),

            // The main button text.
            Text(
              text ?? "Continue",
              style: context.bodyMedium.copyWith(color: textColor ?? const Color(0xFF0C0C0E), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
