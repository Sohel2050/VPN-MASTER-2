import 'package:flutter/material.dart';

/// Shows [child] only when [visible] is true. When it is false the widget takes
/// no space at all (no empty box, no gap), but the child is still laid out at its
/// real size so a native ad view can be created and can load its ad.
class AdCollapse extends StatelessWidget {
  /// Creates an [AdCollapse].
  const AdCollapse({super.key, required this.visible, required this.child});

  /// True once the ad is loaded.
  final bool visible;

  /// The ad (with its own margin / decoration).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.topCenter,
        heightFactor: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}
