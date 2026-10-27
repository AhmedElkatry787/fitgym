import 'dart:math' as math;

import 'package:FitGym/core/app_routes/app_routes.dart';
import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/services/app_scope.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:FitGym/model/personal_record_model.dart';
import 'package:FitGym/model/week_day_model.dart';
import 'package:FitGym/modules/layout/widgets/app_surface.dart';
import 'package:FitGym/modules/layout/widgets/section_header.dart';
import 'package:FitGym/modules/layout/widgets/stat_tile.dart';
import 'package:FitGym/modules/layout/widgets/tab_page.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final week = app.week;
    final minutes = app.weekMinutes;
    final records = app.topRecords;
    // A full hour reaches the usual bar height; longer days scale the rest down.
    final scaleMinutes = week.map((day) => day.minutes).fold(60, math.max);

    return TabPage(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text('التقدم', style: AppTextStyles.pageTitle),
            Text('الأسبوع ده', style: AppTextStyles.caption),
          ],
        ),
        AppSurface(
          radius: 22,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text('دقايق التمرين', style: AppTextStyles.body(15, fontWeight: FontWeight.w700)),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '$minutes', style: AppTextStyles.display(22, color: AppColors.primary)),
                        const TextSpan(text: ' دقيقة'),
                      ],
                    ),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              SizedBox(
                height: 160,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 8,
                  children: [
                    for (final day in week) Expanded(child: _DayBar(day: day, scaleMinutes: scaleMinutes)),
                  ],
                ),
              ),
            ],
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Expanded(
                child: StatTile(
                  icon: Assets.icons.flame,
                  value: '${app.streak}',
                  label: 'أيام متتالية',
                ),
              ),
              Expanded(
                child: StatTile(
                  icon: Assets.icons.dumbbell,
                  value: '${app.completedWorkouts}',
                  label: 'تمرين خلّصته',
                ),
              ),
              Expanded(
                child: StatTile(icon: Assets.icons.timer, value: _hours(minutes), label: 'ساعة الأسبوع ده'),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            const SectionHeader(title: 'أعلى أوزانك'),
            if (records.isEmpty)
              AppSurface(
                radius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Text(
                  'لسه مسجّلتش أوزان. في برنامج التمرين دوس على دايرة المجموعة وسجّل وزنك.',
                  style: AppTextStyles.caption,
                ),
              ),
            for (final record in records) _RecordTile(record: record),
          ],
        ),
      ],
    );
  }

  /// 210 → `3.5`, 240 → `4`.
  static String _hours(int minutes) {
    final hours = minutes / 60;
    return hours == hours.roundToDouble() ? '${hours.round()}' : hours.toStringAsFixed(1);
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.day, required this.scaleMinutes});

  final WeekDayModel day;

  /// Minutes that fill [_maxHeight].
  final int scaleMinutes;

  static const _maxHeight = 90.0;

  @override
  Widget build(BuildContext context) {
    final trained = day.minutes > 0;
    final Color barColor;
    if (day.isToday) {
      barColor = AppColors.primary;
    } else if (trained) {
      barColor = AppColors.outline;
    } else {
      barColor = AppColors.surfaceRaised;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 8,
      children: [
        Text(trained ? '${day.minutes}' : '-', style: AppTextStyles.body(11, color: AppColors.textSecondary)),
        Container(
          height: trained ? math.max(6, (day.minutes / scaleMinutes * _maxHeight).roundToDouble()) : 6,
          constraints: const BoxConstraints(maxWidth: 30),
          decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(8)),
        ),
        Text(
          day.name,
          maxLines: 1,
          style: AppTextStyles.body(
            11,
            color: day.isToday ? AppColors.primary : AppColors.textSecondary,
            fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final PersonalRecordModel record;

  @override
  Widget build(BuildContext context) {
    final gain = record.gainKg;

    return AppSurface(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => Navigator.pushNamed(context, AppRoutes.exerciseDetails, arguments: record.exercise),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(12)),
            child: AppIcon(Assets.icons.trophy, color: AppColors.primary, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 1,
              children: [
                Text(record.exercise.name, style: AppTextStyles.body(15, fontWeight: FontWeight.w600)),
                Text(record.exercise.muscle.label, style: AppTextStyles.body(12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              Text(
                '${WorkoutService.formatWeight(record.weightKg)} كجم',
                style: AppTextStyles.body(15, fontWeight: FontWeight.w700),
              ),
              if (gain != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    '+${WorkoutService.formatWeight(gain)}',
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.body(11, fontWeight: FontWeight.w700, color: AppColors.background),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
