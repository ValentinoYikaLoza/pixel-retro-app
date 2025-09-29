import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/providers/ad_provider.dart';

class AdBannerScreen extends ConsumerWidget {
  const AdBannerScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final adBannerAsync = ref.watch(adBannerProvider);
    return Scaffold(
      body: Center(
        child: adBannerAsync.when(
          data: (bannerAd) {
            return SizedBox(
              width: bannerAd?.size.width.toDouble(),
              height: bannerAd?.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              const Center(child: Text('Error al mostrar el banner')),
        ),
      ),
    );
  }
}

class AdInterstitialScreen extends ConsumerWidget {
  const AdInterstitialScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final adInterstitialAsync = ref.watch(adInterstitialProvider);

    ref.listen(adInterstitialProvider, (previous, next) {
      if (!next.hasValue) return;
      if (next.value == null) return;

      next.value!.show();
    });

    if (adInterstitialAsync.isLoading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Ad interstitial',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.offNamed(AppRoutes.shop);
            },
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }
}

class AdRewardedScreen extends ConsumerWidget {
  const AdRewardedScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final adRewardedAsync = ref.watch(adRewardedProvider);

    ref.listen(adRewardedProvider, (previous, next) {
      if (!next.hasValue) return;
      if (next.value == null) return;

      next.value!.show(
        onUserEarnedReward: (ad, reward) {
          print('User earned reward: ${reward.amount}');
        },
      );
    });

    if (adRewardedAsync.isLoading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Ad rewarded',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.offNamed(AppRoutes.shop);
            },
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }
}
