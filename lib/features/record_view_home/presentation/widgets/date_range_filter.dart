import 'package:flutter/material.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';

class DateRangeFilter extends StatefulWidget {
  final DateTimeRange? initialRange;
  final ValueChanged<DateTimeRange?> onChanged;

  const DateRangeFilter({
    super.key,
    this.initialRange,
    required this.onChanged,
  });

  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  late DateTimeRange? _selectedRange;
  String _mode = 'none'; // 'today' | 'yesterday' | 'last7' | 'custom' | 'none'

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialRange;
    _mode = _detectMode(_selectedRange);
  }

  @override
  void didUpdateWidget(covariant DateRangeFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRange != widget.initialRange) {
      _selectedRange = widget.initialRange;
      _mode = _detectMode(_selectedRange);
      setState(() {});
    }
  }

  String _detectMode(DateTimeRange? r) {
    if (r == null) return 'none';
    final now = DateTime.now();
    final startToday = _startOfDay(now);
    final endToday = _endOfDay(now);
    final startYesterday = _startOfDay(now.subtract(const Duration(days: 1)));
    final endYesterday = _endOfDay(now.subtract(const Duration(days: 1)));
    final startLast7 = _startOfDay(now.subtract(const Duration(days: 6)));

    if (_equalsRange(r, DateTimeRange(start: startToday, end: endToday))) return 'today';
    if (_equalsRange(r, DateTimeRange(start: startYesterday, end: endYesterday))) return 'yesterday';
    if (_equalsRange(r, DateTimeRange(start: startLast7, end: endToday))) return 'last7';
    return 'custom';
  }

  bool _equalsRange(DateTimeRange a, DateTimeRange b) =>
      a.start.isAtSameMomentAs(b.start) && a.end.isAtSameMomentAs(b.end);

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999, 999);

  void _setMode(String mode) {
    final now = DateTime.now();
    setState(() {
      _mode = mode;
      if (mode == 'today') {
        _selectedRange = DateTimeRange(start: _startOfDay(now), end: _endOfDay(now));
      } else if (mode == 'yesterday') {
        final y = now.subtract(const Duration(days: 1));
        _selectedRange = DateTimeRange(start: _startOfDay(y), end: _endOfDay(y));
      } else if (mode == 'last7') {
        _selectedRange = DateTimeRange(start: _startOfDay(now.subtract(const Duration(days: 6))), end: _endOfDay(now));
      } else if (mode == 'none') {
        _selectedRange = null;
      }
    });
    widget.onChanged(_selectedRange);
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final initial = _selectedRange ??
        DateTimeRange(start: _startOfDay(now.subtract(const Duration(days: 6))), end: _endOfDay(now));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initial,
    );
    if (picked != null) {
      setState(() {
        _mode = 'custom';
        _selectedRange = DateTimeRange(start: _startOfDay(picked.start), end: _endOfDay(picked.end));
      });
      widget.onChanged(_selectedRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    Widget chip(String label, bool selected, VoidCallback onTap) {
      final borderColor = selected
          ? Colors.transparent
          : (isDark ? cs.outline.withValues(alpha: 0.6) : cs.outlineVariant);
      final labelColor = selected ? cs.onPrimary : cs.onSurface;
      final bg = selected
          ? cs.primary
          : (isDark ? Colors.transparent : cs.surfaceContainerHigh);
      return ChoiceChip(
        selected: selected,
        label: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        avatar: selected ? Icon(Icons.check_rounded, size: 16, color: cs.onPrimary) : null,
        onSelected: (_) => onTap(),
        backgroundColor: bg,
        selectedColor: cs.primary,
        side: BorderSide(color: borderColor, width: isDark ? 1.2 : 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        visualDensity: VisualDensity.compact,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(t?.all ?? 'Tất cả', _mode == 'none', () => _setMode('none')),
          SizedBox(width: r.width(8)),
          chip(t?.today ?? 'Hôm nay', _mode == 'today', () => _setMode('today')),
          SizedBox(width: r.width(8)),
          chip(t?.yesterday ?? 'Hôm qua', _mode == 'yesterday', () => _setMode('yesterday')),
          SizedBox(width: r.width(8)),
          chip(t?.last7Days ?? '7 ngày qua', _mode == 'last7', () => _setMode('last7')),
          SizedBox(width: r.width(8)),
          ActionChip(
            label: Text(t?.customRange ?? 'Khoảng khác'),
            onPressed: _pickCustomRange,
          )
        ],
      ),
    );
  }
}

