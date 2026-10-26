import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'package:vpn_master/core/constants/monetization_manager.dart';
import 'package:vpn_master/core/services/monetization/ad_visibility.dart';
import 'package:vpn_master/core/services/monetization/monetization_service.dart';
import 'package:vpn_master/core/utils/ui_helpers/neon.dart';
import 'package:vpn_master/widgets/ad_collapse.dart';

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

  /// True only while an ad is really loaded. Otherwise the whole box (border, glow,
  /// margin) takes no space.
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
      if (mounted) _key.currentState?.loadAd();
    });
  }

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
        return AdCollapse(
          visible: _loaded,
          child: Container(
            width: 300,
            height: 250,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            // Theme colored card (fill + border) around the ad.
            decoration: neonDecoration(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: LevelPlayBannerAdView(
                key: _key,
                adUnitId: MonetizationManager.mrecAdUnitId,
                adSize: LevelPlayAdSize.MEDIUM_RECTANGLE,
                listener: this,
                onPlatformViewCreated: () {
                  // A fresh native view starts hidden until its ad is loaded.
                  _setLoaded(false);
                  _key.currentState?.loadAd();
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
