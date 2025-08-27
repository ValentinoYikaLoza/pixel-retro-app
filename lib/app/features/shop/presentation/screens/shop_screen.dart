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
      ref.read(shopProvider.notifier).getAdvertisements();
      ref.read(shopProvider.notifier).getCoinShopItems();
      ref.read(shopProvider.notifier).getLiveShopItems();
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

                  shopState.coinShopItems.isNotEmpty
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
                          itemCount: shopState.coinShopItems.length,
                          itemBuilder: (context, index) {
                            final item = shopState.coinShopItems[index];

                            return ShopItemWidget(
                              imagePath: ref
                                  .read(shopProvider.notifier)
                                  .getItemImagePath(
                                    index + 1,
                                    TypeItemShop.coin,
                                  ),
                              quantity: item.quantity,
                              price: item.price,
                              unit: ShopItemUnit.usd,
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
                  shopState.liveShopItemsUnitUsd.isNotEmpty
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
                          itemCount: shopState.liveShopItemsUnitUsd.length,
                          itemBuilder: (context, index) {
                            final item = shopState.liveShopItemsUnitUsd[index];

                            return ShopItemWidget(
                              imagePath: ref
                                  .read(shopProvider.notifier)
                                  .getItemImagePath(
                                    index + 1,
                                    TypeItemShop.live,
                                  ),
                              quantity: item.quantity,
                              price: item.price,
                              unit: ShopItemUnit.usd,
                              color: AppColors.red,
                            );
                          },
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            color: AppColors.orange,
                          ),
                        ),
                  shopState.liveShopItemsUnitCoin.isNotEmpty
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
                          itemCount: shopState.liveShopItemsUnitCoin.length,
                          itemBuilder: (context, index) {
                            final item = shopState.liveShopItemsUnitCoin[index];

                            return ShopItemWidget(
                              imagePath: ref
                                  .read(shopProvider.notifier)
                                  .getItemImagePath(
                                    index + 1,
                                    TypeItemShop.live,
                                  ),
                              quantity: item.quantity,
                              price: item.price,
                              unit: ShopItemUnit.coin,
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
          if (unit == ShopItemUnit.coin)
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
