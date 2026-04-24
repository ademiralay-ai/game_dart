// lib/core/constants/admob_constants.dart
import 'package:flutter/foundation.dart' show kIsWeb;

class AdmobConstants {
  AdmobConstants._();

  // Publisher & App ID
  static const String publisherId = 'pub-6648140774232557';
  static const String appId = 'ca-app-pub-6648140774232557~2686341886';

  // ─── TEST IDs (şu an aktif) ───
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // ─── PRODUCTION IDs (release'e geçince aktif et) ───
  static const String _prodBanner = 'ca-app-pub-6648140774232557/9597258802';
  static const String _prodInterstitial =
      'ca-app-pub-6648140774232557/8284177134';
  static const String _prodRewarded = 'ca-app-pub-6648140774232557/4713739420';

  // ─── Aktif olan ID'ler (kIsRelease kontrolü ile değişir) ───
  static bool get _useTestAds => true; // TODO: Release için false yap

  static String get bannerId =>
      kIsWeb ? '' : (_useTestAds ? _testBanner : _prodBanner);

  static String get interstitialId =>
      kIsWeb ? '' : (_useTestAds ? _testInterstitial : _prodInterstitial);

  static String get rewardedId =>
      kIsWeb ? '' : (_useTestAds ? _testRewarded : _prodRewarded);
}
