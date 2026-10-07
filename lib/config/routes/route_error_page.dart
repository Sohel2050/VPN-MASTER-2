import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/ui_helpers/spacing.dart';
import 'package:winsguard/core/utils/ui_helpers/ui_helpers.dart';

/// A page displayed when a route is not found or an error occurs during navigation.
class ErrorPage extends StatelessWidget {
  /// The state of the router at the time of the error, containing error details.
  final GoRouterState? state;

  /// Creates an [ErrorPage].
  const ErrorPage({super.key, this.state});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    // Determine the error message and the path that failed from the router state.

    final errorMessage = state?.error?.message ?? 'The page you’re looking for doesn’t exist.';
    final failedPath = state?.uri.toString() ?? '';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "404 - Page Not Found",
          style: TextStyle(
              color: Colors.white
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: context.colors.primary,
      ),
      body: Center(
        child: Padding(
          padding: const .symmetric(horizontal: 24.0),
          child: Material(
            child: Padding(
              padding: padding24,
              child: Column(
                mainAxisSize: .min,
                children: [
                  // An animated error icon with a bounce effect.
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (context, scale, _) => Transform.scale(
                      scale: scale,
                      child: const Icon(Icons.error_outline, size: 80, color: Colors.red),
                    ),
                  ),

                  gap24,
                  // The main error headline.
                  Text(
                    "Oops! Page Not Found",
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  gap12,

                  // A detailed error message.
                  Text(
                    errorMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                  ),

                  // Displays the problematic route if available.
                  if (failedPath.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Route: $failedPath',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  gap28,
                  // A button to navigate the user back to the home page.
                  SizedBox(
                    width: 160.w,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home, color: Colors.white),
                      label: const Text("Back to Home",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ), 
            ),
          ),
        ),
      ),
    );
  }
}
