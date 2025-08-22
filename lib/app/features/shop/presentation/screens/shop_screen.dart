import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/providers/shop_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_appbar.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ShopScreenState createState() => ShopScreenState();
}

class ShopScreenState extends ConsumerState<ShopScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopProvider.notifier).initShopItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopProvider);

    return Scaffold(
      appBar: CustomAppbar(isShopView: true),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  const Text(
                    'Anuncios',
                    style: TextStyle(
                      fontSize: 24,
                      height: 24 / 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  AnuncioContainerWidget(
                    title: 'Ver anuncio para obtener 10 monedas',
                    imagePath: 'assets/icons/coins.svg',
                    color: AppColors.orange,
                  ),

                  AnuncioContainerWidget(
                    title: 'Ver anuncio para obtener 5 vidas adicionales',
                    imagePath: 'assets/icons/heart.svg',
                    color: AppColors.red,
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  const Text(
                    'Monedas',
                    style: TextStyle(
                      fontSize: 24,
                      height: 24 / 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),

                  shopState.shopMonedasItems.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.9,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: shopState.shopMonedasItems.length,
                          itemBuilder: (context, index) {
                            final item = shopState.shopMonedasItems[index];

                            return ShopItemWidget(
                              imagePath: item.imagePath,
                              quantity: item.quantity,
                              price: item.price,
                              unit: item.unit,
                              color: AppColors.yellow,
                            );
                          },
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            color: AppColors.orange,
                          ),
                        ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  const Text(
                    'Vidas',
                    style: TextStyle(
                      fontSize: 24,
                      height: 24 / 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  shopState.shopVidasItemsUnitUsd.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.9,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: shopState.shopVidasItemsUnitUsd.length,
                          itemBuilder: (context, index) {
                            final item = shopState.shopVidasItemsUnitUsd[index];

                            return ShopItemWidget(
                              imagePath: item.imagePath,
                              quantity: item.quantity,
                              price: item.price,
                              unit: item.unit,
                              color: AppColors.red,
                            );
                          },
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            color: AppColors.orange,
                          ),
                        ),
                  shopState.shopVidasItemsUnitCoin.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.9,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: shopState.shopVidasItemsUnitCoin.length,
                          itemBuilder: (context, index) {
                            final item =
                                shopState.shopVidasItemsUnitCoin[index];

                            return ShopItemWidget(
                              imagePath: item.imagePath,
                              quantity: item.quantity,
                              price: item.price,
                              unit: item.unit,
                              color: AppColors.yellow,
                            );
                          },
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            color: AppColors.orange,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShopItemWidget extends StatelessWidget {
  const ShopItemWidget({
    super.key,
    required this.imagePath,
    required this.quantity,
    required this.price,
    required this.unit,
    required this.color,
  });

  final String imagePath;
  final int quantity;
  final double price;
  final ShopItemUnit unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.orange, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        spacing: 10,
        children: [
          SvgPicture.asset(imagePath, height: 72),
          Text(
            '$quantity',
            style: TextStyle(
              fontSize: 18,
              height: 18 / 16,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          if (unit == ShopItemUnit.usd)
            Text(
              'USD \$$price',
              style: TextStyle(
                fontSize: 18,
                height: 18 / 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          if (unit == ShopItemUnit.coins)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                SvgPicture.asset(
                  'assets/icons/coin.svg',
                  height: 24,
                  width: 24,
                ),
                Text(
                  price.toStringAsFixed(
                    price.truncateToDouble() == price ? 0 : 2,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    height: 18 / 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.yellow,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AnuncioContainerWidget extends StatelessWidget {
  const AnuncioContainerWidget({
    super.key,
    required this.title,
    required this.imagePath,
    required this.color,
  });

  final String title;
  final String imagePath;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 100),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          SvgPicture.asset(
            'assets/icons/play.svg',
            height: 48,
            width: 48,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
