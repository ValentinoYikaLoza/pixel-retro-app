import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/skeleton.dart';

class CustomAppbar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  @override
  final Size preferredSize = const Size(double.infinity, 62);

  @override
  CustomAppbarState createState() => CustomAppbarState();
}

class CustomAppbarState extends ConsumerState<CustomAppbar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;
    final userState = ref.watch(userProvider);

    final internetStatusState = ref.watch(internetStatusProvider);
    final userInit = ref.watch(userInitProvider);

    final hasIntenetConnection = internetStatusState.value ?? false;
    final hasDataAsync = userInit.hasValue;
    final isDataSyncning = userInit.isLoading;
    final isDataSyncFailed = userInit.hasError;

    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: hasIntenetConnection
          ? hasDataAsync
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
                        GestureDetector(
                          onTap: () {
                            AppRoutes.go(AppRoutes.streak);
                          },
                          child: AppBarRow(
                            asset: 'assets/icons/fire.svg',
                            text: '${userState.streak}',
                            color: AppColors.orange,
                          ),
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
                : isDataSyncning
                ? _buildSkeletonBar(safeAreaPadding.top)
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
                        Icon(
                          isDataSyncFailed
                              ? Icons.error_outline_rounded
                              : Icons.arrow_downward_rounded,
                          color: AppColors.gray,
                          size: 24,
                        ),
                        Text(
                          isDataSyncFailed
                              ? 'OCURRIÓ UN ERROR'
                              : 'SINCRONIZAR DATOS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: AppColors.gray,
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

  /// Skeleton del appbar mientras se cargan los datos del usuario (HTTP).
  Widget _buildSkeletonBar(double topPadding) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: topPadding),
      height: 62 + topPadding,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(bottom: BorderSide(color: AppColors.orange, width: 2)),
      ),
      child: const Shimmer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonBox(width: 70, height: 28),
            SkeletonBox(width: 70, height: 28),
            SkeletonBox(width: 70, height: 28),
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
