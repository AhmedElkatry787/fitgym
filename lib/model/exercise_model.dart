import 'package:FitGym/model/muscle.dart';

class ExerciseModel {
  const ExerciseModel({required this.id, required this.name, required this.muscle, this.featured = false});

  /// Stable key used when saving progress. Never change it once released.
  final String id;
  final String name;
  final Muscle muscle;
  final bool featured;
}
