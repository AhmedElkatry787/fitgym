enum Muscle {
  chest('صدر', '10-12'),
  back('ظهر', '12-15'),
  legs('رجل', '8-10'),
  arms('دراع', '10-12'),
  shoulders('كتف', '10-12'),
  abs('بطن', '15-20');

  const Muscle(this.label, this.reps);

  final String label;

  /// Suggested rep range when training this muscle, 3 sets each.
  final String reps;

  String get setsLabel => '3 × $reps';
}
