import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/styles/app_text_styles.dart';
import 'package:vpn_master/core/utils/ui_helpers/margins.dart';
import 'package:vpn_master/core/utils/ui_helpers/paddings.dart';
import 'package:vpn_master/core/utils/ui_helpers/radius.dart';
import 'package:vpn_master/core/utils/ui_helpers/spacing.dart';

/// A widget that displays a single server item in the server list.
class ServerItemView extends StatelessWidget {
  /// The path to the country flag image asset.
  final String flag;
  /// The name of the country.
  final String country;
  /// The server speed.
  final String speed;
  /// The server ping.
  final String ping;
  /// The number of users connected to the server.
  final String users;
  /// Whether the server is currently selected.
  final bool isSelected;
  /// True for your own private server (shows a "Private server" label).
  final bool isOwn;
  /// True for third party (VPN Gate) servers (shows a "Third Party" badge).
  final bool isThirdParty;

  /// Creates a [ServerItemView].
  const ServerItemView({
    super.key,
    required this.flag,
    required this.country,
    required this.speed,
    required this.ping,
    required this.users,
    required this.isSelected,
    this.isOwn = false,
    this.isThirdParty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: padding12,
      margin: marginTop12,
      decoration: BoxDecoration(
        color: context.colors.secondaryBackground,
        borderRadius: radius12,
        border: Border.all(
          color: isSelected ? context.colors.primary : const Color(0xFF3A3220),
          width: isSelected ? 1 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // Country flag
          ClipRRect(
            borderRadius: radiusCircle,
            child: Image.asset(
              flag,
              width: 40.w,
              height: 40.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.public, size: 40.w),
            ),
          ),
          gap8,
          // Server details
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                country,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.titleMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),


              isOwn
              ? Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, color: context.colors.primary, size: 16.sp),
                    gap4,
                    Text("Our Server", style: context.caption.copyWith(fontSize: 12.sp)),
                  ],
                )
              : FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                crossAxisAlignment: .center,
                children: [
                  // Speed
                  Icon(
                    Icons.signal_cellular_alt_rounded,
                    color: context.colors.primary,
                    size: 18.sp,
                  ),
                  gap4,
                  Text(
                    speed,
                    style: context.caption.copyWith(
                        fontSize: 12.sp
                    ),
                  ),

                  gap8,

                  // Ping
                  Icon(
                    Icons.timer_outlined,
                    color: context.colors.primary,
                    size: 18.sp,
                  ),
                  gap4,
                  Text(
                    "$ping Ms",
                    style: context.caption.copyWith(
                      fontSize: 12.sp
                    ),
                  ),


                ],
              ),
              ),
            ],
          ),
          ),
          gap8,

          // User count (not shown for private servers)
          if (!isOwn) ...[
            Icon(
              CupertinoIcons.person_2,
              color: context.colors.iconPrimary,
              size: 18.sp,
            ),
            gap4,
            Text(
              users,
              style: context.caption,
            ),
          ],

          if (isThirdParty) ...[
            gap8,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Third Party",
                style: TextStyle(color: Colors.orange, fontSize: 10.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],

          gap12,
          // Selection indicator
          Visibility(
            visible: isSelected,
            replacement: const Icon(
              Icons.radio_button_off,
              color: Colors.grey,
            ),
            child: const Icon(
              Icons.radio_button_checked,
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }
}
