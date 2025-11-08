import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/mission/presentation/providers/mission_provider.dart';
import 'package:pixel_retro_app/app/features/time/presentation/providers/time_provider.dart';
import 'package:pixel_retro_app/app/features/time/presentation/widgets/time_widget.dart';
import 'package:pixel_retro_app/app/shared/providers/data_sync_provider.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';

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
    final timeState = ref.watch(timeProvider);
    final internetStatusState = ref.watch(internetStatusProvider);
    final dataAsyncStatusState = ref.watch(dataSyncProvider);

    final hasIntenetConnection = internetStatusState.value ?? false;
    final hasDataAsync = dataAsyncStatusState.syncStatus == SyncStatus.success;

    final hasDailyRewards = missionState.dailyRewards.isNotEmpty;
    final hasWeeklyReward = missionState.weeklyReward != null;
    final hasMonthlyReward = missionState.monthlyReward != null;

    return Scaffold(
      body:
          hasIntenetConnection &&
              hasDataAsync &&
              hasMonthlyReward &&
              hasWeeklyReward &&
              hasDailyRewards
          ? Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: safeAreaPadding.top),
                  decoration: BoxDecoration(color: AppColors.orange),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // --- HEADER / RECOMPENSA MENSUAL ---
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.only(
                            bottom: 30,
                            left: 20,
                            right: 20,
                            top: 30,
                          ),
                          decoration: BoxDecoration(color: AppColors.orange),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 20,
                            children: [
                              // Header superior
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        timeState.currentMonth,
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
                                    type: TimeWidgetType.timeUntilNextMonth,
                                    color: AppColors.purple,
                                  ),
                                ],
                              ),

                              // Recompensa mensual
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundDark,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: GoalWidget(
                                      current: missionState
                                          .monthlyReward!
                                          .currentPoints,
                                      total: missionState
                                          .monthlyReward!
                                          .totalPoints,
                                      imagePath: ref
                                          .read(missionProvider.notifier)
                                          .getRewardImage(
                                            missionState
                                                .monthlyReward!
                                                .category,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
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
                                    type: TimeWidgetType.timeUntilNextWeek,
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
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: AppColors.orange,
                                    width: 2,
                                  ),
                                ),
                                child: GoalWidget(
                                  current:
                                      missionState.weeklyReward!.currentPoints,
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
                      ),

                      // --- RECOMPENSAS DIARIAS ---
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 30),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final reward = missionState.dailyRewards[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 20,
                                children: [
                                  if (index == 0)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          type: TimeWidgetType.timeUntilNextDay,
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
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Stack(
                      children: [
                        Text(
                          "Las desafíos no están disponibles\nen este momento",
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
                          "Las desafíos no están disponibles\nen este momento",
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

class GoalWidget extends StatefulWidget {
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
  State<GoalWidget> createState() => _GoalWidgetState();
}

class _GoalWidgetState extends State<GoalWidget>
    with SingleTickerProviderStateMixin {
  double _iconOffset = 0; // 0 = normal, negativo = sube

  void _onTap() async {
    setState(() => _iconOffset = -36); // sube 12px
    await Future.delayed(const Duration(milliseconds: 240));
    setState(() => _iconOffset = 0); // vuelve
  }

  @override
  Widget build(BuildContext context) {
    if (widget.total <= 0) {
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
        final progressWidth = (widget.current / widget.total) * containerWidth;
        final minProgressWidth = containerWidth * 0.04;
        final containerHeight = constraints.maxHeight;
        final progressFactor = widget.current / widget.total;
        final adjustedFactor = (progressFactor < 0.04 && widget.current != 0)
            ? 0.04
            : progressFactor;

        return SizedBox(
          width: constraints.maxWidth,
          child: Stack(
            children: [
              Container(
                padding: widget.label.isNotEmpty
                    ? EdgeInsets.only(bottom: containerHeight * 0.2)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: widget.label.isNotEmpty
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.center,
                  spacing: 15,
                  children: [
                    // Label
                    if (widget.label.isNotEmpty)
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 14 / 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),

                    // barra de progreso
                    Stack(
                      children: [
                        // Fondo barra
                        Container(
                          height: 30,
                          width: containerWidth,
                          decoration: BoxDecoration(
                            color: AppColors.selector,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(11),
                              bottomLeft: Radius.circular(11),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${widget.current} / ${widget.total}',
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
                          height: 30,
                          width:
                              (widget.current < widget.total * 0.04 &&
                                  widget.current != 0
                              ? minProgressWidth
                              : progressWidth),
                          decoration: BoxDecoration(
                            color: AppColors.emerald,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(11),
                              bottomLeft: Radius.circular(11),
                            ),
                          ),
                        ),

                        ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: adjustedFactor,
                            child: SizedBox(
                              height: 30,
                              width: containerWidth,
                              child: Center(
                                child: Text(
                                  '${widget.current} / ${widget.total}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 16 / 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ícono con animación de salto
              GestureDetector(
                onTap: _onTap,
                child: Align(
                  alignment: widget.label.isNotEmpty
                      ? Alignment.bottomRight
                      : Alignment.centerRight,
                  child: AnimatedContainer(
                    padding: widget.label.isNotEmpty
                        ? EdgeInsets.only(bottom: containerHeight * 0.1)
                        : null,
                    duration: const Duration(milliseconds: 270),
                    curve: Curves.easeOutBack,
                    transform: Matrix4.translationValues(0, _iconOffset, 0),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: SvgPicture.asset(widget.imagePath),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
