import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'package:winsguard/core/constants/monetization_manager.dart';
import 'package:winsguard/core/services/monetization/monetization_service.dart';

/// Native ad (Unity LevelPlay) used inside the server list.
/// It stays almost invisible until an ad is really loaded.
class NativeAdWidget extends StatefulWidget {
  /// Creates a [NativeAdWidget].
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> with LevelPlayNativeAdListener {
  LevelPlayNativeAd? _nativeAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _nativeAd = LevelPlayNativeAd.builder().withListener(this).build();
  }

  @override
  void dispose() {
    _nativeAd?.destroyAd();
    super.dispose();
  }

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
          margin: EdgeInsets.only(bottom: 8.h),
          height: _loaded ? 130.h : 1,
          child: LevelPlayNativeAdView(
            nativeAd: _nativeAd,
            templateType: LevelPlayTemplateType.SMALL,
            height: _loaded ? 130.h : 1,
            onPlatformViewCreated: () => _nativeAd?.loadAd(),
          ),
        );
      },
    );
  }

  @override
  void onAdLoaded(LevelPlayNativeAd? nativeAd, AdInfo? adInfo) {
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void onAdLoadFailed(LevelPlayNativeAd? nativeAd, IronSourceError? error) {}

  @override
  void onAdImpression(LevelPlayNativeAd? nativeAd, AdInfo? adInfo) {}

  @override
  void onAdClicked(LevelPlayNativeAd? nativeAd, AdInfo? adInfo) {}
}
