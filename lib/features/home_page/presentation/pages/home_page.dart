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
import 'notification_page.dart';

/// Main home page with bottom navigation
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          body: pages[homeProvider.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: homeProvider.currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) => homeProvider.setCurrentIndex(index),
            selectedFontSize: responsive.fontSize(14),
            unselectedFontSize: responsive.fontSize(12),
            iconSize: responsive.iconSize(24),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                label: localizations?.bottomNavHome ?? 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.note_add_outlined),
                label: localizations?.bottomNavRecord ?? 'Ghi nhận',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.smart_toy_outlined),
                label: localizations?.bottomNavChatBot ?? 'Chat bot',
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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  );
                },
              ),
              // Badge for unread notifications
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      '1', // Default water reminder
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Xem báo cáo chi tiết'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            SizedBox(height: responsive.height(16)),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _searchQuery.isEmpty
                          ? 'Danh sách bữa ăn sẽ hiển thị ở đây'
                          : 'Tìm kiếm: $_searchQuery',
                    ),
                    if (_activeFilters != null) ...[
                      SizedBox(height: responsive.height(8)),
                      Text(
                        'Lọc: ${_activeFilters!['category']} | ${_activeFilters!['calorieMin']}-${_activeFilters!['calorieMax']} kcal',
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
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
    );
  }
}
