import 'dart:convert';

import 'package:FitGym/core/services/app_controller.dart';
import 'package:FitGym/core/services/storage_service.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/model/exercise_model.dart';
import 'package:FitGym/model/set_entry_model.dart';
import 'package:FitGym/model/week_day_model.dart';
import 'package:FitGym/model/workout_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 2026-10-24 is a Saturday, the first day of the app's week.
final saturday = DateTime(2026, 10, 24);
final monday = DateTime(2026, 10, 26);
final tuesday = DateTime(2026, 10, 27);
final wednesday = DateTime(2026, 10, 28);

SetEntryModel set(double kg, int reps) => SetEntryModel(weightKg: kg, reps: reps);

void main() {
  late StorageService storage;
  late DateTime now;
  late AppController app;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService(await SharedPreferences.getInstance());
    now = tuesday;
    app = AppController(storage, () => now);
  });

  void logSets(ExerciseModel exercise, int count, {double kg = 20, int reps = 10}) {
    for (var i = 0; i < count; i++) {
      app.addSet(exercise, set(kg, reps));
    }
  }

  void finish(WorkoutModel workout) {
    for (final item in workout.exercises) {
      logSets(item.exercise, item.sets);
    }
  }

  test('picks the planned workout, or the next one on a rest day', () {
    expect(app.activeWorkout, WorkoutService.chestAndTriceps);
    expect(app.isRestDay, isFalse);

    now = wednesday;
    expect(app.isRestDay, isTrue);
    expect(app.activeWorkout, WorkoutService.shouldersAndAbs);
    expect(app.nextWorkout.day, DateTime(2026, 10, 29));
  });

  test('done sets drive the week, minutes and totals', () {
    logSets(WorkoutService.benchPress, 3);
    logSets(WorkoutService.inclineDumbbellPress, 3);

    expect(app.activeDoneSets, 6);
    expect(app.activeComplete, isFalse);
    expect(app.weekMinutes, 23); // 45 min × 6 / 12 sets
    expect(app.week[3].status, DayStatus.today);
    expect(app.week[2].status, DayStatus.missed);
    expect(app.week[1].status, DayStatus.rest);
    expect(app.week[5].status, DayStatus.planned);

    logSets(WorkoutService.chestFly, 3);
    logSets(WorkoutService.cableTriceps, 3);
    expect(app.activeComplete, isTrue);
    expect(app.week[3].status, DayStatus.done);
    expect(app.week[3].isToday, isTrue);
    expect(app.weekDoneDays, 1);
    expect(app.weekMinutes, 45);
    expect(app.completedWorkouts, 1);
  });

  test('picked exercises on a rest day keep it a rest day but count as training', () {
    now = wednesday;
    app.addSet(WorkoutService.squat, set(80, 8));

    expect(app.isRestDay, isTrue);
    expect(app.activeWorkout, WorkoutService.shouldersAndAbs);
    expect(app.activeDoneSets, 0);
    expect(app.extraExercisesToday, [WorkoutService.squat]);
    expect(app.week[4].status, DayStatus.done);
    expect(app.weekMinutes, 4); // about 3.75 min a set
    expect(app.completedWorkouts, 1);
  });

  test('the next workout started on a rest day takes over the day', () {
    now = wednesday;
    app.addSet(WorkoutService.shoulderPress, set(20, 10));

    expect(app.isRestDay, isFalse);
    expect(app.activeWorkout, WorkoutService.shouldersAndAbs);
    expect(app.activeDoneSets, 1);
    expect(app.extraExercisesToday, isEmpty);
  });

  test('extra exercises on a workout day add time, not workout progress', () {
    logSets(WorkoutService.benchPress, 3);
    app.addSet(WorkoutService.bulgarianSplitSquat, set(10, 8));

    expect(app.activeDoneSets, 3);
    expect(app.extraExercisesToday, [WorkoutService.bulgarianSplitSquat]);
    expect(app.weekMinutes, 15); // 45 min / 12 sets × 4 sets
  });

  test('each exercise is trained as planned, else 3 sets of its muscle range', () {
    expect(app.itemFor(WorkoutService.benchPress).label, '3 × 10-12');
    expect(app.itemFor(WorkoutService.squat).label, '3 × 8-10', reason: 'from Monday in the plan');
    expect(app.itemFor(WorkoutService.bulgarianSplitSquat).label, '3 × ${WorkoutService.squat.muscle.reps}');
  });

  test('sets can be edited and removed', () {
    final bench = WorkoutService.benchPress;
    app.addSet(bench, set(60, 10));
    app.addSet(bench, set(60, 8));
    app.updateSet(bench, 1, set(62.5, 8));
    expect(app.setsFor(bench), [set(60, 10), set(62.5, 8)]);

    app.removeSet(bench, 0);
    expect(app.setsFor(bench), [set(62.5, 8)]);
  });

  test('progress survives a restart', () {
    app.addSet(WorkoutService.benchPress, set(62.5, 8));
    app.addSet(WorkoutService.benchPress, set(60, 10));

    final reopened = AppController(storage, () => now);
    expect(reopened.setsFor(WorkoutService.benchPress), [set(62.5, 8), set(60, 10)]);
  });

  test('saves from before per-set weights still load', () async {
    final old = {
      'date': '2026-10-27',
      'workoutId': 'chest_triceps',
      'doneSets': {'bench_press': 2},
      'weights': {'bench_press': 60},
    };
    SharedPreferences.setMockInitialValues({
      'workout_logs': jsonEncode([old]),
    });
    final reopened = AppController(StorageService(await SharedPreferences.getInstance()), () => now);

    expect(reopened.setsFor(WorkoutService.benchPress), [set(60, 0), set(60, 0)]);
    expect(reopened.topRecords.single.weightKg, 60);
  });

  test('streak skips rest days and breaks on a skipped workout', () {
    now = saturday;
    finish(WorkoutService.backAndBiceps);
    now = tuesday;
    finish(WorkoutService.chestAndTriceps);
    expect(app.streak, 1, reason: 'Monday was planned and skipped');

    now = monday;
    finish(WorkoutService.legDay);
    now = tuesday;
    expect(app.streak, 3);
  });

  test('history, last time and the suggested next set', () {
    final bench = WorkoutService.chestAndTriceps.exercises.first;
    expect(bench.exercise, WorkoutService.benchPress);
    expect(app.suggestedSet(bench), set(20, 10), reason: 'nothing logged yet');

    now = DateTime(2026, 10, 20);
    app.addSet(bench.exercise, set(55, 10));
    app.addSet(bench.exercise, set(52.5, 10));
    now = tuesday;

    expect(app.previousSession(bench.exercise)!.topSet, set(55, 10));
    expect(app.suggestedSet(bench), set(55, 10), reason: 'starts from the best set last time');

    app.addSet(bench.exercise, set(57.5, 8));
    expect(app.suggestedSet(bench), set(57.5, 8), reason: 'then follows the set before it');
    expect(app.history(bench.exercise).map((session) => session.date), [DateTime(2026, 10, 20), tuesday]);
  });

  test('body weight exercises start at 0 kg', () {
    const pullUps = WorkoutExerciseModel(exercise: WorkoutService.pullUp, sets: 3, reps: '6-8');
    expect(app.suggestedSet(pullUps), set(0, 6));
  });

  test('records keep the best weight and how much it went up', () {
    now = DateTime(2026, 10, 20);
    app.addSet(WorkoutService.benchPress, set(55, 10));
    now = saturday;
    app.addSet(WorkoutService.deadlift, set(90, 5));
    app.addSet(WorkoutService.pullUp, set(0, 10));
    now = tuesday;
    app.addSet(WorkoutService.benchPress, set(57.5, 10));
    app.addSet(WorkoutService.benchPress, set(60, 8));

    final records = app.topRecords;
    expect(records.map((record) => record.exercise), [WorkoutService.deadlift, WorkoutService.benchPress]);
    expect(records[0].gainKg, isNull);
    expect(records[1].weightKg, 60);
    expect(records[1].gainKg, 5);
  });

  test('sets format with weight and reps in the right order', () {
    expect(WorkoutService.formatSet(set(60, 10), WorkoutService.benchPress), WorkoutService.ltr('60×10'));
    expect(WorkoutService.formatSet(set(0, 12), WorkoutService.pullUp), '12 عدّة');
    expect(WorkoutService.formatSet(set(0, 45), WorkoutService.plank), '45 ث');
    expect(WorkoutService.formatSet(set(60, 0), WorkoutService.benchPress), '60 كجم');
    expect(WorkoutService.formatWeight(61.25), '61.25');
  });

  test('exercise search filters by muscle and name', () {
    expect(WorkoutService.exercisesFor(null, query: 'بلغاري').single, WorkoutService.bulgarianSplitSquat);
    expect(WorkoutService.exercisesFor(null, query: 'سكوات'), hasLength(3));
    expect(
      WorkoutService.exercisesFor(WorkoutService.squat.muscle).every((e) => e.muscle == WorkoutService.squat.muscle),
      isTrue,
    );
  });

  test('every exercise has its own id, and workouts only use listed ones', () {
    final ids = WorkoutService.exercises.map((exercise) => exercise.id).toList();
    expect(ids.toSet(), hasLength(ids.length));

    for (final workout in WorkoutService.workouts) {
      for (final item in workout.exercises) {
        expect(WorkoutService.exerciseById(item.exercise.id), item.exercise);
      }
    }
  });
}
