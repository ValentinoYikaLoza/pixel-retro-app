import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final adBannerId = "ca-app-pub-1038083716527611/4373727060";
final adInterstitialId = "ca-app-pub-1038083716527611/2941333691";
final adRewardedCoinsId = "ca-app-pub-1038083716527611/4905044257";
final adRewardedLivesId = "ca-app-pub-1038083716527611/3060645398";

class AdsService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static Future<BannerAd> showBannerAd() async {
    return BannerAd(
      adUnitId: adBannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          print('$ad loaded.');
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          print('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
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

  static Future<RewardedAd> showRewardedCoinsAd() async {
    Completer<RewardedAd> completer = Completer<RewardedAd>();

    RewardedAd.load(
      adUnitId: adRewardedCoinsId,
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

  static Future<RewardedAd> showRewardedLivesAd() async {
    Completer<RewardedAd> completer = Completer<RewardedAd>();

    RewardedAd.load(
      adUnitId: adRewardedLivesId,
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
