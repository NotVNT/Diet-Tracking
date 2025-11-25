import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../responsive/responsive.dart';

/// Enum to represent the state of a calendar day
enum DayState { normal, today, selected, disabled }

/// Model for a day in the calendar
class CalendarDay {
  final DateTime date;
  final DayState state;

  CalendarDay({
    required this.date,
    required this.state,
  });

  CalendarDay copyWith({
    DateTime? date,
    DayState? state,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      state: state ?? this.state,
    );
  }
}

/// A week calendar widget with day selection functionality
class WeekCalendarWidget extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateSelected;
  final bool showMonthYear;

  const WeekCalendarWidget({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.showMonthYear = true,
  });

  @override
  State<WeekCalendarWidget> createState() => _WeekCalendarWidgetState();
}

class _WeekCalendarWidgetState extends State<WeekCalendarWidget> {
  late DateTime _selectedDate;
  late DateTime _displayedWeekStart;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _displayedWeekStart = _getWeekStart(_selectedDate);
  }

    /// Gets the start of the week (Monday) for a given date
  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

    /// Gets the list of 7 days for the currently displayed week
    List<CalendarDay> _getWeekDays() {
    final List<CalendarDay> days = [];
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = _displayedWeekStart.add(Duration(days: i));
      final DayState state;

      // Vô hiệu hóa ngày trong tương lai
      if (date.year > today.year ||
          (date.year == today.year && date.month > today.month) ||
          (date.year == today.year && date.month == today.month && date.day > today.day)) {
        state = DayState.disabled;
      } else if (_isSameDay(date, _selectedDate)) {
        state = DayState.selected;
      } else if (_isSameDay(date, today)) {
        state = DayState.today;
      } else {
        state = DayState.normal;
      }

      days.add(CalendarDay(
        date: date,
        state: state,
      ));
    }

    return days;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

    void _onDayTapped(DateTime date) {
    // Không cho phép chọn ngày trong tương lai
    if (date.isAfter(DateTime.now())) {
      return;
    }
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected?.call(date);
  }

  void _previousWeek() {
    setState(() {
      _displayedWeekStart = _displayedWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _displayedWeekStart = _displayedWeekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final responsive = ResponsiveHelper.of(context);
    final theme = Theme.of(context);
    final locale = localizations?.localeName ?? 'vi';

    return Container(
      padding: EdgeInsets.all(responsive.width(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha((255 * 0.08).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showMonthYear) ...[
            _buildHeader(context, locale, responsive, theme),
            SizedBox(height: responsive.height(16)),
          ],
          _buildWeekDays(context, responsive, theme, localizations),
        ],
      ),
    );
  }

    /// Builds the header with month, year, and navigation buttons
  Widget _buildHeader(
    BuildContext context,
    String locale,
    ResponsiveHelper responsive,
    ThemeData theme,
  ) {
    final monthYear = DateFormat('MMMM yyyy', locale).format(_displayedWeekStart);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: responsive.iconSize(24),
          ),
          onPressed: _previousWeek,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(
          monthYear,
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            size: responsive.iconSize(24),
          ),
          onPressed: _nextWeek,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

    /// Builds the row of week days
  Widget _buildWeekDays(
    BuildContext context,
    ResponsiveHelper responsive,
    ThemeData theme,
    AppLocalizations? localizations,
  ) {
    final weekDays = _getWeekDays();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDays.map((day) {
        return _buildDayItem(
          context,
          day,
          responsive,
          theme,
          localizations,
        );
      }).toList(),
    );
  }

    /// Builds a single day item
    Widget _buildDayItem(
    BuildContext context,
    CalendarDay day,
    ResponsiveHelper responsive,
    ThemeData theme,
    AppLocalizations? localizations,
  ) {
    final dayOfWeekLabel = _getShortDayOfWeek(day.date.weekday, localizations);
    final dayNumber = day.date.day.toString();

    // Define styles based on DayState
    BoxDecoration containerDecoration;
    Color dayNumberColor;
    Color dayLabelColor;
    FontWeight dayNumberFontWeight = FontWeight.w600;

    switch (day.state) {
      case DayState.selected:
        containerDecoration = BoxDecoration(
          color: Colors.black, // As per image
          borderRadius: BorderRadius.circular(responsive.radius(25)), // Capsule shape
        );
        dayNumberColor = Colors.black; // Number inside white circle
        dayLabelColor = Colors.white;
        break;
      case DayState.today:
        containerDecoration = const BoxDecoration(); // No background decoration for the whole item
        dayNumberColor = Colors.red;
        dayLabelColor = theme.colorScheme.onSurface.withAlpha((255 * 0.6).toInt());
        break;
      case DayState.disabled:
        containerDecoration = const BoxDecoration();
        dayNumberColor = Colors.grey;
        dayLabelColor = Colors.grey;
        dayNumberFontWeight = FontWeight.normal;
        break;
            case DayState.normal:
        containerDecoration = const BoxDecoration();
        dayNumberColor = theme.colorScheme.onSurface;
        dayLabelColor = theme.colorScheme.onSurface.withAlpha((255 * 0.6).toInt());
        break;
    }

    // Build the number widget with special decorations for today/selected
    Widget dayNumberWidget;
    if (day.state == DayState.selected) {
      dayNumberWidget = Container(
        padding: EdgeInsets.all(responsive.width(8)),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Text(
          dayNumber,
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            fontWeight: dayNumberFontWeight,
            color: dayNumberColor,
          ),
        ),
      );
    } else if (day.state == DayState.today) {
      dayNumberWidget = Container(
        padding: EdgeInsets.all(responsive.width(8)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 1.5),
        ),
        child: Text(
          dayNumber,
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            fontWeight: dayNumberFontWeight,
            color: dayNumberColor,
          ),
        ),
      );
    } else {
      dayNumberWidget = Padding(
        padding: EdgeInsets.all(responsive.width(9.5)), // Match padding of decorated items
        child: Text(
          dayNumber,
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            fontWeight: dayNumberFontWeight,
            color: dayNumberColor,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: day.state != DayState.disabled ? () => _onDayTapped(day.date) : null,
      child: Container(
        width: responsive.width(45), // Adjust width for capsule
        padding: EdgeInsets.symmetric(
          vertical: responsive.height(4),
        ),
        decoration: containerDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayOfWeekLabel,
              style: TextStyle(
                fontSize: responsive.fontSize(11),
                fontWeight: FontWeight.w500,
                color: dayLabelColor,
              ),
            ),
            SizedBox(height: responsive.height(4)),
            dayNumberWidget,
          ],
        ),
      ),
    );
  }

    /// Gets the short name of the day of the week (MON, TUE, etc.)
  String _getShortDayOfWeek(int weekday, AppLocalizations? localizations) {
    if (localizations == null) {
      return _getVietnameseShortDayOfWeek(weekday);
    }

    final locale = localizations.localeName;
    if (locale == 'vi') {
      return _getVietnameseShortDayOfWeek(weekday);
    } else {
      return _getEnglishShortDayOfWeek(weekday);
    }
  }

  String _getVietnameseShortDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  String _getEnglishShortDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MON';
      case DateTime.tuesday:
        return 'TUE';
      case DateTime.wednesday:
        return 'WED';
      case DateTime.thursday:
        return 'THU';
      case DateTime.friday:
        return 'FRI';
      case DateTime.saturday:
        return 'SAT';
      case DateTime.sunday:
        return 'SUN';
      default:
        return '';
    }
  }
}
