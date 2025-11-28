import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../responsive/responsive.dart';
import 'calendar_date_utils.dart';

class DayItem extends StatelessWidget {
  final CalendarDay day;
  final ResponsiveHelper responsive;
  final ThemeData theme;
  final String locale;
  final VoidCallback? onTap;

  const DayItem({
    super.key,
    required this.day,
    required this.responsive,
    required this.theme,
    required this.locale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayOfWeekLabel = _getShortDayOfWeek(day.date, locale);
    final dayNumber = day.date.day.toString();

    // Define styles based on DayState
    BoxDecoration containerDecoration;
    Color dayNumberColor;
    Color dayLabelColor;
    FontWeight dayNumberFontWeight = FontWeight.w600;

    switch (day.state) {
      case DayState.selected:
        containerDecoration = BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(responsive.radius(25)),
        );
        dayNumberColor = Colors.black;
        dayLabelColor = Colors.white;
        break;
      case DayState.today:
        containerDecoration = const BoxDecoration();
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
        padding: EdgeInsets.all(responsive.width(9.5)),
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
      onTap: day.state != DayState.disabled ? onTap : null,
      child: Container(
        width: responsive.width(45),
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

  String _getShortDayOfWeek(DateTime date, String loc) {
    if (loc == 'vi') {
      switch (date.weekday) {
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
      }
    }
    // Default EN
    return DateFormat('EEE', loc).format(date).toUpperCase();
  }
}
