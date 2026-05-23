import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';

class TabsLayout extends StatefulWidget {
  const TabsLayout({super.key});

  @override
  State<TabsLayout> createState() => _TabsLayoutState();
}

class _TabsLayoutState extends State<TabsLayout> {
  final List<String> pageRoutes = [
    AppRoutes.home,
    AppRoutes.leaderboard,
    AppRoutes.mission,
    AppRoutes.shop,
  ];

  @override
  Widget build(BuildContext context) {
    EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;

    final currentLocation = GoRouterState.of(context).matchedLocation;
    int currentIndex = pageRoutes.indexWhere((route) {
      return route == currentLocation;
    });

    // Si no existe, asigna 0
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.orange, width: 2)),
      ),
      height: 84 + safeAreaPadding.bottom,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundDark,
        onTap: (value) {
          AppRoutes.go(pageRoutes[value]);
        },
        currentIndex: currentIndex,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 14.4 / 12,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 14.4 / 12,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.purple,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SvgPicture.asset(
                'assets/icons/home-test.svg',
                height: 34,
                width: 34,
                colorFilter: ColorFilter.mode(
                  currentIndex == 0 ? AppColors.orange : AppColors.purple,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: 'Juegos',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SvgPicture.asset(
                'assets/icons/cup-test.svg',
                height: 34,
                width: 34,
                colorFilter: ColorFilter.mode(
                  currentIndex == 1 ? AppColors.orange : AppColors.purple,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: 'Divisiónes',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SvgPicture.asset(
                'assets/icons/flag-test.svg',
                height: 34,
                width: 34,
                colorFilter: ColorFilter.mode(
                  currentIndex == 2 ? AppColors.orange : AppColors.purple,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: 'Misiones',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SvgPicture.asset(
                'assets/icons/shop-test.svg',
                height: 34,
                width: 34,
                colorFilter: ColorFilter.mode(
                  currentIndex == 3 ? AppColors.orange : AppColors.purple,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: 'Compras',
          ),
        ],
      ),
    );
  }
}
