import 'dart:convert';

import 'package:FitGym/model/workout_log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingSeenKey = 'onboarding_seen';
  static const _workoutLogsKey = 'workout_logs';

  bool get onboardingSeen => _prefs.getBool(_onboardingSeenKey) ?? false;

  Future<void> setOnboardingSeen() => _prefs.setBool(_onboardingSeenKey, true);

  /// Logs by date. Unreadable data is dropped rather than stopping the app.
  Map<String, WorkoutLogModel> loadLogs() {
    final raw = _prefs.getString(_workoutLogsKey);
    if (raw == null) return {};

    try {
      final logs = (jsonDecode(raw) as List<dynamic>).map(
        (item) => WorkoutLogModel.fromJson(item as Map<String, dynamic>),
      );
      return {for (final log in logs) log.date: log};
    } catch (_) {
      return {};
    }
  }

  Future<void> saveLogs(Iterable<WorkoutLogModel> logs) {
    return _prefs.setString(_workoutLogsKey, jsonEncode([for (final log in logs) log.toJson()]));
  }
}
