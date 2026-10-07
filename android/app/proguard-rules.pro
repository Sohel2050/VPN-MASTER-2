# ============================================================
# Winsguard release rules (R8 / ProGuard)
# ============================================================

-keepattributes Signature, InnerClasses, EnclosingMethod, *Annotation*, SourceFile, LineNumberTable
-keepattributes Exceptions, RuntimeVisibleAnnotations

# ---------- Flutter ----------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ---------- OpenVPN core / VPN plugin ----------
-keep class de.blinkt.openvpn.** { *; }
-keep class com.oneconnect.** { *; }
-dontwarn de.blinkt.openvpn.**

# ---------- Unity LevelPlay (ironSource) ----------
-keep class com.ironsource.** { *; }
-keep class com.unity3d.mediation.** { *; }
-keepclassmembers class com.ironsource.sdk.controller.IronSourceWebView$JSInterface { public *; }
-keepclassmembers class * implements android.os.Parcelable { public static final android.os.Parcelable$Creator *; }
-dontwarn com.ironsource.**
-dontwarn com.unity3d.mediation.**

# ---------- Google Play services / UMP consent ----------
-keep public class com.google.android.gms.ads.** { public *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.appset.** { *; }
-keep class com.google.android.gms.ads.identifier.** { *; }
-keep class com.google.android.ump.** { *; }
-dontwarn com.google.android.gms.**

# ---------- Commonly missing optional classes ----------
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
