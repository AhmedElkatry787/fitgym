import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/services/app_controller.dart';
import 'package:FitGym/core/services/app_scope.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:FitGym/model/exercise_model.dart';
import 'package:FitGym/model/exercise_session_model.dart';
import 'package:FitGym/model/set_entry_model.dart';
import 'package:FitGym/model/workout_model.dart';
import 'package:FitGym/modules/layout/muscles/body_map.dart';
import 'package:FitGym/modules/layout/program/set_sheet.dart';
import 'package:FitGym/modules/layout/widgets/app_surface.dart';
import 'package:FitGym/modules/layout/widgets/check_circle.dart';
import 'package:FitGym/modules/layout/widgets/icon_box.dart';
import 'package:FitGym/modules/layout/widgets/rest_timer.dart';
import 'package:FitGym/modules/layout/widgets/section_header.dart';
import 'package:FitGym/modules/layout/widgets/set_chip.dart';
import 'package:FitGym/modules/layout/widgets/sets_label.dart';
import 'package:FitGym/modules/layout/widgets/stat_tile.dart';
import 'package:FitGym/modules/layout/widgets/tab_page.dart';
import 'package:flutter/material.dart';

/// One exercise: train it today, then see the muscle it works, where it is in
/// the weekly plan, and every session of it going up. Progress tracks the top
/// weight, or reps (seconds when timed) for an exercise only done with body
/// weight.
class ExerciseDetailsScreen extends StatefulWidget {
  const ExerciseDetailsScreen({super.key, required this.exercise});

  final ExerciseModel exercise;

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  /// Sessions shown in the chart.
  static const _chartSessions = 8;

  final _rest = RestTimer();

  ExerciseModel get exercise => widget.exercise;

  @override
  void dispose() {
    _rest.dispose();
    super.dispose();
  }

  /// Logging a set starts the rest, unless that was the last planned one.
  Future<void> _openSet(AppController app, WorkoutExerciseModel item, int index) async {
    final logged = await editSet(context, app, item, index);
    if (!logged || !mounted) return;
    app.doneSets(exercise) >= item.sets ? _rest.reset() : _rest.start();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final item = app.itemFor(exercise);
    final sessions = app.history(exercise);
    final weighted = sessions.any((session) => session.topSet.weightKg > 0);
    double valueOf(ExerciseSessionModel session) {
      return weighted ? session.topSet.weightKg : session.topSet.reps.toDouble();
    }

    final values = [for (final session in sessions) valueOf(session)];
    final unit = weighted ? 'كجم' : (exercise.timed ? 'ثانية' : 'عدّة');
    final metric = weighted ? 'أعلى وزن' : (exercise.timed ? 'أطول وقت' : 'أعلى عدّات');

    return TabPage(
      spacing: 16,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(exercise.name, style: AppTextStyles.pageTitle),
                  Text(exercise.muscle.label, style: AppTextStyles.caption),
                ],
              ),
            ),
            IconBox(
              icon: Assets.icons.arrowBack,
              background: AppColors.surface,
              iconColor: AppColors.textPrimary,
              label: 'رجوع',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        _TodayCard(
          item: item,
          sets: app.setsFor(exercise),
          previous: app.previousSession(exercise),
          rest: _rest,
          onSetTap: (index) => _openSet(app, item, index),
        ),
        _PlanCard(exercise: exercise),
        AppSurface(
          radius: 22,
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 40,
            children: [
              for (final (side, label) in [(BodySide.front, 'أمام'), (BodySide.back, 'خلف')])
                Column(
                  spacing: 8,
                  children: [
                    BodyMap(side: side, highlight: exercise.muscle),
                    Text(label, style: AppTextStyles.body(12, color: AppColors.textSecondary)),
                  ],
                ),
            ],
          ),
        ),
        const SectionHeader(title: 'تقدّمك'),
        if (sessions.isEmpty)
          AppSurface(
            radius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Text(
              'سجّل أول مجموعة وهتلاقي تقدّمك هنا: أعلى وزن، والفرق من أول مرة، وكل مرة اتمرنت فيها.',
              style: AppTextStyles.caption,
            ),
          )
        else ...[
          _Summary(values: values, metric: '$metric ($unit)'),
          _Chart(
            title: '$metric كل مرة',
            unit: unit,
            sessions: sessions.length > _chartSessions ? sessions.sublist(sessions.length - _chartSessions) : sessions,
            valueOf: valueOf,
          ),
          const SectionHeader(title: 'كل المرات'),
          for (final session in sessions.reversed) _SessionTile(exercise: exercise, session: session),
        ],
      ],
    );
  }
}

/// Today's sets of the exercise, a button for the next one, and the rest.
class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.item,
    required this.sets,
    required this.previous,
    required this.rest,
    required this.onSetTap,
  });

  /// How many sets to do, and the rep range.
  final WorkoutExerciseModel item;
  final List<SetEntryModel> sets;
  final ExerciseSessionModel? previous;
  final RestTimer rest;
  final ValueChanged<int> onSetTap;

  @override
  Widget build(BuildContext context) {
    final exercise = item.exercise;
    final previous = this.previous;
    final done = sets.length >= item.sets;
    final rows = done ? sets.length : item.sets;

    return AppSurface(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(child: Text('تمرين النهارده', style: AppTextStyles.body(16, fontWeight: FontWeight.w700))),
              SetsLabel(item.label),
            ],
          ),
          if (previous != null)
            Text(
              'المرة اللي فاتت: ${previous.sets.map((set) => WorkoutService.formatSet(set, exercise)).join(' · ')}',
              style: AppTextStyles.body(12, color: AppColors.textSecondary),
            ),
          for (var index = 0; index < rows; index++)
            _SetRow(
              number: index + 1,
              set: index < sets.length ? sets[index] : null,
              exercise: exercise,
              onTap: () => onSetTap(index),
            ),
          if (done) ...[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              onPressed: () => onSetTap(sets.length),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  AppIcon(Assets.icons.plus, color: AppColors.primary, size: 16),
                  Text(
                    'مجموعة زيادة',
                    style: AppTextStyles.body(14, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const DoneBar(text: 'خلّصت التمرين ده النهارده'),
          ] else ...[
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: AppTextStyles.body(16, fontWeight: FontWeight.w700),
              ),
              onPressed: () => onSetTap(sets.length),
              child: Text(sets.isEmpty ? 'ابدأ · سجّل المجموعة 1' : 'سجّل المجموعة ${sets.length + 1}'),
            ),
            if (sets.isNotEmpty) RestBar(timer: rest),
          ],
        ],
      ),
    );
  }
}

