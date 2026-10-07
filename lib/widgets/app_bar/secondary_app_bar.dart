import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/styles/app_text_styles.dart';

/// A reusable app bar for secondary screens, featuring a back button and a title.
class SecondaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title displayed in the app bar.
  final String title;

  /// Creates a [SecondaryAppBar].
  const SecondaryAppBar({
    super.key,
    required this.title
  });

  /// Sets the standard height for the app bar.
  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Back button to navigate to the previous screen.
      leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.colors.primary,
          )),
      // The title text displayed in the app bar.
      title: Text(
        title,
        style: context.appBarTextStyles.copyWith(
            letterSpacing: 2,
            color: context.colors.primary
        ),
      ),
      centerTitle: true,
      backgroundColor: context.colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}
