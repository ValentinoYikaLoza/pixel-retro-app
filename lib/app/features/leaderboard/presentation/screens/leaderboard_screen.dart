import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:pixel_retro_app/app/features/time/presentation/widgets/time_widget.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  LeaderboardScreenState createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(leaderboardProvider);
    final userState = ref.watch(userProvider);
    EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;

    final hasDivisions = leaderboardState.divisions.isNotEmpty;
    final hasUsers = leaderboardState.users.isNotEmpty;

    final currentDivision = leaderboardState.divisions.firstWhere(
      (division) => division.id == userState.divisionId,
    );

    return Scaffold(
      body: hasDivisions && hasUsers
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // --- HEADER ---
                Container(
                  padding: EdgeInsets.only(
                    top: 30 + safeAreaPadding.top,
                    bottom: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.orange, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 30,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentDivision.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            TimeWidget(
                              type: TimeWidgetType.timeUntilNextSeason,
                              color: AppColors.orange,
                            ),
                          ],
                        ),
                      ),
                      // --- Divisiones ---
                      SizedBox(
                        height: 75,
                        child: CustomScrollView(
                          scrollDirection: Axis.horizontal,
                          slivers: [
                            const SliverPadding(
                              padding: EdgeInsets.only(left: 20),
                            ),
                            SliverList.separated(
                              itemBuilder: (context, index) {
                                return SvgPicture.asset(
                                  ref
                                      .read(leaderboardProvider.notifier)
                                      .getDivisionImage(
                                        leaderboardState.divisions[index].id,
                                        userState.divisionId,
                                      ),
                                  width: 75,
                                  height: 75,
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 20),
                              itemCount: leaderboardState.divisions.length,
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.only(right: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- LISTA DE USUARIOS ---
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverList.builder(
                        itemBuilder: (context, index) {
                          final user = leaderboardState.users[index];
                          return Column(
                            spacing: 20,
                            children: [
                              UserRow(
                                isCurrentUser: userState.userId == user.id,
                                user: user,
                                index: index + 1,
                              ),
                              if (index + 1 == 5)
                                Separator(
                                  text: "ZONA DE ASCENSO",
                                  color: AppColors.emerald,
                                  icon: 'assets/icons/arrow-up.svg',
                                ),
                              if (index + 1 == 15)
                                Separator(
                                  text: "ZONA DE DESCENSO",
                                  color: AppColors.ruby,
                                  icon: 'assets/icons/arrow-down.svg',
                                ),
                            ],
                          );
                        },
                        itemCount: leaderboardState.users.length,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Stack(
                      children: [
                        Text(
                          "Las ligas no están disponibles\nen este momento",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pixel',
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = AppColors.orange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Las ligas no están disponibles\nen este momento",
                          style: TextStyle(
                            color: AppColors.purple,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pixel',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Text(
                      "Parece que estás offline. ¡Revisa tu conexión!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class Separator extends StatelessWidget {
  final String text;
  final Color color;
  final String icon;

  const Separator({
    super.key,
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 15,
        children: [
          SvgPicture.asset(icon, width: 32, height: 32),
          Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SvgPicture.asset(icon, width: 32, height: 32),
        ],
      ),
    );
  }
}

class UserRow extends StatelessWidget {
  const UserRow({
    super.key,
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
          Expanded(
            child: Row(
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
                Expanded(
                  child: Column(
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
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Text(
                            user.flag,
                            style: TextStyle(
                              fontSize: 15,
                              height: 15 / 15,
                              fontFamily: 'Noto',
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
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
                ),
              ],
            ),
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
