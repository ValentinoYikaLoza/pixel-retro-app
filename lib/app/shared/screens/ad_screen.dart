import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/app/shared/providers/ad_provider.dart';

class AdScreen extends ConsumerStatefulWidget {
  final AdType type;

  const AdScreen({super.key, required this.type});

  @override
  AdScreenState createState() => AdScreenState();
}

class AdScreenState extends ConsumerState<AdScreen> {
  String baseText = "Cargando anuncio";
  String loadingText = "";

  Timer? _timer;
  int dotCount = 0;

  @override
  void initState() {
    super.initState();

    // Animación de los puntitos
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      setState(() {
        dotCount = (dotCount + 1) % 4;
        loadingText = "$baseText${"." * dotCount}";
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(adProvider(widget.type), (prev, next) {
      final ad = next.value;

      if (ad == null) return;

      if (ad is InterstitialAd) {
        ad.show();
      }

      if (ad is RewardedAd) {
        RewardItem? pendingReward;

        // Guardar la recompensa pero NO entregar aún
        ad.setImmersiveMode(true);
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) {},
          onAdFailedToShowFullScreenContent: (ad, err) {
            ad.dispose();
          },

          // ⭐ Se llama cuando el usuario PRESIONA LA X
          onAdDismissedFullScreenContent: (ad) async {
            ad.dispose();

            setState(() {
              baseText = "Obteniendo recompensa";
            });

            if (pendingReward != null) {
              final reward = pendingReward!;
              final text = widget.type == AdType.rewardedCoins
                  ? "¡Ganaste ${reward.amount} monedas!"
                  : "¡Ganaste ${reward.amount} vidas!";

              if (widget.type == AdType.rewardedCoins) {
                await ref
                    .read(userProvider.notifier)
                    .updateCoins(reward.amount.toInt());
              } else if (widget.type == AdType.rewardedLives) {
                await ref
                    .read(userProvider.notifier)
                    .updateLives(reward.amount.toInt());
              }
              SnackbarService.show(text, type: SnackbarType.success);
            }

            // Ir a la tienda luego del cierre
            Get.offNamed(AppRoutes.shop);
          },
        );

        // Aquí NO damos recompensa, solo la guardamos
        ad.show(
          onUserEarnedReward: (_, reward) {
            pendingReward = reward;
          },
        );
      }
    });

    return Container(
      decoration: BoxDecoration(color: AppColors.logoBackground),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          Image.asset('assets/images/logo.png'),
          Stack(
            children: [
              Text(
                loadingText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pixel',
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = AppColors.orange,
                ),
              ),
              Text(
                loadingText,
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pixel',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
