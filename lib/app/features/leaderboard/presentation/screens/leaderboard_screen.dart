import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/providers/leaderboard_provider.dart';

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
      ref.read(leaderboardProvider.notifier).initStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(leaderboardProvider);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30),
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
                        leaderboardState.currentStatus?.title ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Spin(
                            infinite: true,
                            child: SvgPicture.asset(
                              'assets/icons/clock.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.orange,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Text(
                            '${leaderboardState.daysTillSunday} DÍAS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
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
                          final status = leaderboardState.status[index];
                          return SvgPicture.asset(
                            leaderboardState.currentStatus == status ||
                                    leaderboardState.status.indexOf(status) <
                                        leaderboardState.status.indexOf(
                                          leaderboardState.currentStatus!,
                                        )
                                ? status.activePath
                                : status.inactivePath,
                            width: 75,
                            height: 75,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 20);
                        },
                        itemCount: leaderboardState.status.length,
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
                      SliverPadding(padding: const EdgeInsets.only(top: 20)),
                      SliverList.separated(
                        itemBuilder: (context, index) {
                          final user = leaderboardState.users[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 20,
                            children: [
                              _UserRow(
                                leaderboardState: leaderboardState,
                                user: user,
                              ),
                              if (user.rank == 5)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 15,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/arrow-up.svg',
                                      width: 32,
                                      height: 32,
                                    ),
                                    Text(
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
                              if (user.rank == 15)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 15,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/arrow-down.svg',
                                      width: 32,
                                      height: 32,
                                    ),
                                    Text(
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
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 20);
                        },
                        itemCount: 20,
                      ),
                      SliverPadding(padding: const EdgeInsets.only(bottom: 20)),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.leaderboardState, required this.user});

  final LeaderboardState leaderboardState;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: leaderboardState.currentUser == user
            ? AppColors.selector
            : Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 20,
              children: [
                user.rank <= 3
                    ? SvgPicture.asset(
                        'assets/icons/${user.rank == 1
                            ? 'gold-medal'
                            : user.rank == 2
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
                            user.rank.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: user.rank <= 5
                                  ? AppColors.emerald
                                  : user.rank <= 15
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
                          user.timesRankedFirst.toString(),
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
      ),
    );
  }
}
