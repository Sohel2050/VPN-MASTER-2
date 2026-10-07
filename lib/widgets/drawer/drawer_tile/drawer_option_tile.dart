import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/styles/app_text_styles.dart';
import 'package:winsguard/core/utils/ui_helpers/decoration.dart';
import 'package:winsguard/core/utils/ui_helpers/margins.dart';
import 'package:winsguard/core/utils/ui_helpers/paddings.dart';
import 'package:winsguard/core/utils/ui_helpers/spacing.dart';

/// A reusable tile for displaying an option in a list, typically used in a drawer.
class DrawerOptionTile extends StatelessWidget {
  /// The path for the leading SVG asset. This is used if [icon] is null.
  final String? leadingAsset;
  /// The primary text to display in the tile.
  final String title;
  /// Optional text to display below the title.
  final String? subtitle;
  /// The leading icon for the tile. If this is provided, [leadingAsset] is ignored.
  final IconData? icon;
  /// The callback that is executed when the tile is tapped.
  final VoidCallback onTap;

  /// Creates a [DrawerOptionTile].
  const DrawerOptionTile({
    super.key,
    this.icon,
    this.leadingAsset,
    this.subtitle,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: marginV6,
        padding: padding16,
        decoration: primaryDecoration(context),
        child: Row(
          children: [
            // Displays the leading icon or SVG asset.
            Container(
              padding: padding10,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.2),
                shape: .circle,
              ),
              child: Visibility(
                visible: icon == null,
                replacement: Icon(icon, color: context.colors.primary),
                child: SvgPicture.asset(
                  leadingAsset ?? "",
                  width: 20.w,
                  height: 20.w,
                  colorFilter: ColorFilter.mode(
                    context.colors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            gap12,

            // Displays the title and an optional subtitle.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.primary
                    ),
                  ),
                  if (subtitle != null) ...[
                    gap4,
                    Text(
                      subtitle!,
                      style: context.caption.copyWith(
                        color: context.colors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Displays a trailing arrow to indicate tappability.
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: context.colors.textSecondary,
            )
          ],
        ),
      ),
    );
  }
}
