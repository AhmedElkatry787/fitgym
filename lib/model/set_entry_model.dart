/// One finished set.
class SetEntryModel {
  const SetEntryModel({required this.weightKg, required this.reps});

  /// 0 means body weight only.
  final double weightKg;

  /// Reps, or seconds for a timed exercise. 0 when unknown (older saves).
  final int reps;

  Map<String, dynamic> toJson() => {'kg': weightKg, 'reps': reps};

  factory SetEntryModel.fromJson(Map<String, dynamic> json) {
    return SetEntryModel(weightKg: (json['kg'] as num).toDouble(), reps: (json['reps'] as num).toInt());
  }

  @override
  bool operator ==(Object other) => other is SetEntryModel && other.weightKg == weightKg && other.reps == reps;

  @override
  int get hashCode => Object.hash(weightKg, reps);
}
