import 'package:FitGym/model/set_entry_model.dart';

/// Every set of one exercise on one day.
class ExerciseSessionModel {
  const ExerciseSessionModel({required this.date, required this.sets});

  final DateTime date;

  /// Never empty.
  final List<SetEntryModel> sets;

  /// The heaviest set; the one with more reps when two tie.
  SetEntryModel get topSet {
    return sets.reduce((best, set) {
      if (set.weightKg != best.weightKg) return set.weightKg > best.weightKg ? set : best;
      return set.reps > best.reps ? set : best;
    });
  }
}
