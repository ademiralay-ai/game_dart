# Flutter ProGuard kuralları
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Easy Localization
-keep class **.*_Keys { *; }

# Flutter engine deferred components kullanmiyoruz.
# R8, opsiyonel Play Core siniflari yokken release build'i dusurmesin.
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn com.google.android.play.core.common.**
-dontwarn com.google.android.play.core.splitcompat.**
