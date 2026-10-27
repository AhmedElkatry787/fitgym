import 'dart:math' as math;

import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/services/app_controller.dart';
import 'package:FitGym/core/services/app_scope.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:FitGym/model/muscle.dart';
import 'package:FitGym/model/week_day_model.dart';
import 'package:FitGym/modules/layout/layout_screen.dart';
import 'package:FitGym/modules/layout/widgets/app_surface.dart';
import 'package:FitGym/modules/layout/widgets/check_circle.dart';
import 'package:FitGym/modules/layout/widgets/section_header.dart';
import 'package:FitGym/modules/layout/widgets/tab_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return TabPage(
      spacing: 22,
      children: [
        Text('دفتر التمرين', style: AppTextStyles.pageTitle),
        _TodayWorkoutCard(app: app, onStart: () => LayoutScreen.of(context).openProgram()),
        _WeekSection(week: app.week, doneDays: app.weekDoneDays, plannedDays: app.weekPlannedDays),
        _MusclesSection(
          onSelect: (muscle) => LayoutScreen.of(context).openExercises(muscle: muscle),
          onShowAll: () => LayoutScreen.of(context).openMuscles(),
        ),
      ],
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({required this.app, required this.onStart});

  final AppController app;
  final VoidCallback onStart;

  String get _subtitle {
    final workout = app.activeWorkout;
    final exercises = WorkoutService.exercisesCountLabel(workout.exercises.length);
    final done = app.activeDoneSets;

    if (app.isRestDay) return 'التمرين الجاي يوم ${WorkoutService.dayName(app.nextWorkout.day)} · $exercises';
    if (done == 0) return '$exercises · حوالي ${workout.durationMinutes} دقيقة';
    if (!app.activeComplete) return 'خلّصت $done من ${workout.totalSets} مجموعة';
    return 'خلّصت التمرين كله';
  }

  String get _buttonLabel {
    if (app.activeDoneSets == 0) return 'ابدأ التمرين';
    return app.activeComplete ? 'شوف التمرين' : 'كمّل التمرين';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          Positioned(
            left: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background.withValues(alpha: 0.08), width: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        app.isRestDay ? 'النهارده راحة' : 'تمرين النهارده',
                        style: AppTextStyles.body(13, fontWeight: FontWeight.w600, color: AppColors.background),
                      ),
                    ),
                    AppIcon(Assets.icons.dumbbell, color: AppColors.background, size: 34),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      app.activeWorkout.title,
                      style: AppTextStyles.display(32, color: AppColors.background, height: 1.15),
                    ),
                    Text(
                      _subtitle,
                      style: AppTextStyles.body(14, fontWeight: FontWeight.w500, color: AppColors.surface),
                    ),
                  ],
                ),
                AppSurface(
                  color: AppColors.background,
                  radius: 16,
                  onTap: onStart,
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          _buttonLabel,
                          style: AppTextStyles.body(16, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        AppIcon(Assets.icons.playReverse, color: AppColors.primary, size: 18),
                      ],
                    ),
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

class _WeekSection extends StatelessWidget {
  const _WeekSection({required this.week, required this.doneDays, required this.plannedDays});

  final List<WeekDayModel> week;
  final int doneDays;
  final int plannedDays;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        SectionHeader(
          title: 'أسبوعك',
          trailing: Text('$doneDays من $plannedDays أيام', style: AppTextStyles.caption),
        ),
        Row(
          spacing: 6,
          children: [
            for (final day in week) Expanded(child: _DayCell(day: day)),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day});

  final WeekDayModel day;

  @override
  Widget build(BuildContext context) {
    final isToday = day.isToday;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isToday ? AppColors.surfaceRaised : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        // Every cell gets the border so today's cell isn't taller than the rest.
        border: Border.all(color: isToday ? AppColors.primary : Colors.transparent, width: 1.5),
      ),
      child: Column(
        spacing: 8,
        children: [
          Text(
            day.name,
            maxLines: 1,
            style: AppTextStyles.body(
              11,
              color: isToday ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          _DayIndicator(status: day.status),
        ],
      ),
    );
  }
}

class _DayIndicator extends StatelessWidget {
  const _DayIndicator({required this.status});

  final DayStatus status;

  static const _size = 26.0;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      DayStatus.done => const CheckCircle(size: _size, iconSize: 14),
      DayStatus.today => Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
      ),
      DayStatus.planned || DayStatus.missed => Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outline, width: 2),
        ),
      ),
      DayStatus.rest => const CustomPaint(
        size: Size.square(_size),
        painter: _DashedCirclePainter(color: AppColors.outline),
      ),
    };
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  static const _strokeWidth = 2.0;
  static const _dashes = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final rect = (Offset.zero & size).deflate(_strokeWidth / 2);
    const step = 2 * math.pi / _dashes;

    for (var i = 0; i < _dashes; i++) {
      canvas.drawArc(rect, i * step, step * 0.6, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) => oldDelegate.color != color;
}

class _MusclesSection extends StatelessWidget {
  const _MusclesSection({required this.onSelect, required this.onShowAll});

  final ValueChanged<Muscle> onSelect;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        SectionHeader(
          title: 'اختار عضلة',
          trailing: TextButton(
            onPressed: onShowAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'عرض الكل',
              style: AppTextStyles.body(13, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ),
        Row(
          spacing: 10,
          children: [
            for (final muscle in WorkoutService.homeMuscles)
              Expanded(child: _MuscleCard(muscle: muscle, onTap: () => onSelect(muscle))),
          ],
        ),
      ],
    );
  }
}

class _MuscleCard extends StatelessWidget {
  const _MuscleCard({required this.muscle, required this.onTap});

  final Muscle muscle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      borderColor: AppColors.surfaceRaised,
      onTap: onTap,
      child: SizedBox(
        height: 74,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            Text(muscle.label, style: AppTextStyles.body(15, fontWeight: FontWeight.w700)),
            Text(
              WorkoutService.exercisesCountLabel(WorkoutService.exercisesFor(muscle).length),
              style: AppTextStyles.body(11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
