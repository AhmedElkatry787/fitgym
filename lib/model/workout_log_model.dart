/// What was done on one day. Saved on the device as JSON.
class WorkoutLogModel {
  const WorkoutLogModel({
    required this.date,
    required this.workoutId,
    this.doneSets = const {},
    this.weights = const {},
  });

  /// `yyyy-MM-dd`.
  final String date;
  final String workoutId;

  /// Exercise id → sets done.
  final Map<String, int> doneSets;

  /// Exercise id → weight lifted in kg.
  final Map<String, double> weights;

  WorkoutLogModel copyWith({Map<String, int>? doneSets, Map<String, double>? weights}) {
    return WorkoutLogModel(
      date: date,
      workoutId: workoutId,
      doneSets: doneSets ?? this.doneSets,
      weights: weights ?? this.weights,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'workoutId': workoutId,
    'doneSets': doneSets,
    'weights': weights,
  };

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    final doneSets = json['doneSets'] as Map<String, dynamic>? ?? {};
    final weights = json['weights'] as Map<String, dynamic>? ?? {};

    return WorkoutLogModel(
      date: json['date'] as String,
      workoutId: json['workoutId'] as String,
      doneSets: doneSets.map((id, sets) => MapEntry(id, (sets as num).toInt())),
      weights: weights.map((id, kg) => MapEntry(id, (kg as num).toDouble())),
    );
  }
}
