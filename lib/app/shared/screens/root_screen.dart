import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/providers/data_sync_provider.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  RootScreenState createState() => RootScreenState();
}

class RootScreenState extends ConsumerState<RootScreen> {
  String loadingText = "Cargando";
  Timer? _timer;
  int dotCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getData();
    });

    // Animación de los puntitos
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      setState(() {
        dotCount = (dotCount + 1) % 4; // 0,1,2,3 → vuelve a 0
        loadingText = "Cargando${"." * dotCount}";
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> getData() async {
    await ref.read(dataSyncProvider.notifier).sync();

    if (Get.isDialogOpen == true) return;

    _timer?.cancel();

    AppRoutes.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.logoBackground),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          Image.asset('assets/images/logo.png'),
          Stack(
            children: [
              Text(
                loadingText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pixel',
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = AppColors.orange,
                ),
              ),
              Text(
                loadingText,
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pixel',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
