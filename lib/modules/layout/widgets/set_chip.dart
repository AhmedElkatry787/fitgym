import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:FitGym/model/exercise_model.dart';
import 'package:FitGym/model/set_entry_model.dart';
import 'package:flutter/material.dart';

/// A small `60×10` tag for one finished set.
class SetChip extends StatelessWidget {
  const SetChip({super.key, required this.set, required this.exercise, this.highlighted = false});

  final SetEntryModel set;
  final ExerciseModel exercise;

  /// Yellow, for the best set.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary : AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        WorkoutService.formatSet(set, exercise),
        style: AppTextStyles.body(
          12,
          fontWeight: FontWeight.w600,
          color: highlighted ? AppColors.background : AppColors.textPrimary,
        ),
      ),
    );
  }
}
