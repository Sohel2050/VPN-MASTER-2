import 'package:winsguard/core/utils/styles/app_text_styles.dart';
import 'package:winsguard/core/utils/ui_helpers/paddings.dart';
import 'package:winsguard/core/utils/ui_helpers/spacing.dart';
import 'package:winsguard/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable widget for displaying a generic API error message with a retry button.
class ApiErrorWidget extends StatelessWidget {
  /// The specific error message to be displayed.
  final String errorMessage;
  /// The callback function to be executed when the retry button is pressed.
  final VoidCallback onRetry;

  /// Creates an [ApiErrorWidget].
  const ApiErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon.
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red,
            ),

            gap16,

            // Generic error title.
            Text(
              'Oops! Something went wrong.',
              style: context.titleMedium,
            ),
            gap8,

            // Specific error message.
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: context.caption,
            ),

            gap24,

            // Retry button.
            SizedBox(
              width: 100.w,
              height: 40.h,
              child: PrimaryButton(
                onPressed: onRetry,
                icon: Icons.refresh,
                text: "Retry",
              ),
            )
          ],
        ),
      ),
    );
  }
}
