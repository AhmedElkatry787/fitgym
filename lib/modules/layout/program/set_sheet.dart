import 'dart:math' as math;

import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/services/app_controller.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:FitGym/model/exercise_model.dart';
import 'package:FitGym/model/set_entry_model.dart';
import 'package:FitGym/model/workout_model.dart';
import 'package:FitGym/modules/layout/widgets/icon_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Null when dismissed. A null `set` means the user removed the set.
typedef SetSheetResult = ({SetEntryModel? set});

/// Opens set [index] of [item] today: a done set to edit or remove, otherwise
/// the next set to log. Returns true when a new set was logged.
Future<bool> editSet(BuildContext context, AppController app, WorkoutExerciseModel item, int index) async {
  final sets = app.setsFor(item.exercise);
  final editing = index < sets.length;

  final result = await showSetSheet(
    context,
    exercise: item.exercise,
    setNumber: editing ? index + 1 : sets.length + 1,
    initial: editing ? sets[index] : app.suggestedSet(item),
    canRemove: editing,
  );
  if (result == null) return false;

  final set = result.set;
  if (set == null) {
    app.removeSet(item.exercise, index);
  } else if (editing) {
    app.updateSet(item.exercise, index, set);
  } else {
    app.addSet(item.exercise, set);
    return true;
  }
  return false;
}

/// Asks for the weight and reps of one set.
Future<SetSheetResult?> showSetSheet(
  BuildContext context, {
  required ExerciseModel exercise,
  required int setNumber,
  required SetEntryModel initial,
  bool canRemove = false,
}) {
  return showModalBottomSheet<SetSheetResult>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => _SetSheet(exercise: exercise, setNumber: setNumber, initial: initial, canRemove: canRemove),
  );
}

class _SetSheet extends StatefulWidget {
  const _SetSheet({required this.exercise, required this.setNumber, required this.initial, required this.canRemove});

  final ExerciseModel exercise;
  final int setNumber;
  final SetEntryModel initial;
  final bool canRemove;

  @override
  State<_SetSheet> createState() => _SetSheetState();
}

class _SetSheetState extends State<_SetSheet> {
  late final _weight = TextEditingController(text: WorkoutService.formatWeight(widget.initial.weightKg));
  late final _reps = TextEditingController(text: '${widget.initial.reps}');
  String? _repsError;

  bool get _timed => widget.exercise.timed;

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  void _save() {
    final reps = _parse(_reps.text)?.round() ?? 0;
    if (reps <= 0) {
      setState(() => _repsError = _timed ? 'اكتب عدد الثواني' : 'اكتب عدد العدّات');
      return;
    }
    final kg = math.max(0.0, _parse(_weight.text) ?? 0);
    Navigator.pop(context, (set: SetEntryModel(weightKg: kg, reps: reps)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 18,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.outline, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Column(
                spacing: 2,
                children: [
                  Text(widget.exercise.name, style: AppTextStyles.sectionTitle, textAlign: TextAlign.center),
                  Text('المجموعة ${widget.setNumber}', style: AppTextStyles.caption),
                ],
              ),
              _NumberField(
                name: 'الوزن',
                label: widget.exercise.bodyweight ? 'وزن زيادة (كجم) · 0 لوزن الجسم' : 'الوزن (كجم)',
                controller: _weight,
                step: 2.5,
                decimals: true,
              ),
              _NumberField(
                name: _timed ? 'الوقت' : 'العدّات',
                label: _timed ? 'الوقت (ثانية)' : 'العدّات',
                controller: _reps,
                step: _timed ? 5 : 1,
                decimals: false,
                error: _repsError,
                onChanged: () => setState(() => _repsError = null),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: AppTextStyles.body(16, fontWeight: FontWeight.w700),
                ),
                onPressed: _save,
                child: const Text('حفظ المجموعة'),
              ),
              if (widget.canRemove)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context, (set: null)),
                  child: Text('شيل المجموعة', style: AppTextStyles.body(14, color: AppColors.textSecondary)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A number box with − and + on each side.
class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.name,
    required this.label,
    required this.controller,
    required this.step,
    required this.decimals,
    this.error,
    this.onChanged,
  });

  /// Short name for the buttons' screen-reader labels.
  final String name;
  final String label;
  final TextEditingController controller;
  final double step;
  final bool decimals;
  final String? error;
  final VoidCallback? onChanged;

  void _add(double delta) {
    final value = math.max(0.0, (_parse(controller.text) ?? 0) + delta);
    controller.text = decimals ? WorkoutService.formatWeight(value) : '${value.round()}';
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        Row(
          spacing: 12,
          children: [
            IconBox(
              icon: Assets.icons.plus,
              background: AppColors.surfaceRaised,
              iconColor: AppColors.primary,
              size: 52,
              label: 'زوّد $name',
              onPressed: () => _add(step),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.numberWithOptions(decimal: decimals),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(decimals ? r'[0-9٠-٩۰-۹.,٫]' : r'[0-9٠-٩۰-۹]'))],
                onChanged: (_) => onChanged?.call(),
                style: AppTextStyles.display(32),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceRaised,
                  isDense: true,
                  errorText: error,
                  errorStyle: AppTextStyles.body(12, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
            ),
            IconBox(
              icon: Assets.icons.minus,
              background: AppColors.surfaceRaised,
              iconColor: AppColors.primary,
              size: 52,
              label: 'قلّل $name',
              onPressed: () => _add(-step),
            ),
          ],
        ),
      ],
    );
  }
}

/// Reads a number typed with Western or Arabic digits and `.`, `,` or `٫`.
double? _parse(String text) {
  final western = text.trim().replaceAllMapped(RegExp('[٠-٩۰-۹]'), (match) {
    final code = match[0]!.codeUnitAt(0);
    return '${code >= 0x06F0 ? code - 0x06F0 : code - 0x0660}';
  });
  return double.tryParse(western.replaceAll(RegExp('[,٫]'), '.'));
}
