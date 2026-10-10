import 'package:flutter/material.dart';
import 'package:vpn_master/core/constants/monetization_manager.dart';
import 'package:vpn_master/widgets/mrec_ad_widget.dart';
import 'package:vpn_master/widgets/native_ad_widget.dart';

/// The "big ad" slot (server list, Network page, Speed page).
/// Default: MREC (300x250). When a native ad network is added later, set
/// `MonetizationManager.useNativeAds = true` and every slot switches to Native.
class AdSlotWidget extends StatelessWidget {
  /// Creates an [AdSlotWidget].
  const AdSlotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MonetizationManager.useNativeAds
        ? const NativeAdWidget()
        : const MrecAdWidget();
  }
}
