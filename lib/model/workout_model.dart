import 'package:FitGym/model/exercise_model.dart';

class WorkoutExerciseModel {
  const WorkoutExerciseModel({required this.exercise, required this.sets, required this.reps});

  final ExerciseModel exercise;
  final int sets;

  /// Rep range, e.g. `10-12`.
  final String reps;

  /// e.g. `3 × 10-12`. Render it left-to-right so the numbers keep their order.
  String get label => '$sets × $reps';
}

class WorkoutModel {
  const WorkoutModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.exercises,
  });

  /// Stable key used when saving progress. Never change it once released.
  final String id;
  final String title;
  final int durationMinutes;
  final List<WorkoutExerciseModel> exercises;

  int get totalSets => exercises.fold(0, (total, item) => total + item.sets);
}
