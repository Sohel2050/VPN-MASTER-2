import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show ConsentInformation, ConsentForm, ConsentRequestParameters;
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'package:vpn_master/core/constants/monetization_manager.dart';

/// Starts Unity LevelPlay and shows interstitial / rewarded ads.
///
/// Flow: user consent form (GDPR/UMP) -> LevelPlay init -> preload ads.
class MonetizationService with LevelPlayInitListener {
  MonetizationService._();

  static final MonetizationService instance = MonetizationService._();

  /// Becomes true after LevelPlay finished its init. Banner / native widgets wait for it.
  static final ValueNotifier<bool> isReady = ValueNotifier<bool>(false);

  LevelPlayInterstitialAd? _interstitial;
  LevelPlayRewardedAd? _rewarded;
  VoidCallback? _onRewarded;

  /// Call once at app start. It never throws.
  static Future<void> initialize() async {
    if (!MonetizationManager.isMonetizationEnabled) return;
    if (!MonetizationManager.isConfigured) {
      debugPrint("LevelPlay: add your App Key and Ad Unit IDs in monetization_manager.dart");
      return;
    }
    await _gatherConsent();
    try {
      final request = LevelPlayInitRequest.builder(MonetizationManager.appKey).build();
      await LevelPlay.init(initRequest: request, initListener: instance);
    } catch (e) {
      debugPrint("LevelPlay init error: $e");
    }
  }

  /// Shows the Google UMP consent form for users in regions that require it.
  static Future<void> _gatherConsent() async {
    final done = Completer<void>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {
            if (!done.isCompleted) done.complete();
          });
        },
        (_) {
          if (!done.isCompleted) done.complete();
        },
      );
      await done.future.timeout(const Duration(seconds: 15), onTimeout: () {});
    } catch (e) {
      debugPrint("Consent error: $e");
    }
  }

  /// Shows an interstitial if one is ready, then loads the next one.
  static Future<void> showInterstitial() async {
    if (!MonetizationManager.isMonetizationEnabled || !isReady.value) return;
    final ad = instance._interstitial;
    if (ad == null) return;
    try {
      if (await ad.isAdReady()) {
        await ad.showAd();
      } else {
        ad.loadAd();
      }
    } catch (e) {
      debugPrint("Interstitial show error: $e");
    }
  }

  /// True when a rewarded video can be shown right now.
  static Future<bool> isRewardedReady() async {
    if (!MonetizationManager.isMonetizationEnabled || !isReady.value) return false;
    try {
      return await instance._rewarded?.isAdReady() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Shows a rewarded video. [onRewarded] runs when the user finished watching.
  /// Returns false when no video is ready (then nothing is shown).
  static Future<bool> showRewarded({required VoidCallback onRewarded}) async {
    final ad = instance._rewarded;
    if (ad == null || !await isRewardedReady()) {
      instance._rewarded?.loadAd();
      return false;
    }
    instance._onRewarded = onRewarded;
    try {
      await ad.showAd();
      return true;
    } catch (e) {
      debugPrint("Rewarded show error: $e");
      return false;
    }
  }

  // ---- LevelPlayInitListener ----
  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    _interstitial = LevelPlayInterstitialAd(adUnitId: MonetizationManager.interstitialAdUnitId)
      ..setListener(_InterstitialListener(this))
      ..loadAd();
    _rewarded = LevelPlayRewardedAd(adUnitId: MonetizationManager.rewardedAdUnitId)
      ..setListener(_RewardedListener(this))
      ..loadAd();
    isReady.value = true;
  }

  @override
  void onInitFailed(LevelPlayInitError error) {
    debugPrint("LevelPlay init failed: $error");
  }
}

class _InterstitialListener with LevelPlayInterstitialAdListener {
  _InterstitialListener(this._service);
  final MonetizationService _service;

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLoadFailed(LevelPlayAdError error) => debugPrint("Interstitial load failed: $error");

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) => _service._interstitial?.loadAd();

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) => _service._interstitial?.loadAd();

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}

class _RewardedListener with LevelPlayRewardedAdListener {
  _RewardedListener(this._service);
  final MonetizationService _service;

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLoadFailed(LevelPlayAdError error) => debugPrint("Rewarded load failed: $error");

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) => _service._rewarded?.loadAd();

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) => _service._rewarded?.loadAd();

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
    // The user finished the video: give the reward once.
    final callback = _service._onRewarded;
    _service._onRewarded = null;
    callback?.call();
  }
}
