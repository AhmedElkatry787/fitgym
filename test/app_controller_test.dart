import 'package:FitGym/core/services/app_controller.dart';
import 'package:FitGym/core/services/storage_service.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/model/week_day_model.dart';
import 'package:FitGym/model/workout_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 2026-10-24 is a Saturday, the first day of the app's week.
final saturday = DateTime(2026, 10, 24);
final monday = DateTime(2026, 10, 26);
final tuesday = DateTime(2026, 10, 27);
final wednesday = DateTime(2026, 10, 28);

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

  void finish(WorkoutModel workout) {
    for (final item in workout.exercises) {
      app.setDoneSets(item.exercise, item.sets);
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
    final bench = WorkoutService.benchPress;
    app.setDoneSets(bench, 3);
    app.setDoneSets(WorkoutService.inclineDumbbellPress, 3);

    expect(app.activeDoneSets, 6);
    expect(app.activeComplete, isFalse);
    expect(app.weekMinutes, 23); // 45 min × 6 / 12 sets
    expect(app.week[3].status, DayStatus.today);
    expect(app.week[2].status, DayStatus.missed);
    expect(app.week[1].status, DayStatus.rest);
    expect(app.week[5].status, DayStatus.planned);

    finish(WorkoutService.chestAndTriceps);
    expect(app.activeComplete, isTrue);
    expect(app.week[3].status, DayStatus.done);
    expect(app.week[3].isToday, isTrue);
    expect(app.weekDoneDays, 1);
    expect(app.weekMinutes, 45);
    expect(app.completedWorkouts, 1);
  });

  test('progress survives a restart', () {
    app.setDoneSets(WorkoutService.benchPress, 2);
    app.setWeight(WorkoutService.benchPress, 62.5);

    final reopened = AppController(storage, () => now);
    expect(reopened.doneSets(WorkoutService.benchPress), 2);
    expect(reopened.todayWeight(WorkoutService.benchPress), 62.5);
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

  test('records keep the best weight and how much it went up', () {
    now = DateTime(2026, 10, 20);
    app.setWeight(WorkoutService.benchPress, 55);
    now = saturday;
    app.setWeight(WorkoutService.deadlift, 90);
    now = tuesday;
    app.setWeight(WorkoutService.benchPress, 60);

    final records = app.topRecords;
    expect(records.map((record) => record.exercise), [WorkoutService.deadlift, WorkoutService.benchPress]);
    expect(records[0].gainKg, isNull);
    expect(records[1].weightKg, 60);
    expect(records[1].gainKg, 5);
    expect(app.lastWeight(WorkoutService.benchPress), 60);
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
