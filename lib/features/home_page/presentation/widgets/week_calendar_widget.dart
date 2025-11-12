import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../responsive/responsive.dart';

/// Model for a day in the calendar
class CalendarDay {
  final DateTime date;
  final bool isSelected;
  final bool isToday;

  CalendarDay({
    required this.date,
    this.isSelected = false,
    this.isToday = false,
  });

  CalendarDay copyWith({
    DateTime? date,
    bool? isSelected,
    bool? isToday,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      isSelected: isSelected ?? this.isSelected,
      isToday: isToday ?? this.isToday,
    );
  }
}

/// Widget hiển thị lịch tuần với khả năng chọn ngày
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

  /// Lấy ngày đầu tuần (Monday)
  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  /// Lấy danh sách 7 ngày trong tuần
  List<CalendarDay> _getWeekDays() {
    final List<CalendarDay> days = [];
    final today = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = _displayedWeekStart.add(Duration(days: i));
      days.add(CalendarDay(
        date: date,
        isSelected: _isSameDay(date, _selectedDate),
        isToday: _isSameDay(date, today),
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
            color: theme.colorScheme.shadow.withOpacity(0.08),
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

  /// Header với tháng năm và nút điều hướng
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

  /// Build các ngày trong tuần
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

  /// Build một item ngày
  Widget _buildDayItem(
    BuildContext context,
    CalendarDay day,
    ResponsiveHelper responsive,
    ThemeData theme,
    AppLocalizations? localizations,
  ) {
    final dayOfWeekLabel = _getShortDayOfWeek(day.date.weekday, localizations);
    final dayNumber = day.date.day.toString();

    Color backgroundColor;
    Color textColor;
    Color labelColor;

    if (day.isSelected) {
      backgroundColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
      labelColor = theme.colorScheme.onPrimary.withOpacity(0.8);
    } else if (day.isToday) {
      backgroundColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
      labelColor = theme.colorScheme.onPrimaryContainer.withOpacity(0.7);
    } else {
      backgroundColor = theme.colorScheme.surfaceContainerHighest.withOpacity(0.3);
      textColor = theme.colorScheme.onSurface;
      labelColor = theme.colorScheme.onSurface.withOpacity(0.6);
    }

    return GestureDetector(
      onTap: () => _onDayTapped(day.date),
      child: Container(
        width: responsive.width(42),
        padding: EdgeInsets.symmetric(
          vertical: responsive.height(8),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(responsive.radius(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayOfWeekLabel,
              style: TextStyle(
                fontSize: responsive.fontSize(11),
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            SizedBox(height: responsive.height(4)),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: responsive.fontSize(16),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lấy tên ngắn của thứ (MON, TUE, ...)
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
