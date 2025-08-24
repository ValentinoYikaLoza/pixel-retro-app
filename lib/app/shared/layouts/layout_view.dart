// Crea un nuevo widget para manejar el PageView con navegación
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/home/presentation/screens/home_screen.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:pixel_retro_app/app/features/reward/presentation/screens/reward_screen.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/screens/shop_screen.dart';
import 'package:pixel_retro_app/app/shared/providers/navigation_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/tabs_layout.dart';

class LayoutView extends ConsumerStatefulWidget {
  const LayoutView({super.key});

  @override
  LayoutViewState createState() => LayoutViewState();
}

class LayoutViewState extends ConsumerState<LayoutView> {
  late final PageController _pageController;

  final List<Widget> pages = [
    HomeScreen(),
    LeaderboardScreen(),
    RewardScreen(),
    ShopScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setScreenConfig();
    });
    // Obtener el estado inicial del provider
    final initialIndex = ref.read(navigationProvider).currentRoute;
    _pageController = PageController(initialPage: initialIndex);
  }

  void setScreenConfig() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(systemNavigationBarColor: AppColors.orange),
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(navigationProvider.notifier).navigateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final navigationState = ref.watch(navigationProvider);

    // Sincronizar el PageController si cambia externamente
    if (_pageController.hasClients &&
        _pageController.page?.round() != navigationState.currentRoute) {
      _pageController.jumpToPage(navigationState.currentRoute);
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: pages,
      ),
      bottomNavigationBar: TabsLayout(
        currentIndex: navigationState.currentRoute,
        pages: pages,
        onTabTapped: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}
