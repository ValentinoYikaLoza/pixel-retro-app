import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/time_widget.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  LeaderboardScreenState createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardProvider.notifier).getUsers();
      ref.read(leaderboardProvider.notifier).getDivisions();
      ref.read(leaderboardProvider.notifier).getCurrentUser();
      ref.read(leaderboardProvider.notifier).getCurrentDivision();
      ref.read(leaderboardProvider.notifier).getTimeLeft();
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(leaderboardProvider);
    EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 30 + safeAreaPadding.top, bottom: 30),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.orange, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 30,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        leaderboardState.currentDivision?.name ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      TimeWidget(
                        time: leaderboardState.timeLeft?.time ?? 0,
                        unit: leaderboardState.timeLeft?.unit ?? '',
                        color: AppColors.orange,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 75,
                  child: CustomScrollView(
                    scrollDirection: Axis.horizontal,
                    slivers: [
                      SliverPadding(padding: const EdgeInsets.only(left: 20)),
                      SliverList.separated(
                        itemBuilder: (context, index) {
                          return SvgPicture.asset(
                            ref
                                .read(leaderboardProvider.notifier)
                                .getDivisionImage(
                                  leaderboardState.divisions[index].id,
                                ),
                            width: 75,
                            height: 75,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 20);
                        },
                        itemCount: leaderboardState.divisions.length,
                      ),
                      SliverPadding(padding: const EdgeInsets.only(right: 20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          leaderboardState.users.isNotEmpty
              ? Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverList.builder(
                        itemBuilder: (context, index) {
                          final user = leaderboardState.users[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 20,
                            children: [
                              _UserRowWidget(
                                isCurrentUser:
                                    leaderboardState.currentUser!.id == user.id,
                                user: user,
                                index: index + 1,
                              ),
                              if (index + 1 == 5)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 15,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/arrow-up.svg',
                                        width: 32,
                                        height: 32,
                                      ),
                                      const Text(
                                        'ZONA DE ASCENSO',
                                        style: TextStyle(
                                          fontSize: 20,
                                          height: 20 / 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.emerald,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        'assets/icons/arrow-up.svg',
                                        width: 32,
                                        height: 32,
                                      ),
                                    ],
                                  ),
                                ),
                              if (index + 1 == 15)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 15,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/arrow-down.svg',
                                        width: 32,
                                        height: 32,
                                      ),
                                      const Text(
                                        'ZONA DE DESCENSO',
                                        style: TextStyle(
                                          fontSize: 20,
                                          height: 20 / 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.ruby,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        'assets/icons/arrow-down.svg',
                                        width: 32,
                                        height: 32,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                        itemCount: 20,
                      ),
                    ],
                  ),
                )
              : SizedBox(height: 0),
        ],
      ),
    );
  }
}

class _UserRowWidget extends StatelessWidget {
  const _UserRowWidget({
    required this.isCurrentUser,
    required this.user,
    required this.index,
  });

  final bool isCurrentUser;
  final UserDivisionEntity user;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.selector : Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 20,
            children: [
              index <= 3
                  ? SvgPicture.asset(
                      'assets/icons/${index == 1
                          ? 'gold-medal'
                          : index == 2
                          ? 'silver-medal'
                          : 'bronze-medal'}.svg',
                      width: 45,
                      height: 45,
                    )
                  : SizedBox(
                      width: 45,
                      height: 45,
                      child: Center(
                        child: Text(
                          '$index',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: index <= 5
                                ? AppColors.emerald
                                : index <= 15
                                ? AppColors.white
                                : AppColors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 20 / 15,
                      color: AppColors.white,
                    ),
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      Image.asset(
                        'assets/images/flag.png',
                        height: 15,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        '${user.timesRankedFirst}',
                        style: TextStyle(
                          fontSize: 15,
                          height: 15 / 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${user.score} EXP',
            style: TextStyle(
              fontSize: 20,
              height: 20 / 15,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
