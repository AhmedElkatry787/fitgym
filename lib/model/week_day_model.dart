enum DayStatus { done, today, planned, missed, rest }

class WeekDayModel {
  const WeekDayModel({required this.name, required this.status, required this.isToday, this.minutes = 0});

  final String name;
  final DayStatus status;

  /// Today can also be [DayStatus.done] once the workout is finished.
  final bool isToday;

  /// Minutes trained on this day.
  final int minutes;
}
