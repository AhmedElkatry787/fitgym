import 'dart:async';
import 'dart:math' as math;

import 'package:FitGym/core/services/storage_service.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/model/exercise_model.dart';
import 'package:FitGym/model/personal_record_model.dart';
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

  /// No workout planned today and none started.
  bool get isRestDay => plannedFor(today) == null && _todayLog == null;

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
    final started = _todayLog;
    if (started != null) {
      final workout = WorkoutService.workoutById(started.workoutId);
      if (workout != null) return workout;
    }
    return plannedFor(today) ?? nextWorkout.workout;
  }

  int doneSets(ExerciseModel exercise) => _todayLog?.doneSets[exercise.id] ?? 0;

  int get activeDoneSets => _todayLog == null ? 0 : _doneSetsIn(_todayLog!);

  bool get activeComplete => activeDoneSets >= activeWorkout.totalSets;

  double? todayWeight(ExerciseModel exercise) => _todayLog?.weights[exercise.id];

  /// The most recent weight logged for [exercise], to start the picker from.
  double? lastWeight(ExerciseModel exercise) {
    final dates = _logs.keys.toList()..sort();
    for (final date in dates.reversed) {
      final weight = _logs[date]!.weights[exercise.id];
      if (weight != null) return weight;
    }
    return null;
  }

  void setDoneSets(ExerciseModel exercise, int sets) {
    _updateToday((log) => log.copyWith(doneSets: {...log.doneSets, exercise.id: sets}));
  }

  void setWeight(ExerciseModel exercise, double kg) {
    _updateToday((log) => log.copyWith(weights: {...log.weights, exercise.id: kg}));
  }

  void _updateToday(WorkoutLogModel Function(WorkoutLogModel log) update) {
    final key = dateKey(today);
    final log = _logs[key] ?? WorkoutLogModel(date: key, workoutId: activeWorkout.id);
    _logs[key] = update(log);
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

  /// Best weight per exercise, heaviest first.
  List<PersonalRecordModel> get topRecords {
    final history = <String, List<double>>{};
    final dates = _logs.keys.toList()..sort();
    for (final date in dates) {
      for (final entry in _logs[date]!.weights.entries) {
        (history[entry.key] ??= []).add(entry.value);
      }
    }

    final records = <PersonalRecordModel>[];
    history.forEach((id, weights) {
      final exercise = WorkoutService.exerciseById(id);
      if (exercise == null) return;

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
    });

    records.sort((a, b) => b.weightKg.compareTo(a.weightKg));
    return records.take(3).toList();
  }

  int _doneSetsIn(WorkoutLogModel log) {
    final workout = WorkoutService.workoutById(log.workoutId);
    if (workout == null) return 0;
    return workout.exercises.fold(
      0,
      (total, item) => total + math.min(log.doneSets[item.exercise.id] ?? 0, item.sets),
    );
  }

  bool _isComplete(WorkoutLogModel? log) {
    if (log == null) return false;
    final workout = WorkoutService.workoutById(log.workoutId);
    return workout != null && _doneSetsIn(log) >= workout.totalSets;
  }

  /// Estimated from the workout's length and how many of its sets were done.
  int _minutesIn(WorkoutLogModel? log) {
    if (log == null) return 0;
    final workout = WorkoutService.workoutById(log.workoutId);
    if (workout == null) return 0;
    return (workout.durationMinutes * _doneSetsIn(log) / workout.totalSets).round();
  }
}
