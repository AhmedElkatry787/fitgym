import 'dart:async';

import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/services/app_controller.dart';
import 'package:FitGym/core/services/app_scope.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:FitGym/model/workout_model.dart';
import 'package:FitGym/modules/layout/program/weight_sheet.dart';
import 'package:FitGym/modules/layout/widgets/app_surface.dart';
import 'package:FitGym/modules/layout/widgets/check_circle.dart';
import 'package:FitGym/modules/layout/widgets/icon_box.dart';
import 'package:FitGym/modules/layout/widgets/sets_label.dart';
import 'package:FitGym/modules/layout/widgets/tab_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  Duration _rest = WorkoutService.restDuration;
  Timer? _restTimer;

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  /// Tapping a set marks it and every set before it done; tapping a done set
  /// un-marks it and every set after it. Finishing a set starts the rest.
  void _toggleSet(AppController app, WorkoutExerciseModel item, int set) {
    final done = app.doneSets(item.exercise);
    final sets = set < done ? set : set + 1;
    app.setDoneSets(item.exercise, sets);

    if (app.activeComplete) {
      _stopRest();
    } else if (sets > done) {
      _startRest();
    }
  }

  Future<void> _editWeight(AppController app, WorkoutExerciseModel item) async {
    final kg = await showWeightSheet(
      context,
      exerciseName: item.exercise.name,
      initialKg: app.todayWeight(item.exercise) ?? app.lastWeight(item.exercise) ?? 20,
    );
    if (kg != null) app.setWeight(item.exercise, kg);
  }

  void _startRest() {
    _restTimer?.cancel();
    setState(() {
      _rest = WorkoutService.restDuration;
      _restTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickRest());
    });
  }

  void _toggleRest() {
    if (_restTimer != null) {
      _restTimer!.cancel();
      setState(() => _restTimer = null);
    } else if (_rest == Duration.zero) {
      _startRest();
    } else {
      setState(() => _restTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickRest()));
    }
  }

  void _tickRest() {
    setState(() {
      _rest -= const Duration(seconds: 1);
      if (_rest > Duration.zero) return;
      _rest = Duration.zero;
      _restTimer?.cancel();
      _restTimer = null;
    });
    if (_rest == Duration.zero) HapticFeedback.heavyImpact();
  }

  void _stopRest() {
    _restTimer?.cancel();
    setState(() {
      _restTimer = null;
      _rest = WorkoutService.restDuration;
    });
  }

  String get _restLabel {
    final seconds = (_rest.inSeconds % 60).toString().padLeft(2, '0');
    return '${_rest.inMinutes}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final workout = app.activeWorkout;

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
            doneSets: app.doneSets(item.exercise),
            weightKg: app.todayWeight(item.exercise),
            onSetTap: (set) => _toggleSet(app, item, set),
            onTap: () => _editWeight(app, item),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: app.activeComplete
              ? const _DoneBar()
              : _RestBar(
                  label: _restLabel,
                  running: _restTimer != null,
                  onToggle: _toggleRest,
                  onReset: _stopRest,
                ),
        ),
      ],
    );
  }
}

class _ProgramExerciseCard extends StatelessWidget {
  const _ProgramExerciseCard({
    required this.item,
    required this.doneSets,
    required this.weightKg,
    required this.onSetTap,
    required this.onTap,
  });

  final WorkoutExerciseModel item;
  final int doneSets;
  final double? weightKg;
  final ValueChanged<int> onSetTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final weight = weightKg;

    return AppSurface(
      borderColor: AppColors.surfaceRaised,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      semanticLabel: 'سجّل وزن ${item.exercise.name}',
      child: Row(
        spacing: 14,
        children: [
          Column(
            spacing: 6,
            children: [
              for (var set = 0; set < item.sets; set++)
                _SetToggle(number: set + 1, done: set < doneSets, onTap: () => onSetTap(set)),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(item.exercise.name, style: AppTextStyles.body(15, fontWeight: FontWeight.w700)),
                SetsLabel(item.label),
                Text(
                  weight == null ? 'سجّل الوزن' : '${WorkoutService.formatWeight(weight)} كجم',
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

class _RestBar extends StatelessWidget {
  const _RestBar({required this.label, required this.running, required this.onToggle, required this.onReset});

  final String label;
  final bool running;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(18)),
      child: Row(
        spacing: 12,
        children: [
          IconBox(
            icon: Assets.icons.close,
            background: AppColors.primary,
            iconColor: AppColors.background,
            iconSize: 14,
            size: 28,
            label: 'إلغاء الراحة',
            onPressed: onReset,
          ),
          Expanded(child: Text('الراحة', style: AppTextStyles.body(15, fontWeight: FontWeight.w600))),
          AppSurface(
            color: AppColors.primary,
            radius: 999,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onTap: onToggle,
            semanticLabel: running ? 'إيقاف الراحة' : 'ابدأ الراحة',
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.ltr,
                spacing: 6,
                children: [
                  AppIcon(running ? Assets.icons.pause : Assets.icons.play, color: AppColors.background, size: 14),
                  Text(
                    label,
                    style: AppTextStyles.body(15, fontWeight: FontWeight.w700, color: AppColors.background),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneBar extends StatelessWidget {
  const _DoneBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        spacing: 12,
        children: [
          const CheckCircle(size: 28, iconSize: 15),
          Expanded(
            child: Text('خلّصت تمرين النهارده', style: AppTextStyles.body(15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
