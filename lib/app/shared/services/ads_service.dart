import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

final adBannerId = "ca-app-pub-3940256099942544/9214589741";
final adInterstitialId = "ca-app-pub-3940256099942544/1033173712";
final adRewardedId = "ca-app-pub-3940256099942544/5224354917";

class AdsService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static Future<BannerAd> showBannerAd() async {
    return BannerAd(
      adUnitId: adBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  static Future<InterstitialAd> showInterstitialAd() async {
    Completer<InterstitialAd> completer = Completer<InterstitialAd>();

    InterstitialAd.load(
      adUnitId: adInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('Ad loaded');
          completer.complete(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Ad failed to load: $error');
          completer.completeError(error);
        },
      ),
    );

    return completer.future;
  }

  static Future<RewardedAd> showRewardedAd() async {
    Completer<RewardedAd> completer = Completer<RewardedAd>();

    RewardedAd.load(
      adUnitId: adRewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('Ad loaded');
          completer.complete(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Ad failed to load: $error');
          completer.completeError(error);
        },
      ),
    );

    return completer.future;
  }
}
