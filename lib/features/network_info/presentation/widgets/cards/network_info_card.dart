import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/styles/app_text_styles.dart';
import 'package:winsguard/core/utils/ui_helpers/paddings.dart';
import 'package:winsguard/core/utils/ui_helpers/radius.dart';
import 'package:winsguard/core/utils/ui_helpers/spacing.dart';

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
      decoration: BoxDecoration(
        color: context.colors.secondaryBackground,
        borderRadius: radius12,
        border: Border.all(color: const Color(0xFF3A3220), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          gap12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.titleMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: context.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
