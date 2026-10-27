import 'package:FitGym/model/exercise_model.dart';
import 'package:FitGym/model/muscle.dart';
import 'package:FitGym/model/set_entry_model.dart';
import 'package:FitGym/model/workout_model.dart';

/// The fixed catalog: every exercise, the workouts, and which day each one is
/// on. What the user actually did lives in `AppController`.
class WorkoutService {
  static const restDuration = Duration(minutes: 2);

  /// Saturday first, the way the week is shown in the app.
  static const dayNames = ['سبت', 'أحد', 'اتنين', 'تلات', 'أربع', 'خميس', 'جمعة'];

  /// Muscles shown on the home screen.
  static const homeMuscles = [Muscle.chest, Muscle.back, Muscle.legs, Muscle.shoulders];

  // Chest
  static const benchPress = ExerciseModel(id: 'bench_press', name: 'ضغط بار مستوي', muscle: Muscle.chest);
  static const inclineDumbbellPress = ExerciseModel(
    id: 'incline_dumbbell_press',
    name: 'ضغط دمبل مائل',
    muscle: Muscle.chest,
    featured: true,
  );
  static const chestFly = ExerciseModel(id: 'chest_fly', name: 'تفتيح صدر', muscle: Muscle.chest);
  static const pushUp = ExerciseModel(id: 'push_up', name: 'ضغط أرضي', muscle: Muscle.chest, bodyweight: true);
  static const inclineBenchPress = ExerciseModel(id: 'incline_bench_press', name: 'ضغط بار مائل', muscle: Muscle.chest);
  static const declineBenchPress = ExerciseModel(id: 'decline_bench_press', name: 'ضغط بار مقلوب', muscle: Muscle.chest);
  static const dumbbellPress = ExerciseModel(id: 'dumbbell_press', name: 'ضغط دمبل مستوي', muscle: Muscle.chest);
  static const cableCrossover = ExerciseModel(id: 'cable_crossover', name: 'كروس أوفر كابل', muscle: Muscle.chest);
  static const pecDeck = ExerciseModel(id: 'pec_deck', name: 'تفتيح بالجهاز', muscle: Muscle.chest);
  static const chestDips = ExerciseModel(id: 'chest_dips', name: 'ديبس صدر', muscle: Muscle.chest, bodyweight: true);

  // Back
  static const deadlift = ExerciseModel(id: 'deadlift', name: 'سحب أرضي', muscle: Muscle.back);
  static const latPulldown = ExerciseModel(id: 'lat_pulldown', name: 'سحب علوي', muscle: Muscle.back);
  static const barbellRow = ExerciseModel(id: 'barbell_row', name: 'تجديف بار', muscle: Muscle.back);
  static const cableRow = ExerciseModel(id: 'cable_row', name: 'تجديف كابل', muscle: Muscle.back);
  static const pullUp = ExerciseModel(id: 'pull_up', name: 'عقلة', muscle: Muscle.back, bodyweight: true);
  static const dumbbellRow = ExerciseModel(id: 'dumbbell_row', name: 'تجديف دمبل', muscle: Muscle.back);
  static const closeGripPulldown = ExerciseModel(id: 'close_grip_pulldown', name: 'سحب علوي ضيق', muscle: Muscle.back);
  static const tBarRow = ExerciseModel(id: 't_bar_row', name: 'تجديف تي بار', muscle: Muscle.back);
  static const backExtension = ExerciseModel(id: 'back_extension', name: 'ظهر سفلي بالجهاز', muscle: Muscle.back);

