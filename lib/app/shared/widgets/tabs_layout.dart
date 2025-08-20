// tabs_layout.dart - Versión corregida
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/router/app_router.dart';

class TabsLayout extends StatefulWidget {
  const TabsLayout({super.key});

  @override
  State<TabsLayout> createState() => _TabsLayoutState();
}

class _TabsLayoutState extends State<TabsLayout> {
  final List<String> pageRoutes = [
    '/home',
    '/leaderboard',
    '/rewards',
    '/shop',
  ];

  int _getCurrentIndex(String location) {
    for (int i = 0; i < pageRoutes.length; i++) {
      if (location == pageRoutes[i] ||
          location.startsWith('${pageRoutes[i]}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(
      GoRouterState.of(context).uri.toString(),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.orange, width: 2)),
      ),
      height: 80,
      child: BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundDark,
        onTap: (value) {
          AppRouter.go(pageRoutes[value]);
        },
        currentIndex: currentIndex,
        selectedItemColor: Colors.transparent, // Transparente para ocultar
        unselectedItemColor: Colors.transparent, // Transparente para ocultar
        selectedLabelStyle: const TextStyle(height: 0, fontSize: 0),
        unselectedLabelStyle: const TextStyle(height: 0, fontSize: 0),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 0,
        items: [
          _buildNavItem(
            'assets/icons/home.svg',
            'assets/icons/home-selected.svg',
            currentIndex == 0,
          ),
          _buildNavItem(
            'assets/icons/leaderboard.svg',
            'assets/icons/leaderboard-selected.svg',
            currentIndex == 1,
          ),
          _buildNavItem(
            'assets/icons/chest.svg',
            'assets/icons/chest-selected.svg',
            currentIndex == 2,
          ),
          _buildNavItem(
            'assets/icons/shop.svg',
            'assets/icons/shop-selected.svg',
            currentIndex == 3,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    String normalAsset,
    String selectedAsset,
    bool isSelected,
  ) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        isSelected ? selectedAsset : normalAsset,
        height: 48, // Reducido para evitar overflow
        width: 48,
      ),
      label: '',
    );
  }
}
