import 'package:flutter/material.dart';

/// Enum to represent the state of a calendar day
enum DayState { normal, today, selected, disabled }

/// Model for a day in the calendar
class CalendarDay {
  final DateTime date;
  final DayState state;

  const CalendarDay({
    required this.date,
    required this.state,
  });
}

class CalendarDateUtils {
  const CalendarDateUtils._();

  /// Gets the start of the week (Monday) for a given date
  static DateTime weekStart(DateTime date) {
    final d = DateUtils.dateOnly(date);
    final dayOfWeek = d.weekday; // Monday=1
    return d.subtract(Duration(days: dayOfWeek - 1));
  }

  /// Build 7 days for a displayed week. Future dates are disabled.
  static List<CalendarDay> buildWeekDays({
    required DateTime displayedWeekStart,
    required DateTime selectedDate,
  }) {
    final List<CalendarDay> days = [];
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = DateUtils.dateOnly(selectedDate);

    for (int i = 0; i < 7; i++) {
      final date = displayedWeekStart.add(Duration(days: i));
      final DayState state;

      // Disable future dates
      if (date.isAfter(today)) {
        state = DayState.disabled;
      } else if (DateUtils.isSameDay(date, selected)) {
        state = DayState.selected;
      } else if (DateUtils.isSameDay(date, today)) {
        state = DayState.today;
      } else {
        state = DayState.normal;
      }

      days.add(CalendarDay(date: date, state: state));
    }

    return days;
  }
}
