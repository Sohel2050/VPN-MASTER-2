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

  /// Creates a [ServerItemView].
  const ServerItemView({
    super.key,
    required this.flag,
    required this.country,
    required this.speed,
    required this.ping,
    required this.users,
    required this.isSelected,
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


              FittedBox(
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

          // User count
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
