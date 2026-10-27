import 'package:FitGym/model/muscle.dart';

class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.name,
    required this.muscle,
    this.featured = false,
    this.bodyweight = false,
    this.timed = false,
  });

  /// Stable key used when saving progress. Never change it once released.
  final String id;
  final String name;
  final Muscle muscle;
  final bool featured;

  /// Usually done without extra weight, so new sets start at 0 kg.
  final bool bodyweight;

  /// Held for seconds instead of counted in reps.
  final bool timed;
}
