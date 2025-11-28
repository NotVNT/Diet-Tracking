import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../responsive/responsive.dart';
import 'calendar_date_utils.dart';
import 'day_item.dart';
import 'week_calendar_controller.dart';

/// A week calendar widget with day selection functionality (UI only)
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
  final WeekCalendarController _controller = WeekCalendarController();

  @override
  void initState() {
    super.initState();
    _controller.init(widget.initialDate ?? DateTime.now());
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final responsive = ResponsiveHelper.of(context);
    final theme = Theme.of(context);
    final locale = localizations?.localeName ?? 'vi';

    final monthYear = DateFormat('MMMM yyyy', locale).format(_controller.displayedWeekStart);
    final days = _controller.getWeekDays();

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
            _buildHeader(responsive, theme, monthYear),
            SizedBox(height: responsive.height(16)),
          ],
          _buildWeekDays(responsive, theme, locale, days),
        ],
      ),
    );
  }

  Widget _buildHeader(ResponsiveHelper responsive, ThemeData theme, String monthYear) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: responsive.iconSize(24),
          ),
          onPressed: _controller.previousWeek,
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
          onPressed: _controller.nextWeek,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildWeekDays(
    ResponsiveHelper responsive,
    ThemeData theme,
    String locale,
    List<CalendarDay> days,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        return DayItem(
          day: day,
          responsive: responsive,
          theme: theme,
          locale: locale,
          onTap: () {
            _controller.selectDate(day.date);
            widget.onDateSelected?.call(day.date);
          },
        );
      }).toList(),
    );
  }
}
