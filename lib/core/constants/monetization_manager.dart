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

  /// MREC (300x250) ad unit id. Create it in the LevelPlay dashboard (ad format:
  /// Banner, size: MREC) and paste the id here. Until then MREC ads stay hidden.
  static const String mrecAdUnitId = "43zxnkhf0otypdcy";

  /// Set to true to hide the bottom banner on pages that show an MREC ad
  /// (Speed and Network). false = the banner is always visible.
  static const bool hideBannerWhenMrec = false;

  /// True when a real MREC ad unit id was filled in.
  static bool get isMrecConfigured =>
      isConfigured && !mrecAdUnitId.startsWith("YOUR_");

  /// Interstitial ad unit id.
  static const String interstitialAdUnitId = "usx47s9izppmoehd";

  /// Rewarded ad unit id.
  static const String rewardedAdUnitId = "pilez0cdpcelyvv7";

  /// True when real ids were filled in.
  static bool get isConfigured =>
      !appKey.startsWith("YOUR_") &&
      !bannerAdUnitId.startsWith("YOUR_") &&
      !interstitialAdUnitId.startsWith("YOUR_");
}