  // Legs
  static const squat = ExerciseModel(id: 'squat', name: 'سكوات', muscle: Muscle.legs);
  static const legPress = ExerciseModel(id: 'leg_press', name: 'دفع رجل', muscle: Muscle.legs);
  static const lunge = ExerciseModel(id: 'lunge', name: 'لانجز', muscle: Muscle.legs);
  static const legCurl = ExerciseModel(id: 'leg_curl', name: 'رجل خلفي بالجهاز', muscle: Muscle.legs);
  static const legExtension = ExerciseModel(id: 'leg_extension', name: 'رجل أمامي بالجهاز', muscle: Muscle.legs);
  static const bulgarianSplitSquat = ExerciseModel(
    id: 'bulgarian_split_squat',
    name: 'سكوات بلغاري',
    muscle: Muscle.legs,
  );
  static const romanianDeadlift = ExerciseModel(id: 'romanian_deadlift', name: 'رومانيان ديدلفت', muscle: Muscle.legs);
  static const hackSquat = ExerciseModel(id: 'hack_squat', name: 'هاك سكوات', muscle: Muscle.legs);
  static const hipThrust = ExerciseModel(id: 'hip_thrust', name: 'هيب ثرست', muscle: Muscle.legs);
  static const standingCalfRaise = ExerciseModel(id: 'standing_calf_raise', name: 'سمانة واقف', muscle: Muscle.legs);
  static const seatedCalfRaise = ExerciseModel(id: 'seated_calf_raise', name: 'سمانة قاعد', muscle: Muscle.legs);

  // Arms
  static const cableTriceps = ExerciseModel(id: 'cable_triceps', name: 'ترايبس بالكابل', muscle: Muscle.arms);
  static const barbellCurl = ExerciseModel(id: 'barbell_curl', name: 'بايسبس بار', muscle: Muscle.arms);
  static const hammerCurl = ExerciseModel(id: 'hammer_curl', name: 'بايسبس هامر', muscle: Muscle.arms);
  static const dumbbellCurl = ExerciseModel(id: 'dumbbell_curl', name: 'بايسبس دمبل', muscle: Muscle.arms);
  static const inclineCurl = ExerciseModel(id: 'incline_curl', name: 'بايسبس مائل', muscle: Muscle.arms);
  static const concentrationCurl = ExerciseModel(id: 'concentration_curl', name: 'بايسبس تركيز', muscle: Muscle.arms);
  static const cableCurl = ExerciseModel(id: 'cable_curl', name: 'بايسبس بالكابل', muscle: Muscle.arms);
  static const skullCrusher = ExerciseModel(id: 'skull_crusher', name: 'ترايبس فرنساوي', muscle: Muscle.arms);
  static const overheadExtension = ExerciseModel(
    id: 'overhead_extension',
    name: 'ترايبس دمبل خلف الراس',
    muscle: Muscle.arms,
  );
  static const benchDips = ExerciseModel(id: 'bench_dips', name: 'ديبس ترايبس', muscle: Muscle.arms, bodyweight: true);
  static const closeGripBenchPress = ExerciseModel(
    id: 'close_grip_bench_press',
    name: 'ضغط بار ضيق',
    muscle: Muscle.arms,
  );

  // Shoulders
  static const shoulderPress = ExerciseModel(id: 'shoulder_press', name: 'ضغط دمبل', muscle: Muscle.shoulders);
  static const lateralRaise = ExerciseModel(id: 'lateral_raise', name: 'رفرفة جانبي', muscle: Muscle.shoulders);
  static const frontRaise = ExerciseModel(id: 'front_raise', name: 'رفرفة أمامي', muscle: Muscle.shoulders);
  static const militaryPress = ExerciseModel(id: 'military_press', name: 'ضغط بار عسكري', muscle: Muscle.shoulders);
  static const arnoldPress = ExerciseModel(id: 'arnold_press', name: 'أرنولد بريس', muscle: Muscle.shoulders);
  static const rearDeltFly = ExerciseModel(id: 'rear_delt_fly', name: 'رفرفة خلفي', muscle: Muscle.shoulders);
  static const facePull = ExerciseModel(id: 'face_pull', name: 'فيس بول', muscle: Muscle.shoulders);
  static const uprightRow = ExerciseModel(id: 'upright_row', name: 'سحب بار للدقن', muscle: Muscle.shoulders);
  static const cableLateralRaise = ExerciseModel(
    id: 'cable_lateral_raise',
    name: 'رفرفة جانبي كابل',
    muscle: Muscle.shoulders,
  );
  static const shrug = ExerciseModel(id: 'shrug', name: 'ترابيس دمبل', muscle: Muscle.shoulders);

