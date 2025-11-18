import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../common/permission_service.dart';
import '../providers/home_provider.dart';
import '../widgets/custom_floating_action_button.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/week_calendar_widget.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/calorie_goal_card.dart';
import '../widgets/recently_logged_section.dart';
import '../../../food_scanner/domain/entities/scanned_food_entity.dart';
import '../../../food_scanner/domain/repositories/scanned_food_repository.dart';
import '../../../food_scanner/data/datasources/scanned_food_local_datasource.dart';
import '../../../food_scanner/data/repositories/scanned_food_repository_impl.dart';
import '../../../food_scanner/presentation/pages/food_scanner_page.dart';
import '../../../food_scanner/presentation/pages/scanned_food_detail_page.dart';
import 'home_page_config.dart';

/// Main home page with bottom navigation
///
/// Quản lý navigation giữa các trang chính:
/// - Trang chủ (Home)
/// - Ghi nhận (Record)
/// - Chat bot
/// - Hồ sơ (Profile)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Home content state
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic>? _activeFilters;
  late final ScannedFoodRepository _scannedFoodRepository;
  List<ScannedFoodEntity> _scannedFoods = [];

  @override
  void initState() {
    super.initState();
    _scannedFoodRepository = ScannedFoodRepositoryImpl(
      localDataSource: ScannedFoodLocalDataSource(),
    );
    _loadScannedFoods();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload scanned foods when returning to this page
    _loadScannedFoods();
  }

  Future<void> _loadScannedFoods() async {
    try {
      final foods = await _scannedFoodRepository.getRecentScannedFoods(
        limit: 6,
      );
      if (mounted) {
        setState(() {
          _scannedFoods = foods;
        });
      }
    } catch (e) {
      debugPrint('Unable to load scanned foods: $e');
    }
  }

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
    debugPrint('View report tapped');
  }

  /// Handle picture tap - navigate to detail page
  Future<void> _onPictureTap(ScannedFoodEntity food) async {
    final shouldDelete = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ScannedFoodDetailPage(scannedFood: food),
      ),
    );

    // If user deleted the photo, reload the list
    if (shouldDelete == true) {
      await _scannedFoodRepository.deleteScannedFood(food.id);
      await _loadScannedFoods();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final pages = HomePageConfig.getPages();

        return Scaffold(
          body: homeProvider.currentIndex == HomePageConfig.homeIndex
              ? _buildHomeContent(context)
              : pages[homeProvider.currentIndex],
          floatingActionButton: CustomFloatingActionButton(
            onRecordSelected: () => _navigateToRecord(homeProvider),
            onChatBotSelected: () => _navigateToChatBot(homeProvider),
            onScanFoodSelected: () => _onScanFoodTapped(),
            onReportSelected: () => _onReportTapped(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: homeProvider.currentIndex,
            onTap: (index) => _onBottomNavTap(homeProvider, index),
          ),
        );
      },
    );
  }

  /// Build home content
  Widget _buildHomeContent(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: localizations?.bottomNavHome ?? 'Trang chủ'),
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
              SizedBox(height: responsive.height(16)),
              RecentlyLoggedSection(
                scannedFoods: _scannedFoods,
                onViewAll: () {
                  // TODO: Navigate to full gallery view
                  debugPrint('View all tapped');
                },
                onPictureTap: (food) => _onPictureTap(food),
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
              style: TextStyle(fontSize: responsive.fontSize(14)),
            ),
            if (_activeFilters != null) ...[
              SizedBox(height: responsive.height(6)),
              Text(
                'Lọc: ${_activeFilters!['category']} | ${_activeFilters!['calorieMin']}-${_activeFilters!['calorieMax']} kcal',
                style: TextStyle(
                  fontSize: responsive.fontSize(11),
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Navigate to record page
  void _navigateToRecord(HomeProvider provider) {
    provider.setCurrentIndex(HomePageConfig.recordIndex);
  }

  /// Navigate to chat bot page
  void _navigateToChatBot(HomeProvider provider) {
    provider.setCurrentIndex(HomePageConfig.chatBotIndex);
  }

  /// Handle scan food action
  void _onScanFoodTapped() {
    PermissionService.requestCameraPermission(
      context,
      onPermissionGranted: () async {
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const FoodScannerPage()),
        );
        // Trigger a rebuild to refresh the scanned foods list
        if (mounted) {
          await _loadScannedFoods();
        }
      },
    );
  }

  /// Handle report action
  void _onReportTapped() {
    // TODO: Implement report functionality
  }

  /// Handle bottom navigation tap
  void _onBottomNavTap(HomeProvider provider, int index) {
    if (HomePageConfig.isValidIndex(index)) {
      provider.setCurrentIndex(index);
    }
  }
}
