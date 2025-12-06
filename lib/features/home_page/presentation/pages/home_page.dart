import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../widgets/navigation/custom_floating_action_button.dart';
import '../widgets/navigation/custom_bottom_navigation_bar.dart';
import '../widgets/shared/guided_fab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../record_view_home/presentation/cubit/record_cubit.dart';
import '../../../record_view_home/presentation/cubit/record_state.dart';
import '../../../food_scanner/presentation/pages/food_scanner_page.dart';
import '../widgets/food_scanned/food_scanned_detail.dart';
import '../../../../config/home_page_config.dart';
import '../../../../common/snackbar_helper.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/permission_service.dart';
import '../widgets/layout/home_content.dart';

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
  @override
  void initState() {
    super.initState();
    // Initial load
    context.read<RecordCubit>().loadFoodRecords();

    // Schedule a one-time water reminder after 30s when user accesses Home
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PermissionService().requestNotificationPermission();
      await LocalNotificationService().scheduleWaterReminderOncePerSession();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onViewReport() {}

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

        final bool isChatTab =
            homeProvider.currentIndex == HomePageConfig.chatBotIndex;
        final bool isRecordTab =
            homeProvider.currentIndex == HomePageConfig.recordIndex;
        final bool isKeyboardOpen =
            MediaQuery.of(context).viewInsets.bottom > 0;

        return Scaffold(
          body: homeProvider.currentIndex == HomePageConfig.homeIndex
              ? _buildHomeContent(context, homeProvider)
              : pages[homeProvider.currentIndex],
          floatingActionButton: ((isChatTab || isRecordTab) && isKeyboardOpen)
              ? null
              : BlocBuilder<RecordCubit, RecordState>(
                  builder: (context, state) {
                    bool showFabArrow = false;
                    final bool isHomeTab =
                        homeProvider.currentIndex == HomePageConfig.homeIndex;
                    final bool isViewingToday = DateUtils.isSameDay(
                      homeProvider.selectedDate,
                      DateTime.now(),
                    );
                    if (state is RecordListLoaded) {
                      final DateTime today = DateTime.now();
                      final bool hasTodayRecord = state.records.any(
                        (r) => DateUtils.isSameDay(r.date, today),
                      );
                      // Only show on Home tab, when viewing Today, and Today has no records
                      showFabArrow =
                          isHomeTab && isViewingToday && !hasTodayRecord;
                    } else {
                      // Until data is loaded, don't show the arrow
                      showFabArrow = false;
                    }

                    return GuidedFloatingActionButton(
                      showArrow: showFabArrow,
                      arrowDistance: ResponsiveHelper.of(context).width(84),
                      arrowColor: Theme.of(context).colorScheme.primary,
                      arrowSize: ResponsiveHelper.of(context).width(64),
                      child: CustomFloatingActionButton(
                        onRecordSelected: () => _navigateToRecord(homeProvider),
                        onChatBotSelected: () =>
                            _navigateToChatBot(homeProvider),
                        onScanFoodSelected: () =>
                            _onScanFoodTapped(homeProvider),
                        onReportSelected: () => _onReportTapped(),
                      ),
                    );
                  },
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
  Widget _buildHomeContent(BuildContext context, HomeProvider homeProvider) {
    return HomeContent(
      onViewReport: _onViewReport,
      onEmptyTap: () => _onScanFoodTapped(homeProvider),
      onItemTap: (food) => _onPictureTap(food),
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
  void _onScanFoodTapped(HomeProvider homeProvider) async {
    // Only allow scanning for today
    final bool isTodaySelected = DateUtils.isSameDay(
      homeProvider.selectedDate,
      DateTime.now(),
    );
    if (!isTodaySelected) {
      SnackBarHelper.showInfo(
        context,
        'Bạn chỉ có thể quét món ăn cho ngày hôm nay.',
      );
      return;
    }

    final hasPermission = await homeProvider.requestCameraPermission();

    if (!hasPermission) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        SnackBarHelper.showWarning(
          context,
          localizations?.permissionCameraRequired ??
              'Vui lòng cấp quyền truy cập máy ảnh để sử dụng tính năng này.',
        );
      }
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
  void _onReportTapped() {}

  /// Handle bottom navigation tap
  void _onBottomNavTap(HomeProvider provider, int index) {
    if (HomePageConfig.isValidIndex(index)) {
      provider.setCurrentIndex(index);
    }
  }
}
