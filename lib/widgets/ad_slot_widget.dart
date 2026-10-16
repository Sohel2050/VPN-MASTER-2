import 'package:flutter/material.dart';
import 'package:vpn_master/widgets/mrec_ad_widget.dart';

/// The "big ad" slot (Network page, Speed page). It always shows an MREC (300x250) ad.
class AdSlotWidget extends StatelessWidget {
  /// Creates an [AdSlotWidget].
  const AdSlotWidget({super.key});

  @override
  Widget build(BuildContext context) => const MrecAdWidget();
}
