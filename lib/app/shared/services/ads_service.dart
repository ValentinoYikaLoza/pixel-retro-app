import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdType { banner, interstitial, rewardedCoins, rewardedLives }

class AdsService {
  AdsService._private();

  static final AdsService instance = AdsService._private();

  static const _bannerId = "ca-app-pub-1038083716527611/4373727060";
  static const _interstitialId = "ca-app-pub-1038083716527611/2941333691";
  static const _rewardedCoinsId = "ca-app-pub-1038083716527611/4905044257";
  static const _rewardedLivesId = "ca-app-pub-1038083716527611/3060645398";

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ---------------------------------------------------------
  // BANNER
  // ---------------------------------------------------------
  Future<BannerAd> loadBanner() async {
    final banner = BannerAd(
      adUnitId: _bannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => print("Banner loaded"),
        onAdFailedToLoad: (ad, err) {
          print("Banner error: $err");
          ad.dispose();
        },
      ),
    );

    await banner.load();
    return banner;
  }

  // ---------------------------------------------------------
  // INTERSTITIAL
  // ---------------------------------------------------------
  Future<InterstitialAd?> loadInterstitial() async {
    final completer = Completer<InterstitialAd?>();

    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (err) => completer.complete(null),
      ),
    );

    return completer.future;
  }

  // ---------------------------------------------------------
  // REWARDED COINS
  // ---------------------------------------------------------
  Future<RewardedAd?> loadRewardedCoins() async {
    return _loadRewarded(_rewardedCoinsId);
  }

  // ---------------------------------------------------------
  // REWARDED LIVES
  // ---------------------------------------------------------
  Future<RewardedAd?> loadRewardedLives() async {
    return _loadRewarded(_rewardedLivesId);
  }

  Future<RewardedAd?> _loadRewarded(String id) async {
    final completer = Completer<RewardedAd?>();

    RewardedAd.load(
      adUnitId: id,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (err) => completer.complete(null),
      ),
    );

    return completer.future;
  }

  // ---------------------------------------------------------
  // MÉTODO GENERAL: Recibe un tipo y carga el anuncio correcto
  // ---------------------------------------------------------
  Future<Object?> load(AdType type) {
    switch (type) {
      case AdType.banner:
        return loadBanner();
      case AdType.interstitial:
        return loadInterstitial();
      case AdType.rewardedCoins:
        return loadRewardedCoins();
      case AdType.rewardedLives:
        return loadRewardedLives();
    }
  }
}
