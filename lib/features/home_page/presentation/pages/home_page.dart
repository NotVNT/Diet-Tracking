import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../chat_bot_view_home/presentation/pages/chat_bot_page.dart';
import '../../../profile_view_home/di/profile_di.dart';
import '../../../profile_view_home/presentation/pages/profile_page.dart';
import '../../../record_view_home/di/record_di.dart';
import '../../../record_view_home/presentation/pages/record_page.dart';
import '../../../../responsive/responsive.dart';
import '../providers/home_provider.dart';
import '../widgets/week_calendar_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/calorie_goal_card.dart';
import '../widgets/speed_dial_fab.dart';
import '../../../../utils/snackbar_helper.dart';

/// Main home page with bottom navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isFabOpen = false;
  final GlobalKey<SpeedDialFabState> _fabKey = GlobalKey<SpeedDialFabState>();

  void _setFabOpen(bool isOpen) {
    setState(() {
      _isFabOpen = isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final responsive = ResponsiveHelper.of(context);
        final localizations = AppLocalizations.of(context);
        
        // Pages: 0 Trang chủ, 1 Ghi nhận, 2 Chat bot, 3 Hồ sơ
        final pages = [
          const _HomeMainPage(),
          BlocProvider(
            create: (_) => RecordDI.getRecordCubit()..loadFoodRecords(),
            child: const RecordPage(),
          ),
          // Provide RecordCubit for ChatBotPage so the "Thêm vào danh sách" button can access it
          BlocProvider(
            create: (_) => RecordDI.getRecordCubit(),
            child: const ChatBotPage(),
          ),
          ProfilePage(profileProvider: ProfileDI.getProfileProvider()),
        ];
        
        return Scaffold(
          body: Stack(
            children: [
              pages[homeProvider.currentIndex],
              // Background overlay when FAB is open
              if (_isFabOpen)
                GestureDetector(
                  onTap: () {
                    _fabKey.currentState?.close();
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
            ],
          ),
          floatingActionButton: SpeedDialFab(
            key: _fabKey,
            actions: [
              SpeedDialAction(
                icon: Icons.note_add_outlined,
                label: localizations?.bottomNavRecord ?? 'Ghi nhận',
                onTap: () => homeProvider.setCurrentIndex(1),
              ),
              SpeedDialAction(
                icon: Icons.smart_toy_outlined,
                label: localizations?.bottomNavChatBot ?? 'Chat bot',
                onTap: () => homeProvider.setCurrentIndex(2),
              ),
            ],
            onToggle: _setFabOpen,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: homeProvider.currentIndex == 1 || homeProvider.currentIndex == 2 
                ? 0 // Show Home as selected when on Record or Chat bot pages
                : homeProvider.currentIndex > 2 
                    ? 2 // Profile is now index 2 in bottom nav
                    : homeProvider.currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              // Ignore tap on center item (FAB placeholder)
              if (index == 1) return;
              
              // Map bottom nav index to actual page index
              // 0 -> Home (0), 2 -> Profile (3)
              final pageIndex = index == 0 ? 0 : 3;
              homeProvider.setCurrentIndex(pageIndex);
            },
            selectedFontSize: responsive.fontSize(14),
            unselectedFontSize: responsive.fontSize(12),
            iconSize: responsive.iconSize(24),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                label: localizations?.bottomNavHome ?? 'Trang chủ',
              ),
              const BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Empty space for FAB
                label: '',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                label: localizations?.bottomNavProfile ?? 'Hồ sơ',
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Main home content page
class _HomeMainPage extends StatefulWidget {
  const _HomeMainPage();

  @override
  State<_HomeMainPage> createState() => _HomeMainPageState();
}

class _HomeMainPageState extends State<_HomeMainPage> {
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
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                  // TODO: Load data for selected date
                  debugPrint('Selected date: $date');
                },
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
                onViewReport: () {
                  // TODO: Navigate to detailed report
                  SnackBarHelper.showInfo(context, 'Xem báo cáo chi tiết');
                },
              ),
              SizedBox(height: responsive.height(12)),
              Center(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