/// One set: its number, and its weight and reps once done.
class _SetRow extends StatelessWidget {
  const _SetRow({required this.number, required this.set, required this.exercise, required this.onTap});

  final int number;
  final SetEntryModel? set;
  final ExerciseModel exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final set = this.set;

    return AppSurface(
      color: AppColors.surfaceRaised,
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: onTap,
      semanticLabel: 'المجموعة $number',
      child: Row(
        spacing: 12,
        children: [
          if (set != null)
            const CheckCircle(size: 26, iconSize: 14)
          else
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outline, width: 2),
              ),
              child: Text('$number', style: AppTextStyles.body(12, color: AppColors.textSecondary)),
            ),
          Expanded(child: Text('المجموعة $number', style: AppTextStyles.body(14, fontWeight: FontWeight.w600))),
          Text(
            set == null ? 'سجّل' : WorkoutService.formatSet(set, exercise),
            style: AppTextStyles.body(
              14,
              fontWeight: FontWeight.w700,
              color: set == null ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Which day of the weekly plan has this exercise, or the suggested sets
/// when none does.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final planned = WorkoutService.plannedDaysFor(exercise);

    final String title;
    final String setsLabel;
    if (planned.isEmpty) {
      title = 'مش في برنامج الأسبوع · المقترح';
      setsLabel = exercise.muscle.setsLabel;
    } else {
      final days = planned.map((entry) => WorkoutService.dayNames[entry.day]).join(' و ');
      title = 'في برنامجك يوم $days · ${planned.first.workout.title}';
      setsLabel = planned.first.item.label;
    }

    return AppSurface(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(12)),
            child: AppIcon(Assets.icons.dumbbell, color: AppColors.primary, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(title, style: AppTextStyles.body(14, fontWeight: FontWeight.w600)),
                SetsLabel(setsLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.values, required this.metric});

  /// One per session, oldest first.
  final List<double> values;
  final String metric;

  @override
  Widget build(BuildContext context) {
    final best = values.reduce((a, b) => a > b ? a : b);
    final change = values.last - values.first;
    final String changeLabel;
    if (change > 0) {
      changeLabel = WorkoutService.ltr('+${WorkoutService.formatWeight(change)}');
    } else if (change < 0) {
      changeLabel = WorkoutService.ltr('-${WorkoutService.formatWeight(-change)}');
    } else {
      changeLabel = '0';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Expanded(
            child: StatTile(icon: Assets.icons.trophy, value: WorkoutService.formatWeight(best), label: metric),
          ),
          Expanded(
            child: StatTile(icon: Assets.icons.chart, value: changeLabel, label: 'الفرق من أول مرة'),
          ),
          Expanded(
            child: StatTile(icon: Assets.icons.dumbbell, value: '${values.length}', label: 'مرات اتمرنته'),
          ),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.title, required this.unit, required this.sessions, required this.valueOf});

  final String title;
  final String unit;

  /// Oldest first; drawn from the right, the way the app reads.
  final List<ExerciseSessionModel> sessions;
  final double Function(ExerciseSessionModel session) valueOf;

  static const _maxHeight = 90.0;

  @override
  Widget build(BuildContext context) {
    final values = [for (final session in sessions) valueOf(session)];
    final top = values.reduce((a, b) => a > b ? a : b);

    return AppSurface(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.body(15, fontWeight: FontWeight.w700)),
              Text(unit, style: AppTextStyles.caption),
            ],
          ),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
              children: [
                for (final (index, session) in sessions.indexed)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 8,
                      children: [
                        Text(
                          WorkoutService.formatWeight(values[index]),
                          maxLines: 1,
                          style: AppTextStyles.body(11, color: AppColors.textSecondary),
                        ),
                        Container(
                          height: top == 0 ? 6 : (values[index] / top * _maxHeight).clamp(6, _maxHeight),
                          constraints: const BoxConstraints(maxWidth: 30),
                          decoration: BoxDecoration(
                            color: index == sessions.length - 1 ? AppColors.primary : AppColors.outline,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Text(
                          WorkoutService.ltr('${session.date.day}/${session.date.month}'),
                          maxLines: 1,
                          style: AppTextStyles.body(11, color: AppColors.textSecondary),
                        ),
                      ],
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

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.exercise, required this.session});

  final ExerciseModel exercise;
  final ExerciseSessionModel session;

  @override
  Widget build(BuildContext context) {
    final top = session.topSet;

    return AppSurface(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(WorkoutService.dateLabel(session.date), style: AppTextStyles.body(14, fontWeight: FontWeight.w600)),
              Text(
                WorkoutService.setsCountLabel(session.sets.length),
                style: AppTextStyles.body(12, color: AppColors.textSecondary),
              ),
            ],
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final set in session.sets)
                SetChip(set: set, exercise: exercise, highlighted: session.sets.length > 1 && identical(set, top)),
            ],
          ),
        ],
      ),
    );
  }
}
