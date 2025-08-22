import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/providers/navigation_provider.dart';
import 'package:pixel_retro_app/app/shared/providers/user_provider.dart';

class CustomAppbar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final bool isShopView;
  const CustomAppbar({super.key, this.isShopView = false});

  @override
  final Size preferredSize = const Size(double.infinity, 62);

  @override
  CustomAppbarState createState() => CustomAppbarState();
}

class CustomAppbarState extends ConsumerState<CustomAppbar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;
    final userState = ref.watch(userProvider);

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
                text: '${userState.coins}',
                color: AppColors.yellow,
              ),
            ),
            if (!widget.isShopView)
              AppBarRow(
                asset: 'assets/icons/fire.svg',
                text: '${userState.streak}',
                color: AppColors.orange,
              ),
            GestureDetector(
              onTap: () {
                ref.read(navigationProvider.notifier).navigateTo(3);
              },
              child: AppBarRow(
                asset: 'assets/icons/heart.svg',
                text: '${userState.lives}',
                color: AppColors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
