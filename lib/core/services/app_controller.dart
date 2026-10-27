import 'dart:async';
import 'dart:math' as math;

import 'package:FitGym/core/services/storage_service.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/model/exercise_model.dart';
import 'package:FitGym/model/exercise_session_model.dart';
import 'package:FitGym/model/personal_record_model.dart';
import 'package:FitGym/model/set_entry_model.dart';
import 'package:FitGym/model/week_day_model.dart';
import 'package:FitGym/model/workout_log_model.dart';
import 'package:FitGym/model/workout_model.dart';
import 'package:flutter/foundation.dart';

/// Everything the user did, saved on the device, and the numbers worked out
/// from it. Screens read it through `AppScope`.
class AppController extends ChangeNotifier {
  /// [_clock] is for tests that need a fixed date.
  AppController(this._storage, [this._clock = DateTime.now]) : _logs = _storage.loadLogs();

  final StorageService _storage;
  final DateTime Function() _clock;
  final Map<String, WorkoutLogModel> _logs;

  bool get onboardingSeen => _storage.onboardingSeen;

  Future<void> completeOnboarding() => _storage.setOnboardingSeen();

  DateTime get today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  static String dateKey(DateTime day) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${day.year}-${twoDigits(day.month)}-${twoDigits(day.day)}';
  }

  WorkoutModel? plannedFor(DateTime day) => WorkoutService.weeklyPlan[WorkoutService.dayIndex(day)];

  WorkoutLogModel? get _todayLog => _logs[dateKey(today)];

  /// No workout planned today and none started. Training picked exercises
  /// doesn't end a rest day.
  bool get isRestDay => plannedFor(today) == null && _todayLog?.workoutId == null;

  ({DateTime day, WorkoutModel workout}) get nextWorkout {
    for (var i = 1; i <= 7; i++) {
      final day = DateTime(today.year, today.month, today.day + i);
      final workout = plannedFor(day);
      if (workout != null) return (day: day, workout: workout);
    }
    throw StateError('WorkoutService.weeklyPlan has no workouts');
  }

  /// Today's workout. On a rest day it's the next one, so you can train early.
  WorkoutModel get activeWorkout {
    final startedId = _todayLog?.workoutId;
    if (startedId != null) {
      final workout = WorkoutService.workoutById(startedId);
      if (workout != null) return workout;
    }
    return plannedFor(today) ?? nextWorkout.workout;
  }

  /// How [exercise] is trained: as in today's workout, else as on its day in
  /// the plan, else 3 sets in its muscle's rep range.
  WorkoutExerciseModel itemFor(ExerciseModel exercise) {
    for (final item in activeWorkout.exercises) {
      if (item.exercise == exercise) return item;
    }
    final planned = WorkoutService.plannedDaysFor(exercise).firstOrNull;
    return planned?.item ?? WorkoutExerciseModel(exercise: exercise, sets: 3, reps: exercise.muscle.reps);
  }

  /// Exercises trained today on top of today's workout, in the order started.
  List<ExerciseModel> get extraExercisesToday {
    final planned = {for (final item in activeWorkout.exercises) item.exercise.id};
    final sets = _todayLog?.sets ?? const <String, List<SetEntryModel>>{};
    return [
      for (final MapEntry(key: id, value: entries) in sets.entries)
        if (entries.isNotEmpty && !planned.contains(id)) ?WorkoutService.exerciseById(id),
    ];
  }

  /// Today's finished sets of [exercise], in order.
  List<SetEntryModel> setsFor(ExerciseModel exercise) => _todayLog?.setsOf(exercise.id) ?? const [];

  int doneSets(ExerciseModel exercise) => setsFor(exercise).length;

  int get activeDoneSets => _todayLog == null ? 0 : _doneSetsIn(_todayLog!);

  bool get activeComplete => activeDoneSets >= activeWorkout.totalSets;

  /// Every day [exercise] was trained, oldest first.
  List<ExerciseSessionModel> history(ExerciseModel exercise) {
    final dates = _logs.keys.toList()..sort();
    return [
      for (final date in dates)
        if (_logs[date]!.setsOf(exercise.id) case final sets when sets.isNotEmpty)
          ExerciseSessionModel(date: DateTime.parse(date), sets: sets),
    ];
  }

  /// The last time [exercise] was trained before today.
  ExerciseSessionModel? previousSession(ExerciseModel exercise) {
    return history(exercise).where((session) => session.date.isBefore(today)).lastOrNull;
  }

  /// What a new set starts with: the set before it, else the best set last
  /// time, else an empty bar at the bottom of the rep range.
  SetEntryModel suggestedSet(WorkoutExerciseModel item) {
    final start = setsFor(item.exercise).lastOrNull ?? previousSession(item.exercise)?.topSet;
    if (start == null) return SetEntryModel(weightKg: item.exercise.bodyweight ? 0 : 20, reps: item.minReps);
    // Sets saved before reps were tracked have 0 reps.
    return start.reps > 0 ? start : SetEntryModel(weightKg: start.weightKg, reps: item.minReps);
  }

  void addSet(ExerciseModel exercise, SetEntryModel set) {
    _updateToday(exercise, (sets) => [...sets, set]);
  }

  void updateSet(ExerciseModel exercise, int index, SetEntryModel set) {
    _updateToday(exercise, (sets) => [...sets]..[index] = set);
  }

  void removeSet(ExerciseModel exercise, int index) {
    _updateToday(exercise, (sets) => [...sets]..removeAt(index));
  }

  void _updateToday(ExerciseModel exercise, List<SetEntryModel> Function(List<SetEntryModel> sets) update) {
    final key = dateKey(today);
    var log = _logs[key] ?? WorkoutLogModel(date: key, workoutId: plannedFor(today)?.id);
    // On a rest day, starting one of the next workout's exercises starts that
    // workout early; any other exercise stays a picked one.
    if (log.workoutId == null && activeWorkout.exercises.any((item) => item.exercise == exercise)) {
      log = log.withWorkout(activeWorkout.id);
    }
    _logs[key] = log.withSets(exercise.id, update(log.setsOf(exercise.id)));
    unawaited(_storage.saveLogs(_logs.values));
    notifyListeners();
  }

  List<WeekDayModel> get week {
    final start = DateTime(today.year, today.month, today.day - WorkoutService.dayIndex(today));
    return [
      for (var i = 0; i < 7; i++) _weekDay(DateTime(start.year, start.month, start.day + i), i),
    ];
  }

  WeekDayModel _weekDay(DateTime day, int index) {
    final log = _logs[dateKey(day)];
    final isToday = day == today;
    final planned = plannedFor(day) != null;

    final DayStatus status;
    if (_isComplete(log)) {
      status = DayStatus.done;
    } else if (isToday) {
      status = DayStatus.today;
    } else if (!planned) {
      status = DayStatus.rest;
    } else if (day.isBefore(today)) {
      status = DayStatus.missed;
    } else {
      status = DayStatus.planned;
    }

    return WeekDayModel(
      name: WorkoutService.dayNames[index],
      status: status,
      isToday: isToday,
      minutes: _minutesIn(log),
    );
  }

  int get weekDoneDays => week.where((day) => day.status == DayStatus.done).length;

  int get weekPlannedDays => WorkoutService.weeklyPlan.length;

  int get weekMinutes => week.fold(0, (total, day) => total + day.minutes);

  int get completedWorkouts => _logs.values.where(_isComplete).length;

  /// Finished workouts in a row. Rest days don't break it, and neither does
  /// today before it's done; a planned day that was skipped does.
  int get streak {
    var count = _isComplete(_todayLog) ? 1 : 0;
    // Ends at the first skipped planned day, at the latest the one before the
    // oldest log.
    for (var i = 1;; i++) {
      final day = DateTime(today.year, today.month, today.day - i);
      final log = _logs[dateKey(day)];
      if (_isComplete(log)) {
        count++;
      } else if (plannedFor(day) != null) {
        break;
      }
    }
    return count;
  }

  /// Best weight per exercise, heaviest first. Body-weight-only sets don't
  /// count.
  List<PersonalRecordModel> get topRecords {
    final ids = {for (final log in _logs.values) ...log.sets.keys};

    final records = <PersonalRecordModel>[];
    for (final id in ids) {
      final exercise = WorkoutService.exerciseById(id);
      if (exercise == null) continue;

      // Heaviest set of each session, oldest first.
      final weights = [
        for (final session in history(exercise))
          if (session.topSet.weightKg > 0) session.topSet.weightKg,
      ];
      if (weights.isEmpty) continue;

      final best = weights.reduce(math.max);
      final before = weights.sublist(0, weights.indexOf(best));
      final previousBest = before.isEmpty ? null : before.reduce(math.max);
      records.add(
        PersonalRecordModel(
          exercise: exercise,
          weightKg: best,
          gainKg: previousBest == null ? null : best - previousBest,
        ),
      );
    }

    records.sort((a, b) => b.weightKg.compareTo(a.weightKg));
    return records.take(3).toList();
  }

  WorkoutModel? _workoutOf(WorkoutLogModel log) {
    final id = log.workoutId;
    return id == null ? null : WorkoutService.workoutById(id);
  }

  /// Sets done of the log's planned workout, at most its planned count each.
  int _doneSetsIn(WorkoutLogModel log) {
    final workout = _workoutOf(log);
    if (workout == null) return 0;
    return workout.exercises.fold(
      0,
      (total, item) => total + math.min(log.setsOf(item.exercise.id).length, item.sets),
    );
  }

  /// The planned workout is finished, or, on a rest day, anything was trained.
  bool _isComplete(WorkoutLogModel? log) {
    if (log == null) return false;
    final workout = _workoutOf(log);
    if (workout == null) return log.totalSets > 0;
    return _doneSetsIn(log) >= workout.totalSets;
  }

  /// Rough minutes per set, rest included, for days without a planned workout.
  static const _minutesPerSet = 3.75;

  /// Estimated from every set done, at the planned workout's pace.
  int _minutesIn(WorkoutLogModel? log) {
    if (log == null) return 0;
    final workout = _workoutOf(log);
    final perSet = workout == null ? _minutesPerSet : workout.durationMinutes / workout.totalSets;
    return (perSet * log.totalSets).round();
  }
}
