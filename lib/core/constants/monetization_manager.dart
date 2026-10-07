/// All advertisement settings for the app (Unity LevelPlay mediation).
///
/// Ids come from the LevelPlay dashboard: https://platform.ironsrc.com
class MonetizationManager {
  const MonetizationManager._();

  /// Set to false to turn off every ad in the app.
  static bool isMonetizationEnabled = true;

  /// LevelPlay App Key.
  static const String appKey = "288e61d0d";

  /// Banner ad unit id.
  static const String bannerAdUnitId = "bthg9c7kjlnslq0x";

  /// Interstitial ad unit id.
  static const String interstitialAdUnitId = "usx47s9izppmoehd";

  /// Rewarded ad unit id.
  static const String rewardedAdUnitId = "pilez0cdpcelyvv7";

  /// Native ad unit id (kept for reference: the Flutter plugin loads native ads
  /// through the LevelPlay placement, it does not take an ad unit id).
  static const String nativeAdUnitId = "e2adpsiggjgpfl9z";

  /// True when real ids were filled in.
  static bool get isConfigured =>
      !appKey.startsWith("YOUR_") &&
      !bannerAdUnitId.startsWith("YOUR_") &&
      !interstitialAdUnitId.startsWith("YOUR_");
}
