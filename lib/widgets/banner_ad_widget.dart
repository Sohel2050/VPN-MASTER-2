import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'package:vpn_master/core/constants/monetization_manager.dart';
import 'package:vpn_master/core/services/monetization/ad_visibility.dart';
import 'package:vpn_master/core/services/monetization/monetization_service.dart';

/// Banner ad (Unity LevelPlay). Shows nothing until LevelPlay is ready.
class BannerAdWidget extends StatefulWidget {
  /// Hide the banner while a drawer is open (needed when the banner sits inside a
  /// page, because native ad views are always drawn above the drawer).
  final bool hideWhenDrawerOpen;

  /// Creates a [BannerAdWidget].
  const BannerAdWidget({super.key, this.hideWhenDrawerOpen = false});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> with LevelPlayBannerAdViewListener {
  final _bannerKey = GlobalKey<LevelPlayBannerAdViewState>();

  @override
  Widget build(BuildContext context) {
    if (!MonetizationManager.isMonetizationEnabled || !MonetizationManager.isConfigured) {
      return const SizedBox.shrink();
    }
    if (!widget.hideWhenDrawerOpen) return _buildAd();
    return ValueListenableBuilder<bool>(
      valueListenable: AdVisibility.drawerOpen,
      builder: (context, drawerOpen, _) =>
          drawerOpen ? const SizedBox.shrink() : _buildAd(),
    );
  }

  Widget _buildAd() {
    return ValueListenableBuilder<bool>(
      valueListenable: MonetizationService.isReady,
      builder: (context, ready, _) {
        if (!ready) return const SizedBox.shrink();
        return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
          // Fixed size: the native banner view never changes the page layout.
          child: SizedBox(
            width: 320,
            height: 50,
            child: LevelPlayBannerAdView(
              key: _bannerKey,
              adUnitId: MonetizationManager.bannerAdUnitId,
              adSize: LevelPlayAdSize.BANNER,
              listener: this,
              onPlatformViewCreated: () => _bannerKey.currentState?.loadAd(),
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