  // Abs
  static const plank = ExerciseModel(id: 'plank', name: 'البلانك', muscle: Muscle.abs, bodyweight: true, timed: true);
  static const crunch = ExerciseModel(id: 'crunch', name: 'كرانش', muscle: Muscle.abs, bodyweight: true);
  static const legRaise = ExerciseModel(id: 'leg_raise', name: 'رفع رجل', muscle: Muscle.abs, bodyweight: true);
  static const sidePlank = ExerciseModel(id: 'side_plank', name: 'بلانك جانبي', muscle: Muscle.abs, bodyweight: true, timed: true);
  static const bicycleCrunch = ExerciseModel(id: 'bicycle_crunch', name: 'كرانش دراجة', muscle: Muscle.abs, bodyweight: true);
  static const russianTwist = ExerciseModel(id: 'russian_twist', name: 'روسيان تويست', muscle: Muscle.abs);
  static const abWheel = ExerciseModel(id: 'ab_wheel', name: 'عجلة البطن', muscle: Muscle.abs, bodyweight: true);
  static const cableCrunch = ExerciseModel(id: 'cable_crunch', name: 'كرانش كابل', muscle: Muscle.abs);
  static const mountainClimber = ExerciseModel(id: 'mountain_climber', name: 'متسلق الجبل', muscle: Muscle.abs, bodyweight: true, timed: true);
  static const hangingLegRaise = ExerciseModel(id: 'hanging_leg_raise', name: 'رفع رجل معلّق', muscle: Muscle.abs, bodyweight: true);

  /// Grouped by muscle, in the order the exercises screen shows them.
  static const exercises = [
    // Chest
    benchPress,
    inclineDumbbellPress,
    inclineBenchPress,
    dumbbellPress,
    declineBenchPress,
    chestFly,
    cableCrossover,
    pecDeck,
    chestDips,
    pushUp,
    // Back
    deadlift,
    pullUp,
    latPulldown,
    closeGripPulldown,
    barbellRow,
    dumbbellRow,
    tBarRow,
    cableRow,
    backExtension,
    // Legs
    squat,
    legPress,
    hackSquat,
    bulgarianSplitSquat,
    lunge,
    romanianDeadlift,
    legExtension,
    legCurl,
    hipThrust,
    standingCalfRaise,
    seatedCalfRaise,
    // Arms
    barbellCurl,
    dumbbellCurl,
    hammerCurl,
    inclineCurl,
    concentrationCurl,
    cableCurl,
    cableTriceps,
    skullCrusher,
    overheadExtension,
    closeGripBenchPress,
    benchDips,
    // Shoulders
    shoulderPress,
    militaryPress,
    arnoldPress,
    lateralRaise,
    cableLateralRaise,
    frontRaise,
    rearDeltFly,
    facePull,
    uprightRow,
    shrug,
    // Abs
    plank,
    crunch,
    cableCrunch,
    bicycleCrunch,
    legRaise,
    hangingLegRaise,
    russianTwist,
    sidePlank,
    abWheel,
    mountainClimber,
  ];

  static const backAndBiceps = WorkoutModel(
    id: 'back_biceps',
    title: 'ظهر و بايسبس',
    durationMinutes: 50,
    exercises: [
      WorkoutExerciseModel(exercise: deadlift, sets: 3, reps: '6-8'),
      WorkoutExerciseModel(exercise: latPulldown, sets: 3, reps: '10-12'),
      WorkoutExerciseModel(exercise: barbellRow, sets: 3, reps: '8-10'),
      WorkoutExerciseModel(exercise: barbellCurl, sets: 3, reps: '10-12'),
    ],
  );

  static const legDay = WorkoutModel(
    id: 'legs',
    title: 'رجل',
    durationMinutes: 50,
    exercises: [
      WorkoutExerciseModel(exercise: squat, sets: 3, reps: '8-10'),
      WorkoutExerciseModel(exercise: legPress, sets: 3, reps: '10-12'),
      WorkoutExerciseModel(exercise: lunge, sets: 3, reps: '10-12'),
      WorkoutExerciseModel(exercise: legCurl, sets: 3, reps: '12-15'),
    ],
  );

