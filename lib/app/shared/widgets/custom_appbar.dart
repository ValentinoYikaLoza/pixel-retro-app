import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/providers/navigation_provider.dart';

class CustomAppbar extends ConsumerWidget implements PreferredSizeWidget {
  final bool isShopView;
  const CustomAppbar({super.key, this.isShopView = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: AppColors.backgroundDark,
      flexibleSpace: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: safeAreaPadding.top),
        height: 62 + safeAreaPadding.top,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.orange, width: 2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                ref.read(navigationProvider.notifier).navigateTo(3);
              },
              child: AppBarRow(
                asset: 'assets/icons/coin.svg',
                text: '100',
                color: AppColors.yellow,
              ),
            ),
            AppBarRow(
              asset: 'assets/icons/fire.svg',
              text: '1',
              color: AppColors.orange,
            ),
            GestureDetector(
              onTap: () {
                ref.read(navigationProvider.notifier).navigateTo(3);
              },
              child: AppBarRow(
                asset: 'assets/icons/heart.svg',
                text: '5',
                color: AppColors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  final Size preferredSize = const Size(double.infinity, 62);
}

class AppBarRow extends StatelessWidget {
  const AppBarRow({
    super.key,
    required this.asset,
    required this.text,
    required this.color,
  });

  final String asset;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(asset, height: 32, width: 32),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
