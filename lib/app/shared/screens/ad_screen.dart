import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/app/shared/providers/ad_provider.dart';

class AdScreen extends ConsumerWidget {
  final AdType type;

  const AdScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adAsync = ref.watch(adProvider(type));

    ref.listen(adProvider(type), (prev, next) {
      final ad = next.value;

      if (ad == null) return;

      if (ad is InterstitialAd) {
        ad.show();
      }

      if (ad is RewardedAd) {
        ad.show(
          onUserEarnedReward: (_, reward) {
            final text = type == AdType.rewardedCoins
                ? "¡Ganaste ${reward.amount} monedas!"
                : "¡Ganaste ${reward.amount} vidas!";

            SnackbarService.show(text, type: SnackbarType.success);
            Get.offNamed(AppRoutes.shop);
          },
        );
      }
    });

    if (adAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Cargando anuncio...", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.offNamed(AppRoutes.shop),
              child: const Text("Volver"),
            ),
          ],
        ),
      ),
    );
  }
}
