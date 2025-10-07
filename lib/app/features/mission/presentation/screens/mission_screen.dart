import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/mission/presentation/providers/mission_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/time_widget.dart';

class MissionScreen extends ConsumerStatefulWidget {
  const MissionScreen({super.key});

  @override
  MissionScreenState createState() => MissionScreenState();
}

class MissionScreenState extends ConsumerState<MissionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;
    final missionState = ref.watch(missionProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- HEADER / RECOMPENSA MENSUAL ---
          SliverToBoxAdapter(
            child: Container(
              height: 300 + safeAreaPadding.top,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 30 + safeAreaPadding.top,
              ),
              decoration: BoxDecoration(color: AppColors.orange),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  // Header superior
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 120,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            missionState.currentMonth.isNotEmpty
                                ? missionState.currentMonth
                                : "Sin mes",
                            style: TextStyle(
                              fontSize: 20,
                              height: 20 / 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange,
                            ),
                          ),
                        ),
                      ),
                      TimeWidget(
                        time: missionState.timeLeftUntilNextMonth?.time ?? 0,
                        unit: missionState.timeLeftUntilNextMonth?.unit ?? '',
                        color: AppColors.purple,
                      ),
                    ],
                  ),

                  // Recompensa mensual
                  if (missionState.monthlyReward != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        Text(
                          missionState.monthlyReward!.description,
                          style: TextStyle(
                            fontSize: 20,
                            height: 20 / 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: GoalWidget(
                            current: missionState.monthlyReward!.currentPoints,
                            total: missionState.monthlyReward!.totalPoints,
                            imagePath: ref
                                .read(missionProvider.notifier)
                                .getRewardImage(
                                  missionState.monthlyReward!.category,
                                ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: Center(
                        child: Stack(
                          children: [
                            Text(
                              "No hay desafío mensual",
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
                              "No hay desafío mensual",
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
                      ),
                    ),
                ],
              ),
            ),
          ),

          // --- RECOMPENSA SEMANAL ---
          missionState.weeklyReward != null
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            const Text(
                              'Desafíos de la semana',
                              style: TextStyle(
                                fontSize: 24,
                                height: 24 / 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            TimeWidget(
                              time:
                                  missionState.timeLeftUntilNextWeek?.time ?? 0,
                              unit:
                                  missionState.timeLeftUntilNextWeek?.unit ??
                                  '',
                              color: AppColors.orange,
                              fontSize: 15,
                              showTheTextComplete: true,
                            ),
                          ],
                        ),
                        Container(
                          height: 120,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppColors.orange,
                              width: 2,
                            ),
                          ),
                          child: GoalWidget(
                            current: missionState.weeklyReward!.currentPoints,
                            total: missionState.weeklyReward!.totalPoints,
                            imagePath: ref
                                .read(missionProvider.notifier)
                                .getRewardImage(
                                  missionState.weeklyReward!.category,
                                ),
                            label: missionState.weeklyReward!.description,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: Center(
                      child: Stack(
                        children: [
                          Text(
                            "No hay desafío semanal",
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
                            "No hay desafío semanal",
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
                    ),
                  ),
                ),

          // --- RECOMPENSAS DIARIAS ---
          missionState.dailyRewards.isNotEmpty
              ? SliverPadding(
                  padding: const EdgeInsets.only(bottom: 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final reward = missionState.dailyRewards[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 20,
                          children: [
                            if (index == 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 5,
                                children: [
                                  const Text(
                                    'Desafíos del día',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  TimeWidget(
                                    time:
                                        missionState
                                            .timeLeftUntilNextDay
                                            ?.time ??
                                        0,
                                    unit:
                                        missionState
                                            .timeLeftUntilNextDay
                                            ?.unit ??
                                        '',
                                    color: AppColors.orange,
                                    fontSize: 15,
                                    showTheTextComplete: true,
                                  ),
                                ],
                              ),
                            Container(
                              height: 120,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDark,
                                borderRadius: BorderRadius.only(
                                  topLeft: index == 0
                                      ? Radius.circular(15)
                                      : Radius.zero,
                                  topRight: index == 0
                                      ? Radius.circular(15)
                                      : Radius.zero,
                                  bottomLeft: index == 2
                                      ? Radius.circular(15)
                                      : Radius.zero,
                                  bottomRight: index == 2
                                      ? Radius.circular(15)
                                      : Radius.zero,
                                ),
                                border: Border(
                                  top: index == 0
                                      ? BorderSide(
                                          color: AppColors.orange,
                                          width: 2,
                                        )
                                      : BorderSide.none,
                                  bottom: BorderSide(
                                    color: AppColors.orange,
                                    width: 2,
                                  ),
                                  left: BorderSide(
                                    color: AppColors.orange,
                                    width: 2,
                                  ),
                                  right: BorderSide(
                                    color: AppColors.orange,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: GoalWidget(
                                current: reward.currentPoints,
                                total: reward.totalPoints,
                                imagePath: ref
                                    .read(missionProvider.notifier)
                                    .getRewardImage(reward.category),
                                label: reward.description,
                              ),
                            ),
                          ],
                        ),
                      );
                    }, childCount: missionState.dailyRewards.length),
                  ),
                )
              : SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: Center(
                      child: Stack(
                        children: [
                          Text(
                            "No hay desafíos diarios",
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
                            "No hay desafíos diarios",
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
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class GoalWidget extends StatelessWidget {
  const GoalWidget({
    super.key,
    required this.current,
    required this.total,
    required this.imagePath,
    this.label = '',
  });

  final int current;
  final int total;
  final String imagePath;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Evitar división por cero
    if (total <= 0) {
      return const Center(
        child: Text(
          "Progreso no disponible",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth - 28;
        final progressWidth = (current / total) * containerWidth;
        final minProgressWidth = containerWidth * 0.04;
        final stackHeight = 46.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            if (label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  height: 14 / 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            SizedBox(
              height: stackHeight,
              width: constraints.maxWidth,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Fondo de barra
                  Container(
                    height: 30,
                    width: containerWidth,
                    decoration: BoxDecoration(
                      color: AppColors.selector,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$current / $total',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 16 / 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                  ),

                  // Progreso
                  Container(
                    width: (current < total * 0.04 && current != 0
                        ? minProgressWidth
                        : progressWidth),
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                      ),
                    ),
                  ),

                  // Ícono
                  Positioned(
                    right: 0,
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: SvgPicture.asset(imagePath, width: 56, height: 56),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
