import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/providers/ad_provider.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';

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

class AdRewardedCoinsScreen extends ConsumerWidget {
  const AdRewardedCoinsScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final adRewardedAsync = ref.watch(adRewardedCoinsProvider);

    ref.listen(adRewardedCoinsProvider, (previous, next) {
      if (!next.hasValue) return;
      if (next.value == null) return;

      next.value!.show(
        onUserEarnedReward: (ad, reward) {
          SnackbarService.show(
            '¡Felicidades! Has ganado un ${reward.amount} monedas',
          );
          Get.offNamed(AppRoutes.shop);
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

class AdRewardedLivesScreen extends ConsumerWidget {
  const AdRewardedLivesScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final adRewardedAsync = ref.watch(adRewardedLivesProvider);

    ref.listen(adRewardedLivesProvider, (previous, next) {
      if (!next.hasValue) return;
      if (next.value == null) return;

      next.value!.show(
        onUserEarnedReward: (ad, reward) {
          SnackbarService.show(
            '¡Felicidades! Has ganado un ${reward.amount} vidas',
          );
          Get.offNamed(AppRoutes.shop);
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
