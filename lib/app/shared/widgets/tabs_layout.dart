import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

class TabsLayout extends StatefulWidget {
  const TabsLayout({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.pages,
  });

  final int currentIndex;
  final Function(int) onTabTapped;
  final List<Widget> pages;

  @override
  State<TabsLayout> createState() => _TabsLayoutState();
}

class _TabsLayoutState extends State<TabsLayout> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.orange, width: 2)),
      ),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            size: 48,
            currentIndex: widget.currentIndex,
            normalAsset: 'assets/icons/home.svg',
            selectedAsset: 'assets/icons/home-selected.svg',
          ),
          _buildNavItem(
            index: 1,
            size: 54,
            currentIndex: widget.currentIndex,
            normalAsset: 'assets/icons/leaderboard.svg',
            selectedAsset: 'assets/icons/leaderboard-selected.svg',
          ),
          _buildNavItem(
            index: 2,
            size: 48,
            currentIndex: widget.currentIndex,
            normalAsset: 'assets/icons/chest.svg',
            selectedAsset: 'assets/icons/chest-selected.svg',
          ),
          _buildNavItem(
            index: 3,
            size: 48,
            currentIndex: widget.currentIndex,
            normalAsset: 'assets/icons/shop.svg',
            selectedAsset: 'assets/icons/shop-selected.svg',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required double size,
    required String normalAsset,
    required String selectedAsset,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        widget.onTabTapped(index);
      },
      child: Container(
        padding: EdgeInsets.all(size == 48 ? 8 : 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected
              ? AppColors.orange.withOpacity(0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: SvgPicture.asset(
          isSelected ? selectedAsset : normalAsset,
          height: size,
          width: size,
        ),
      ),
    );
  }
}
