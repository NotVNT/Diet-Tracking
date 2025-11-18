import 'package:flutter/material.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/snackbar_helper.dart';
import '../widgets/week_calendar_widget.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/calorie_goal_card.dart';

/// Main home content page
class HomeMainPage extends StatefulWidget {
  const HomeMainPage({super.key});

  @override
  State<HomeMainPage> createState() => _HomeMainPageState();
}

class _HomeMainPageState extends State<HomeMainPage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic>? _activeFilters;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    // TODO: Implement search logic
    debugPrint('Search query: $query');
  }

  void _onFilterTapped() {
    showFilterBottomSheet(
      context,
      onApplyFilter: (filters) {
        setState(() {
          _activeFilters = filters;
        });
        debugPrint('Applied filters: $filters');
        // TODO: Implement filter logic
      },
    );
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    // TODO: Load data for selected date
    debugPrint('Selected date: $date');
  }

  void _onViewReport() {
    // TODO: Navigate to detailed report
    SnackBarHelper.showInfo(context, 'Xem báo cáo chi tiết');
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations?.bottomNavHome ?? 'Trang chủ',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(responsive.width(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeekCalendarWidget(
                initialDate: _selectedDate,
                onDateSelected: _onDateSelected,
                showMonthYear: true,
              ),
              SizedBox(height: responsive.height(16)),
              SearchFilterBar(
                controller: _searchController,
                onSearchChanged: _onSearchChanged,
                onFilterTapped: _onFilterTapped,
                showFilterButton: true,
              ),
              SizedBox(height: responsive.height(16)),
              CalorieGoalCard(
                nutritionInfo: NutritionInfo(
                  calorieGoal: 2273,
                  calorieConsumed: 0,
                  proteinConsumed: 0,
                  carbsConsumed: 0,
                ),
                onViewReport: _onViewReport,
              ),
              SizedBox(height: responsive.height(12)),
              _buildContentPlaceholder(responsive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentPlaceholder(ResponsiveHelper responsive) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: responsive.height(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _searchQuery.isEmpty
                  ? 'Danh sách bữa ăn sẽ hiển thị ở đây'
                  : 'Tìm kiếm: $_searchQuery',
              style: TextStyle(
                fontSize: responsive.fontSize(14),
              ),
            ),
            if (_activeFilters != null) ...[
              SizedBox(height: responsive.height(6)),
              Text(
                'Lọc: ${_activeFilters!['category']} | ${_activeFilters!['calorieMin']}-${_activeFilters!['calorieMax']} kcal',
                style: TextStyle(
                  fontSize: responsive.fontSize(11),
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
