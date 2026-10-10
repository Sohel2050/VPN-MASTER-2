import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'package:vpn_master/core/constants/monetization_manager.dart';
import 'package:vpn_master/core/services/monetization/ad_visibility.dart';
import 'package:vpn_master/core/services/monetization/monetization_service.dart';
import 'package:vpn_master/core/utils/ui_helpers/neon.dart';

/// MREC ad (300x250, Unity LevelPlay). Shows nothing until its ad unit id is set
/// in monetization_manager.dart and LevelPlay is ready.
class MrecAdWidget extends StatefulWidget {
  /// Creates a [MrecAdWidget].
  const MrecAdWidget({super.key});

  @override
  State<MrecAdWidget> createState() => _MrecAdWidgetState();
}

class _MrecAdWidgetState extends State<MrecAdWidget> with LevelPlayBannerAdViewListener {
  final _key = GlobalKey<LevelPlayBannerAdViewState>();

  @override
  Widget build(BuildContext context) {
    if (!MonetizationManager.isMonetizationEnabled || !MonetizationManager.isMrecConfigured) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<bool>(
      valueListenable: AdVisibility.drawerOpen,
      builder: (context, drawerOpen, _) => drawerOpen
          ? const SizedBox.shrink()
          : _buildAd(),
    );
  }

  Widget _buildAd() {
    return ValueListenableBuilder<bool>(
      valueListenable: MonetizationService.isReady,
      builder: (context, ready, _) {
        if (!ready) return const SizedBox.shrink();
        return Container(
          width: 300,
          height: 250,
          margin: EdgeInsets.symmetric(vertical: 8.h),
          decoration: neonDecoration(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: LevelPlayBannerAdView(
              key: _key,
              adUnitId: MonetizationManager.mrecAdUnitId,
              adSize: LevelPlayAdSize.MEDIUM_RECTANGLE,
              listener: this,
              onPlatformViewCreated: () => _key.currentState?.loadAd(),
            ),
          ),
        );
      },
    );
  }

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLoadFailed(LevelPlayAdError error) {}

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {}

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {}

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {}
}
