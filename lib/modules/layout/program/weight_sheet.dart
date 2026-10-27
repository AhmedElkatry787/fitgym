import 'dart:math' as math;

import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:FitGym/modules/layout/widgets/icon_box.dart';
import 'package:flutter/material.dart';

/// Asks for the weight lifted on an exercise. Returns null when dismissed.
Future<double?> showWeightSheet(BuildContext context, {required String exerciseName, required double initialKg}) {
  return showModalBottomSheet<double>(
    context: context,
    useRootNavigator: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => _WeightSheet(exerciseName: exerciseName, initialKg: initialKg),
  );
}

class _WeightSheet extends StatefulWidget {
  const _WeightSheet({required this.exerciseName, required this.initialKg});

  final String exerciseName;
  final double initialKg;

  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  static const _step = 2.5;

  late double _kg = widget.initialKg;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.outline, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('وزن ${widget.exerciseName}', style: AppTextStyles.sectionTitle, textAlign: TextAlign.center),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconBox(
                  icon: Assets.icons.plus,
                  background: AppColors.surfaceRaised,
                  iconColor: AppColors.primary,
                  size: 52,
                  label: 'زوّد الوزن',
                  onPressed: () => setState(() => _kg += _step),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: WorkoutService.formatWeight(_kg), style: AppTextStyles.display(40)),
                      const TextSpan(text: ' كجم'),
                    ],
                  ),
                  style: AppTextStyles.caption,
                ),
                IconBox(
                  icon: Assets.icons.minus,
                  background: AppColors.surfaceRaised,
                  iconColor: AppColors.primary,
                  size: 52,
                  label: 'قلّل الوزن',
                  onPressed: _kg > 0 ? () => setState(() => _kg = math.max(0, _kg - _step)) : null,
                ),
              ],
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: AppTextStyles.body(16, fontWeight: FontWeight.w700),
              ),
              onPressed: () => Navigator.pop(context, _kg),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
