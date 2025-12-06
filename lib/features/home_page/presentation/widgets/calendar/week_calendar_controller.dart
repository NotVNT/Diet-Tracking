import 'package:flutter/foundation.dart';

import 'calendar_date_utils.dart';

/// Controller holding week calendar state and actions.
class WeekCalendarController extends ChangeNotifier {
  late DateTime _selectedDate;
  late DateTime _displayedWeekStart;
  bool _initialized = false;

  void init(DateTime initialDate) {
    if (_initialized) return;
    _selectedDate = initialDate;
    _displayedWeekStart = CalendarDateUtils.weekStart(_selectedDate);
    _initialized = true;
  }

  DateTime get selectedDate => _selectedDate;
  DateTime get displayedWeekStart => _displayedWeekStart;

  List<CalendarDay> getWeekDays() {
    return CalendarDateUtils.buildWeekDays(
      displayedWeekStart: _displayedWeekStart,
      selectedDate: _selectedDate,
    );
  }

  void nextWeek() {
    _displayedWeekStart = _displayedWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  void previousWeek() {
    _displayedWeekStart = _displayedWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  /// Selects a date; future dates are ignored to preserve behavior.
  void selectDate(DateTime date) {
    final today = DateTime.now();
    if (date.isAfter(DateTime(today.year, today.month, today.day))) {
      return; // ignore future
    }
    _selectedDate = DateTime(date.year, date.month, date.day);
    _displayedWeekStart = CalendarDateUtils.weekStart(_selectedDate);
    notifyListeners();
  }
}
