import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';

final adProvider = FutureProvider.family.autoDispose<Object?, AdType>((
  ref,
  type,
) async {
  return AdsService.instance.load(type);
});

final adBannerProvider = FutureProvider.autoDispose<BannerAd?>((ref) async {
  return await AdsService.instance.loadBanner();
});
