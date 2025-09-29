import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';

final adBannerProvider = FutureProvider<BannerAd?>((ref) async {
  final ad = await AdsService.showBannerAd();

  return ad;
});

final adInterstitialProvider = FutureProvider.autoDispose<InterstitialAd?>((
  ref,
) async {
  final ad = await AdsService.showInterstitialAd();

  return ad;
});

final adRewardedProvider = FutureProvider.autoDispose<RewardedAd?>((ref) async {
  final ad = await AdsService.showRewardedAd();

  return ad;
});
