import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/utils/ui_helpers/paddings.dart';
import 'package:vpn_master/core/utils/ui_helpers/radius.dart';
import 'package:vpn_master/core/utils/ui_helpers/spacing.dart';

/// A reusable widget to display when a list or content is empty.
class EmptyWidget extends StatelessWidget {
  /// The main title to display.
  final String title;
  /// The descriptive text to display below the title.
  final String description;
  /// The text for the optional action button.
  final String? buttonText;
  /// The callback to be executed when the optional button is pressed.
  final VoidCallback? onButtonPressed;

  /// Creates an [EmptyWidget].
  const EmptyWidget({
    super.key,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon.
            Icon(
              Icons.wifi_off_rounded,
              size: 100.r,
              color: Colors.grey[600],
            ),
            
            gap24,

            // Main title text.
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            gap8,

            // Description text.
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            gap24,

            // An optional button that is displayed if both text and a callback are provided.
            if (buttonText != null && onButtonPressed != null)
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: radius24,
                  ),
                ),
                child: Text(buttonText!),
              ),
          ],
        ), 
      ),
    );
  }
}
