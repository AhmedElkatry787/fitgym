import 'package:FitGym/core/app_routes/app_routes.dart';
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
import 'package:FitGym/modules/layout/program/set_sheet.dart';
import 'package:FitGym/modules/layout/widgets/app_surface.dart';
import 'package:FitGym/modules/layout/widgets/check_circle.dart';
import 'package:FitGym/modules/layout/widgets/icon_box.dart';
import 'package:FitGym/modules/layout/widgets/rest_timer.dart';
import 'package:FitGym/modules/layout/widgets/section_header.dart';
import 'package:FitGym/modules/layout/widgets/set_chip.dart';
import 'package:FitGym/modules/layout/widgets/sets_label.dart';
import 'package:FitGym/modules/layout/widgets/tab_page.dart';
import 'package:flutter/material.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  final _rest = RestTimer();

  @override
  void dispose() {
    _rest.dispose();
    super.dispose();
  }

  /// A done set opens for editing; any other circle logs the next set.
  /// Logging a set starts the rest.
  Future<void> _openSet(AppController app, WorkoutExerciseModel item, int index) async {
    final logged = await editSet(context, app, item, index);
    if (!logged || !mounted) return;
    app.activeComplete ? _rest.reset() : _rest.start();
  }

  void _openExercise(ExerciseModel exercise) {
    Navigator.pushNamed(context, AppRoutes.exerciseDetails, arguments: exercise);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final workout = app.activeWorkout;
    final extras = app.extraExercisesToday;

    return TabPage(
      spacing: 14,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text('برنامج التمرين', style: AppTextStyles.pageTitle),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: app.isRestDay ? 'النهارده راحة ·' : 'اليوم:',
                            style: AppTextStyles.body(13, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          TextSpan(
                            text: app.isRestDay
                                ? ' الجاي يوم ${WorkoutService.dayName(app.nextWorkout.day)}: ${workout.title}'
                                : ' ${workout.title}',
                          ),
                        ],
                      ),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              IconBox(
                icon: Assets.icons.dumbbell,
                background: AppColors.surface,
                iconColor: AppColors.primary,
                iconSize: 24,
              ),
            ],
          ),
        ),
        for (final item in workout.exercises)
          _ProgramExerciseCard(
            item: item,
            sets: app.setsFor(item.exercise),
            previous: app.previousSession(item.exercise),
            onSetTap: (index) => _openSet(app, item, index),
            onTap: () => _openExercise(item.exercise),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: app.activeComplete ? const DoneBar(text: 'خلّصت تمرين النهارده') : RestBar(timer: _rest),
        ),
        if (extras.isNotEmpty) ...[
          const Padding(padding: EdgeInsets.only(top: 8), child: SectionHeader(title: 'زيادة النهارده')),
          for (final exercise in extras)
            _ExtraExerciseTile(
              exercise: exercise,
              sets: app.setsFor(exercise),
              onTap: () => _openExercise(exercise),
            ),
        ],
      ],
    );
  }
}

/// An exercise trained today outside the plan.
class _ExtraExerciseTile extends StatelessWidget {
  const _ExtraExerciseTile({required this.exercise, required this.sets, required this.onTap});

  final ExerciseModel exercise;
  final List<SetEntryModel> sets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      borderColor: AppColors.surfaceRaised,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(child: Text(exercise.name, style: AppTextStyles.body(15, fontWeight: FontWeight.w700))),
              Text(exercise.muscle.label, style: AppTextStyles.caption),
            ],
          ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [for (final set in sets) SetChip(set: set, exercise: exercise)],
          ),
        ],
      ),
    );
  }
}

class _ProgramExerciseCard extends StatelessWidget {
  const _ProgramExerciseCard({
    required this.item,
    required this.sets,
    required this.previous,
    required this.onSetTap,
    required this.onTap,
  });

  final WorkoutExerciseModel item;

  /// Sets finished today.
  final List<SetEntryModel> sets;

  /// The last session before today, to beat.
  final ExerciseSessionModel? previous;
  final ValueChanged<int> onSetTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exercise = item.exercise;
    final previous = this.previous;

    return AppSurface(
      borderColor: AppColors.surfaceRaised,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      semanticLabel: 'تقدّم ${exercise.name}',
      child: Row(
        spacing: 14,
        children: [
          Column(
            spacing: 6,
            children: [
              for (var index = 0; index < item.sets; index++)
                _SetToggle(number: index + 1, done: index < sets.length, onTap: () => onSetTap(index)),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(exercise.name, style: AppTextStyles.body(15, fontWeight: FontWeight.w700)),
                SetsLabel(item.label),
                if (sets.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [for (final set in sets) SetChip(set: set, exercise: exercise)],
                  ),
                if (previous != null)
                  Text(
                    'المرة اللي فاتت: ${WorkoutService.formatSet(previous.topSet, exercise)}',
                    style: AppTextStyles.body(12, color: AppColors.textSecondary),
                  )
                else if (sets.isEmpty)
                  Text(
                    'دوس على الدايرة وسجّل الوزن',
                    style: AppTextStyles.body(12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
              ],
            ),
          ),
          Container(
            width: 84,
            height: 66,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(12)),
            child: AppIcon(Assets.icons.person, color: AppColors.textSecondary, size: 34),
          ),
        ],
      ),
    );
  }
}

class _SetToggle extends StatelessWidget {
  const _SetToggle({required this.number, required this.done, required this.onTap});

  final int number;
  final bool done;
  final VoidCallback onTap;

  static const _size = 22.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: done,
      label: 'المجموعة $number',
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: done
            ? const CheckCircle(size: _size, iconSize: 13)
            : Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outline, width: 2),
                ),
              ),
      ),
    );
  }
}
