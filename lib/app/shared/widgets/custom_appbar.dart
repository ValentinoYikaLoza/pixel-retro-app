import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppbar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  @override
  final Size preferredSize = const Size(double.infinity, 62);

  @override
  CustomAppbarState createState() => CustomAppbarState();
}

class CustomAppbarState extends ConsumerState<CustomAppbar> {
  String? userName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;
    final userState = ref.watch(userProvider);

    final hasUserId = userState.userId != 0;

    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: hasUserId
          ? Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: safeAreaPadding.top,
              ),
              height: 62 + safeAreaPadding.top,
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                border: Border(
                  bottom: BorderSide(color: AppColors.orange, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      AppRoutes.go(AppRoutes.shop);
                    },
                    child: AppBarRow(
                      asset: 'assets/icons/coin.svg',
                      text: '${userState.coins}',
                      color: AppColors.yellow,
                    ),
                  ),
                  AppBarRow(
                    asset: 'assets/icons/fire.svg',
                    text: '${userState.streak}',
                    color: AppColors.orange,
                  ),
                  GestureDetector(
                    onTap: () {
                      AppRoutes.go(AppRoutes.shop);
                    },
                    child: AppBarRow(
                      asset: 'assets/icons/heart.svg',
                      text: '${userState.lives}',
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: safeAreaPadding.top,
              ),
              height: 62 + safeAreaPadding.top,
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                border: Border(
                  bottom: BorderSide(color: AppColors.gray, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Icon(Icons.wifi_off_rounded, color: AppColors.gray, size: 24),
                  Text(
                    'SIN CONEXIÓN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: AppColors.gray,
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
