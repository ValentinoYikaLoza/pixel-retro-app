import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool isShopView;
  const CustomAppbar({super.key, this.isShopView = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: AppColors.backgroundDark,
      centerTitle: true,
      title: isShopView
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/coin.svg',
                  height: 32,
                  width: 32,
                ),
                SizedBox(width: 10),
                Text(
                  '100',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.yellow,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(width: 20),
                SvgPicture.asset(
                  'assets/icons/heart.svg',
                  height: 32,
                  width: 32,
                ),
                SizedBox(width: 10),
                Text(
                  '5',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.red,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                SvgPicture.asset(
                  'assets/icons/fire.svg',
                  height: 32,
                  width: 32,
                ),
                Text(
                  '1',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
      actions: [
        isShopView
            ? SizedBox(height: 0)
            : Container(
                constraints: const BoxConstraints(maxWidth: 80),
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/heart.svg',
                      height: 32,
                      width: 32,
                    ),
                    Text(
                      '5',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.red,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
      ],
      leading: isShopView
          ? SizedBox(height: 0)
          : Container(
              constraints: const BoxConstraints(maxWidth: 150),
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  SvgPicture.asset(
                    'assets/icons/coin.svg',
                    height: 32,
                    width: 32,
                  ),
                  Text(
                    '100',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.yellow,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
      leadingWidth: isShopView ? null : 150,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.orange, // Color del borde
          height: 2.0, // Grosor del borde
        ),
      ),
      toolbarHeight: 80,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