  static const chestAndTriceps = WorkoutModel(
    id: 'chest_triceps',
    title: 'صدر و ترايبس',
    durationMinutes: 45,
    exercises: [
      WorkoutExerciseModel(exercise: benchPress, sets: 3, reps: '10-12'),
      WorkoutExerciseModel(exercise: inclineDumbbellPress, sets: 3, reps: '10-12'),
      WorkoutExerciseModel(exercise: chestFly, sets: 3, reps: '12-15'),
      WorkoutExerciseModel(exercise: cableTriceps, sets: 3, reps: '12-15'),
    ],
  );

  static const shouldersAndAbs = WorkoutModel(
    id: 'shoulders_abs',
    title: 'كتف و بطن',
    durationMinutes: 40,
    exercises: [
      WorkoutExerciseModel(exercise: shoulderPress, sets: 3, reps: '10-12'),
      WorkoutExerciseModel(exercise: lateralRaise, sets: 3, reps: '12-15'),
      WorkoutExerciseModel(exercise: plank, sets: 3, reps: '45 ث'),
      WorkoutExerciseModel(exercise: crunch, sets: 3, reps: '15-20'),
    ],
  );

  static const workouts = [backAndBiceps, legDay, chestAndTriceps, shouldersAndAbs];

  /// Day index (0 = Saturday) → workout. Missing days are rest days.
  static const weeklyPlan = {0: backAndBiceps, 2: legDay, 3: chestAndTriceps, 5: shouldersAndAbs};

  /// 0 for Saturday through 6 for Friday.
  static int dayIndex(DateTime day) => (day.weekday + 1) % 7;

  static String dayName(DateTime day) => dayNames[dayIndex(day)];

  static ExerciseModel? exerciseById(String id) {
    for (final exercise in exercises) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }

  static WorkoutModel? workoutById(String id) {
    for (final workout in workouts) {
      if (workout.id == id) return workout;
    }
    return null;
  }

  /// Days of the weekly plan that include [exercise], with its sets there.
  static List<({int day, WorkoutModel workout, WorkoutExerciseModel item})> plannedDaysFor(ExerciseModel exercise) {
    return [
      for (final MapEntry(key: day, value: workout) in weeklyPlan.entries)
        for (final item in workout.exercises)
          if (item.exercise == exercise) (day: day, workout: workout, item: item),
    ];
  }

  /// Exercises for [muscle] (all of them when null) whose name contains [query].
  static List<ExerciseModel> exercisesFor(Muscle? muscle, {String query = ''}) {
    return exercises.where((exercise) {
      final matchesMuscle = muscle == null || exercise.muscle == muscle;
      final matchesQuery = query.isEmpty || exercise.name.contains(query);
      return matchesMuscle && matchesQuery;
    }).toList();
  }

  static String exercisesCountLabel(int count) {
    return switch (count) {
      1 => 'تمرين واحد',
      2 => 'تمرينين',
      >= 3 && <= 10 => '$count تمارين',
      _ => '$count تمرين',
    };
  }

  static String setsCountLabel(int count) {
    return switch (count) {
      1 => 'مجموعة واحدة',
      2 => 'مجموعتين',
      >= 3 && <= 10 => '$count مجموعات',
      _ => '$count مجموعة',
    };
  }

  /// 60 → `60`, 62.5 → `62.5`, 61.25 → `61.25`.
  static String formatWeight(double kg) {
    return kg.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  /// Keeps [text] left-to-right inside Arabic text, so `60×10` doesn't show
  /// up as `10×60`.
  static String ltr(String text) => '\u2066$text\u2069';

  /// `60×10`, `12 عدّة` with body weight, `45 ث` when timed, or just the
  /// weight for sets saved before reps were tracked.
  static String formatSet(SetEntryModel set, ExerciseModel exercise) {
    final weight = '${formatWeight(set.weightKg)} كجم';
    final reps = exercise.timed ? '${set.reps} ث' : '${set.reps} عدّة';

    if (set.reps == 0) return set.weightKg == 0 ? 'مجموعة' : weight;
    if (set.weightKg == 0) return reps;
    if (exercise.timed) return '$weight · $reps';
    return ltr('${formatWeight(set.weightKg)}×${set.reps}');
  }

  /// `تلات 27/10`.
  static String dateLabel(DateTime day) => '${dayName(day)} ${ltr('${day.day}/${day.month}')}';
}
