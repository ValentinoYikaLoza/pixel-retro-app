import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/providers/navigation_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            Text(
              'Welcome to the Leaderboard Screen!',
              style: TextStyle(
                fontSize: 24.0,
                color: AppColors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Here you can view the leaderboard.',
              style: TextStyle(
                fontSize: 16.0,
                color: AppColors.orange,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(navigationProvider.notifier).navigateTo(2);
              },
              child: const Text('Go to Rewards'),
            ),
          ],
        ),
      ),
    );
  }
}
