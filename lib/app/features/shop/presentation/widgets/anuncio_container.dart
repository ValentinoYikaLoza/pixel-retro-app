import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/providers/shop_provider.dart';

class AnuncioContainerWidget extends StatelessWidget {
  const AnuncioContainerWidget({
    super.key,
    required this.title,
    required this.imagePath,
    required this.color,
    required this.type,
  });

  final String title;
  final String imagePath;
  final Color color;
  final TypeItemShop type;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.orange, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(imagePath, height: 48, width: 48),
              SizedBox(
                width: 200,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              switch (type) {
                case TypeItemShop.coin:
                  AppRoutes.go(AppRoutes.adRewardedCoins);
                  break;
                case TypeItemShop.live:
                  AppRoutes.go(AppRoutes.adRewardedLives);
                  break;
              }
            },
            child: SvgPicture.asset(
              'assets/icons/play.svg',
              height: 48,
              width: 48,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}
