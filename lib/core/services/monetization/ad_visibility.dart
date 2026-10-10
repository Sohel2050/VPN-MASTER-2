import 'package:flutter/foundation.dart';

/// Lets pages hide native ad views while an overlay (like the drawer) is open,
/// because native ad views are always drawn above Flutter widgets.
class AdVisibility {
  const AdVisibility._();

  /// True while a side drawer is open.
  static final ValueNotifier<bool> drawerOpen = ValueNotifier<bool>(false);
}
