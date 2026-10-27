import 'package:FitGym/model/exercise_model.dart';

class PersonalRecordModel {
  const PersonalRecordModel({required this.exercise, required this.weightKg, this.gainKg});

  final ExerciseModel exercise;
  final double weightKg;

  /// How much higher than the best before it; null for a first entry.
  final double? gainKg;
}
