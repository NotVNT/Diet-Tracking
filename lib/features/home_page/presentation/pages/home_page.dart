import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/permission_service.dart';
import '../providers/home_provider.dart';
import '../widgets/custom_floating_action_button.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/week_calendar_widget.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/calorie_goal_card.dart';
import '../widgets/recently_logged_section.dart';
import '../widgets/meals_list_section.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../record_view_home/presentation/cubit/record_cubit.dart';
import '../../../record_view_home/presentation/cubit/record_state.dart';
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

  @override
  void initState() {
    super.initState();
    // Initial load
    context.read<RecordCubit>().loadFoodRecords();
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
  Future<void> _onPictureTap(FoodRecordEntity food) async {
    final cubit = context.read<RecordCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ScannedFoodDetailPage(scannedFood: food),
        ),
      ),
    );
    // The UI will automatically update via the BlocBuilder listening to RecordCubit.
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
      body: BlocBuilder<RecordCubit, RecordState>(
        builder: (context, state) {
          if (state is RecordLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<FoodRecordEntity> foodRecords = [];
          if (state is RecordListLoaded) {
            foodRecords = state.records;
          }

          return SingleChildScrollView(
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
                  MealsListSection(
                    meals: foodRecords
                        .where((food) => food.recordType == RecordType.barcode)
                        .toList(),
                    onMealTap: (food) => _onPictureTap(food),
                    onViewAll: () {
                      debugPrint('View all meals tapped');
                    },
                  ),
                  SizedBox(height: responsive.height(16)),
                  RecentlyLoggedSection(
                    scannedFoods: foodRecords
                        .where(
                          (food) =>
                              food.imagePath != null &&
                              food.imagePath!.isNotEmpty &&
                              food.recordType == RecordType.food,
                        )
                        .toList(),
                    onViewAll: () {
                      debugPrint('View all photos tapped');
                    },
                    onPictureTap: (food) => _onPictureTap(food),
                  ),
                  SizedBox(height: responsive.height(24)),
                ],
              ),
            ),
          );
        },
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

  /// Handle scan food action - Request camera permission first
  void _onScanFoodTapped() async {
    final permissionService = PermissionService();

    // Request camera permission with single prompt
    final hasPermission = await permissionService.requestCameraPermission();

    if (!hasPermission) {
      return;
    }

    // Permission granted, navigate to FoodScannerPage
    if (mounted) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const FoodScannerPage()));
      // Trigger a rebuild to refresh the scanned foods list
      if (mounted) {
        context.read<RecordCubit>().loadFoodRecords();
      }
    }
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
