import 'package:FitGym/model/set_entry_model.dart';

/// What was done on one day. Saved on the device as JSON.
class WorkoutLogModel {
  const WorkoutLogModel({required this.date, required this.workoutId, this.sets = const {}});

  /// `yyyy-MM-dd`.
  final String date;

  /// The planned workout done that day; null when only picked exercises were
  /// trained on a rest day.
  final String? workoutId;

  /// Exercise id → its finished sets, in order.
  final Map<String, List<SetEntryModel>> sets;

  List<SetEntryModel> setsOf(String exerciseId) => sets[exerciseId] ?? const [];

  /// Finished sets across every exercise.
  int get totalSets => sets.values.fold(0, (total, entries) => total + entries.length);

  WorkoutLogModel withSets(String exerciseId, List<SetEntryModel> entries) {
    return WorkoutLogModel(date: date, workoutId: workoutId, sets: {...sets, exerciseId: entries});
  }

  WorkoutLogModel withWorkout(String id) => WorkoutLogModel(date: date, workoutId: id, sets: sets);

  Map<String, dynamic> toJson() => {
    'date': date,
    'workoutId': workoutId,
    'sets': sets.map((id, entries) => MapEntry(id, [for (final entry in entries) entry.toJson()])),
  };

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    final date = json['date'] as String;
    final workoutId = json['workoutId'] as String?;
    final sets = json['sets'] as Map<String, dynamic>?;

    if (sets != null) {
      return WorkoutLogModel(
        date: date,
        workoutId: workoutId,
        sets: sets.map(
          (id, entries) => MapEntry(id, [
            for (final entry in entries as List<dynamic>) SetEntryModel.fromJson(entry as Map<String, dynamic>),
          ]),
        ),
      );
    }

    // Saves from before sets had their own weight: a count of done sets and
    // one weight per exercise.
    final doneSets = json['doneSets'] as Map<String, dynamic>? ?? {};
    final weights = json['weights'] as Map<String, dynamic>? ?? {};
    return WorkoutLogModel(
      date: date,
      workoutId: workoutId,
      sets: doneSets.map((id, count) {
        final kg = (weights[id] as num?)?.toDouble() ?? 0;
        return MapEntry(id, List.filled((count as num).toInt(), SetEntryModel(weightKg: kg, reps: 0)));
      }),
    );
  }
}
