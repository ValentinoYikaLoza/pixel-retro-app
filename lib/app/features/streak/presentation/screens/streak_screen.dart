import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/streak/domain/entities/streak_overview_entity.dart';
import 'package:pixel_retro_app/app/features/streak/presentation/providers/streak_provider.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_icon_button.dart';

/// Color del congelador (azul hielo) para diferenciarlo del fuego de la racha.
const Color _freezeColor = Color(0xFF4FC3F7);

/// Vista de la racha (estilo Duolingo): calendario de check-ins del mes, hitos
/// por racha consecutiva y metas mensuales reclamables. Se llega tocando el
/// ícono de fuego del app bar.
class StreakScreen extends ConsumerStatefulWidget {
  const StreakScreen({super.key});

  @override
  ConsumerState<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends ConsumerState<StreakScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrientationService.setOverlayColor(AppColors.neonPurple);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(streakProvider);
    final overview = state.overview;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            if (state.loading && overview == null)
              const Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              )
            else if (overview == null)
              const Center(
                child: Text(
                  'No se pudo cargar la racha',
                  style: TextStyle(color: AppColors.white, fontFamily: 'Inter'),
                ),
              )
            else
              RefreshIndicator(
                color: AppColors.orange,
                backgroundColor: AppColors.purple,
                onRefresh: () => ref.read(streakProvider.notifier).load(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 56, 16, 28),
                  children: [
                    _Header(overview: overview),
                    const SizedBox(height: 18),
                    _FreezeCard(overview: overview, busy: state.busy),
                    const SizedBox(height: 18),
                    _CalendarCard(overview: overview),
                    const SizedBox(height: 18),
                    const _SectionTitle('HITOS'),
                    const SizedBox(height: 10),
                    _Milestones(milestones: overview.milestones),
                    const SizedBox(height: 18),
                    const _SectionTitle('METAS DEL MES'),
                    const SizedBox(height: 10),
                    ...overview.goals.map(
                      (g) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _GoalCard(goal: g, busy: state.busy),
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              top: 4,
              left: 8,
              child: CustomIconButton(
                onPressed: () => AppRoutes.go(AppRoutes.home),
                width: 48,
                height: 48,
                imagePath: 'assets/icons/back.svg',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final StreakOverviewEntity overview;

  const _Header({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset('assets/icons/fire.svg', height: 76, width: 76),
        const SizedBox(height: 6),
        Stack(
          children: [
            Text(
              '${overview.streak}',
              style: TextStyle(
                fontSize: 64,
                height: 1,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pixel',
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 5
                  ..color = AppColors.red,
              ),
            ),
            Text(
              '${overview.streak}',
              style: const TextStyle(
                color: AppColors.orange,
                fontSize: 64,
                height: 1,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pixel',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          overview.streak == 1 ? 'día de racha' : 'días de racha',
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _FreezeCard extends ConsumerWidget {
  final StreakOverviewEntity overview;
  final bool busy;

  const _FreezeCard({required this.overview, required this.busy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _freezeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _freezeColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.ac_unit_rounded, color: _freezeColor, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Congeladores  ${overview.freezes}/${overview.maxFreezes}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Protegen tu racha si faltas un día.',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          _BuyFreezeButton(overview: overview, busy: busy),
        ],
      ),
    );
  }
}

class _BuyFreezeButton extends ConsumerWidget {
  final StreakOverviewEntity overview;
  final bool busy;

  const _BuyFreezeButton({required this.overview, required this.busy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = overview.canBuyFreeze && !busy;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled
            ? () => ref.read(streakProvider.notifier).buyFreeze()
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _freezeColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _freezeColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: AppColors.white, size: 16),
              const SizedBox(width: 2),
              SvgPicture.asset('assets/icons/coin.svg', height: 16, width: 16),
              const SizedBox(width: 4),
              Text(
                '${overview.freezeCost}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final StreakOverviewEntity overview;

  const _CalendarCard({required this.overview});

  static const _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final parts = overview.month.split('-');
    final year = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 2026;
    final mon = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 1;
    final firstWeekday = DateTime.utc(year, mon, 1).weekday; // 1=Lun..7=Dom
    final lead = firstWeekday - 1;
    final checked = overview.checkedInDays.toSet();

    final nowUtc = DateTime.now().toUtc();
    final todayDay = (nowUtc.year == year && nowUtc.month == mon)
        ? nowUtc.day
        : -1;

    // Celdas: blancos iniciales + días del mes, completadas a múltiplo de 7.
    final totalCells = lead + overview.daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.purple, AppColors.backgroundDark],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonPurple, width: 2),
      ),
      child: Column(
        children: [
          Text(
            '${_months[(mon - 1).clamp(0, 11)]} $year',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pixel',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _weekdays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          for (var r = 0; r < rows; r++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: _DayCell(
                        day: r * 7 + c - lead + 1,
                        daysInMonth: overview.daysInMonth,
                        checked: checked,
                        todayDay: todayDay,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final int daysInMonth;
  final Set<int> checked;
  final int todayDay;

  const _DayCell({
    required this.day,
    required this.daysInMonth,
    required this.checked,
    required this.todayDay,
  });

  @override
  Widget build(BuildContext context) {
    if (day < 1 || day > daysInMonth) {
      return const SizedBox(height: 38);
    }
    final isChecked = checked.contains(day);
    final isToday = day == todayDay;

    return SizedBox(
      height: 38,
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isChecked ? AppColors.orange.withValues(alpha: 0.9) : null,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: AppColors.white, width: 2)
                : Border.all(
                    color: AppColors.neonPurple.withValues(alpha: 0.25),
                    width: 1,
                  ),
          ),
          child: isChecked
              ? SvgPicture.asset('assets/icons/fire.svg', height: 20, width: 20)
              : Text(
                  '$day',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
        ),
      ),
    );
  }
}

class _Milestones extends StatelessWidget {
  final List<StreakMilestoneEntity> milestones;

  const _Milestones({required this.milestones});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final m in milestones)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: m.reached
                      ? AppColors.orange.withValues(alpha: 0.18)
                      : AppColors.purple.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: m.reached
                        ? AppColors.orange
                        : AppColors.neonPurple.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      m.reached
                          ? Icons.check_circle
                          : Icons.local_fire_department,
                      color: m.reached
                          ? AppColors.emerald
                          : AppColors.white.withValues(alpha: 0.7),
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${m.days} días',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/coin.svg',
                          height: 12,
                          width: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${m.rewardCoins}',
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final StreakGoalEntity goal;
  final bool busy;

  const _GoalCard({required this.goal, required this.busy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = (goal.progress / goal.daysRequired).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: goal.claimed
              ? AppColors.emerald.withValues(alpha: 0.6)
              : AppColors.neonPurple.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entra ${goal.daysRequired} días este mes',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.backgroundDark,
                    valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${goal.progress}/${goal.daysRequired} días',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const Spacer(),
                    _RewardLabel(goal: goal),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _ClaimButton(goal: goal, busy: busy),
        ],
      ),
    );
  }
}

class _RewardLabel extends StatelessWidget {
  final StreakGoalEntity goal;

  const _RewardLabel({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (goal.rewardCoins > 0) ...[
          SvgPicture.asset('assets/icons/coin.svg', height: 13, width: 13),
          const SizedBox(width: 2),
          Text(
            '${goal.rewardCoins}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
        ],
        if (goal.rewardFreezes > 0) ...[
          const Icon(Icons.ac_unit_rounded, color: _freezeColor, size: 13),
          const SizedBox(width: 2),
          Text(
            '${goal.rewardFreezes}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

class _ClaimButton extends ConsumerWidget {
  final StreakGoalEntity goal;
  final bool busy;

  const _ClaimButton({required this.goal, required this.busy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (goal.claimed) {
      return const Icon(Icons.check_circle, color: AppColors.emerald, size: 30);
    }
    final enabled = goal.claimable && !busy;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled
            ? () => ref.read(streakProvider.notifier).claimGoal(goal.id)
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.emerald
                : AppColors.gray.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: const Text(
            'RECLAMAR',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.white.withValues(alpha: 0.85),
        fontSize: 15,
        fontWeight: FontWeight.bold,
        fontFamily: 'Pixel',
        letterSpacing: 1,
      ),
    );
  }
}
