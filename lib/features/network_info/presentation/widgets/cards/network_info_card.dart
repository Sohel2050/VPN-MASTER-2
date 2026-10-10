import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/styles/app_text_styles.dart';
import 'package:vpn_master/core/utils/ui_helpers/paddings.dart';
import 'package:vpn_master/core/utils/ui_helpers/neon.dart';
import 'package:vpn_master/core/utils/ui_helpers/spacing.dart';

/// Displays a single piece of network information in a card format.
class NetworkInfoCard extends StatelessWidget {
  /// The icon representing the network information (e.g., IP, location).
  final IconData icon;
  /// The title of the network information.
  final String title;
  /// The value or subtitle of the network information.
  final String subtitle;
  /// The color of the leading icon.
  final Color iconColor;

  /// Creates a [NetworkInfoCard].
  const NetworkInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: padding12,
      decoration: neonDecoration(context),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          gap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
