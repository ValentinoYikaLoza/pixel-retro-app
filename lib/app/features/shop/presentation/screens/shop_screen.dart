import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/providers/shop_provider.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/widgets/anuncio_container.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/widgets/section_title.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/widgets/show_item.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopState = ref.watch(shopProvider);

    final internetStatusState = ref.watch(internetStatusProvider);

    final hasIntenetConnection = internetStatusState.value ?? false;

    final hasAdvertisements = shopState.advertisements.isNotEmpty;
    final hasCoinShopItems = shopState.coinShopItems.isNotEmpty;
    final hasLiveShopItems =
        shopState.liveShopItemsUnitUsd.isNotEmpty ||
        shopState.liveShopItemsUnitCoin.isNotEmpty;

    return hasIntenetConnection &&
            hasAdvertisements &&
            hasCoinShopItems &&
            hasLiveShopItems
        ? CustomScrollView(
            slivers: [
              // -------------------- ANUNCIOS --------------------
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: 'Anuncios'),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: shopState.advertisements.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ad = shopState.advertisements[index];
                          return AnuncioContainerWidget(
                            title: ad.description,
                            type: ad.typeId == 1
                                ? TypeItemShop.coin
                                : TypeItemShop.live,
                            imagePath: ad.typeId == 1
                                ? 'assets/icons/coin.svg'
                                : 'assets/icons/heart.svg',
                            color: ad.typeId == 1
                                ? AppColors.yellow
                                : AppColors.red,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // -------------------- MONEDAS --------------------
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: 'Monedas'),

                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: shopState.coinShopItems.length,
                        itemBuilder: (context, index) {
                          final item = shopState.coinShopItems[index];

                          return ShopItem(
                            imagePath: ref
                                .read(shopProvider.notifier)
                                .getItemImagePath(index + 1, TypeItemShop.coin),
                            quantity: item.quantity,
                            price: item.price,
                            unit: ShopItemUnit.usd,
                            color: AppColors.yellow,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // -------------------- VIDAS --------------------
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: 'Vidas'),

                      // live items USD
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: shopState.liveShopItemsUnitUsd.length,
                        itemBuilder: (context, index) {
                          final item = shopState.liveShopItemsUnitUsd[index];

                          return ShopItem(
                            imagePath: ref
                                .read(shopProvider.notifier)
                                .getItemImagePath(index + 1, TypeItemShop.live),
                            quantity: item.quantity,
                            price: item.price,
                            unit: ShopItemUnit.usd,
                            color: AppColors.red,
                          );
                        },
                      ),

                      // live items coins
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: shopState.liveShopItemsUnitCoin.length,
                        itemBuilder: (context, index) {
                          final item = shopState.liveShopItemsUnitCoin[index];

                          return ShopItem(
                            imagePath: ref
                                .read(shopProvider.notifier)
                                .getItemImagePath(index + 1, TypeItemShop.live),
                            quantity: item.quantity,
                            price: item.price,
                            unit: ShopItemUnit.coin,
                            color: AppColors.yellow,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 20,
                children: [
                  Stack(
                    children: [
                      Text(
                        "Los artículos no están disponibles\nen este momento",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pixel',
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 4
                            ..color = AppColors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Los artículos no están disponibles\nen este momento",
                        style: TextStyle(
                          color: AppColors.purple,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pixel',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Text(
                    "Parece que estás offline. ¡Revisa tu conexión!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
  }
}
