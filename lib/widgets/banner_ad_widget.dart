import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'package:vpn_master/core/constants/monetization_manager.dart';
import 'package:vpn_master/core/services/monetization/ad_visibility.dart';
import 'package:vpn_master/core/services/monetization/monetization_service.dart';
import 'package:vpn_master/widgets/ad_collapse.dart';

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

  /// True only while an ad is really loaded. Otherwise the banner takes no space.
  bool _loaded = false;
  int _retries = 0;
  Timer? _retryTimer;

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _setLoaded(bool value) {
    if (!mounted || _loaded == value) return;
    setState(() => _loaded = value);
  }

  /// The ad could not be loaded or shown: hide the box and try again later (3 times).
  void _onFailed() {
    _setLoaded(false);
    if (_retries >= 3) return;
    _retries++;
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) _bannerKey.currentState?.loadAd();
    });
  }

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
        // No fill color on purpose: the area around the ad always has the page's own
        // theme background, and when the ad fails everything collapses to zero size.
        return AdCollapse(
          visible: _loaded,
          child: Container(
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
                onPlatformViewCreated: () {
                  // A fresh native view starts hidden until its ad is loaded.
                  _setLoaded(false);
                  _bannerKey.currentState?.loadAd();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    _retries = 0;
    _setLoaded(true);
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) => _onFailed();

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) => _onFailed();

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {}

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {}
}
