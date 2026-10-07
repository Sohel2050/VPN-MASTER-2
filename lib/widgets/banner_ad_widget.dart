import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'package:winsguard/core/constants/monetization_manager.dart';
import 'package:winsguard/core/services/monetization/monetization_service.dart';

/// Banner ad (Unity LevelPlay). Shows nothing until LevelPlay is ready.
class BannerAdWidget extends StatefulWidget {
  /// Creates a [BannerAdWidget].
  const BannerAdWidget({super.key});

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
    return ValueListenableBuilder<bool>(
      valueListenable: MonetizationService.isReady,
      builder: (context, ready, _) {
        if (!ready) return const SizedBox.shrink();
        return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
          child: LevelPlayBannerAdView(
            key: _bannerKey,
            adUnitId: MonetizationManager.bannerAdUnitId,
            adSize: LevelPlayAdSize.BANNER,
            listener: this,
            onPlatformViewCreated: () => _bannerKey.currentState?.loadAd(),
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
