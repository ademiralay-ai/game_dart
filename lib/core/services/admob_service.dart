// lib/core/services/admob_service.dart
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/admob_constants.dart';

/// Singleton AdMob servisi.
/// Web platformunda tüm metotlar sessizce no-op olarak çalışır.
class AdmobService {
  AdmobService._();
  static final AdmobService instance = AdmobService._();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialReady = false;
  bool _isRewardedReady = false;

  /// Uygulamanın başında bir kez çağrılır.
  Future<void> initialize() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
    debugPrint('[AdmobService] Initialized ✓');
  }

  // ─── BANNER ────────────────────────────────────────────────────
  /// BannerAdWidget'ı doğrudan `ad_banner_widget.dart` oluşturur.

  // ─── INTERSTITIAL ──────────────────────────────────────────────
  void _loadInterstitial() {
    if (kIsWeb) return;
    InterstitialAd.load(
      adUnitId: AdmobConstants.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          debugPrint('[AdmobService] Interstitial yüklendi ✓');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
          debugPrint('[AdmobService] Interstitial yükleme hatası: $error');
        },
      ),
    );
  }

  /// Hazırsa geçiş reklamını göster, sonra otomatik yeniden yükle.
  void showInterstitial() {
    if (kIsWeb || !_isInterstitialReady || _interstitialAd == null) return;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialReady = false;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialReady = false;
        _loadInterstitial();
      },
    );
    _interstitialAd!.show();
  }

  // ─── REWARDED ──────────────────────────────────────────────────
  void _loadRewarded() {
    if (kIsWeb) return;
    RewardedAd.load(
      adUnitId: AdmobConstants.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
          debugPrint('[AdmobService] Rewarded yüklendi ✓');
        },
        onAdFailedToLoad: (error) {
          _isRewardedReady = false;
          debugPrint('[AdmobService] Rewarded yükleme hatası: $error');
        },
      ),
    );
  }

  /// Ödüllü reklam göster. [onRewarded] kullanıcı ödülü kazandığında çağrılır.
  void showRewarded({void Function(RewardItem reward)? onRewarded}) {
    if (kIsWeb || !_isRewardedReady || _rewardedAd == null) return;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedReady = false;
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedReady = false;
        _loadRewarded();
      },
    );
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) => onRewarded?.call(reward),
    );
  }

  bool get isInterstitialReady => _isInterstitialReady;
  bool get isRewardedReady => _isRewardedReady;

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
