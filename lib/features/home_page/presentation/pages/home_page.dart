import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../widgets/navigation/floating_action_button.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';
import '../widgets/navigation/home_navigation_handlers.dart';
import '../widgets/shared/guided_fab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../record_view_home/presentation/cubit/record_cubit.dart';
import '../../../record_view_home/presentation/cubit/record_state.dart';
import '../widgets/food_scanned/food_scanned_detail.dart';
import '../../../../config/home_page_config.dart';
import '../../../../common/snackbar_helper.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/permission_service.dart';
import '../widgets/layout/home_content.dart';
import 'daily_nutrition_detail_page.dart';
import '../../../upload_video/presentation/pages/video_processing_page.dart';

/// Main home page with bottom navigation
///
/// Quản lý navigation giữa các trang chính:
/// - Trang chủ (Home)
/// - Ghi nhận (Record)
/// - Chat bot
/// - Hồ sơ (Profile)
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.pagesBuilder,
    this.homeContentBuilder,
    this.scanFoodPageBuilder,
  });

  /// Optional override for building the tab pages.
  /// Useful for widget tests to avoid constructing heavy tabs.
  final List<Widget> Function()? pagesBuilder;

  /// Optional override for building the Home tab content.
  /// Useful for widget tests to bypass Firebase-dependent HomeContent.
  final Widget Function({
    required void Function(DateTime, List<FoodRecordEntity>) onViewReport,
    required VoidCallback onEmptyTap,
    required void Function(FoodRecordEntity) onItemTap,
  })?
  homeContentBuilder;

  /// Optional override for scan food page.
  /// Useful for widget tests to avoid plugin-heavy FoodScannerPage.
  final WidgetBuilder? scanFoodPageBuilder;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<Widget> _pages;

  bool get _isWidgetTest {
    return WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    );
  }

  @override
  void initState() {
    super.initState();
    // Initial load
    context.read<RecordCubit>().loadFoodRecords();

    // Prebuild tab pages once and keep them alive to avoid heavy rebuilds
    final pages = List<Widget>.of(
      (widget.pagesBuilder ?? HomePageConfig.getPages)(),
    );
    final homeBuilder = widget.homeContentBuilder;
    pages[0] = (homeBuilder != null)
        ? homeBuilder(
            onViewReport: _onViewReport,
            onEmptyTap: () => _onScanFoodTapped(context.read<HomeProvider>()),
            onItemTap: (food) => _onPictureTap(food),
          )
        : HomeContent(
            onViewReport: _onViewReport,
            onEmptyTap: () => _onScanFoodTapped(context.read<HomeProvider>()),
            onItemTap: (food) => _onPictureTap(food),
          );
    _pages = pages;

    // Schedule a one-time water reminder after 30s when user accesses Home
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isWidgetTest) return;
      await PermissionService().requestNotificationPermission();
      await LocalNotificationService().scheduleWaterReminderOncePerSession();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onViewReport(DateTime date, List<FoodRecordEntity> foodRecords) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            DailyNutritionDetailPage(date: date, foodRecords: foodRecords),
      ),
    );
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
        final bool isChatTab =
            homeProvider.currentIndex == HomePageConfig.chatBotIndex;
        final bool isRecordTab =
            homeProvider.currentIndex == HomePageConfig.recordIndex;
        final bool isKeyboardOpen =
            MediaQuery.of(context).viewInsets.bottom > 0;

        return Scaffold(
          body: IndexedStack(
            index: homeProvider.currentIndex,
            children: _pages,
          ),
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
                        onUploadVideoSelected: () => _navigateToVideoUpload(),
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

  /// Navigate to record page
  void _navigateToRecord(HomeProvider provider) {
    HomeNavigationHandlers.navigateToRecord(context);
  }

  /// Navigate to chat bot page
  void _navigateToChatBot(HomeProvider provider) {
    HomeNavigationHandlers.navigateToChatBot(context);
  }

  /// Handle scan food action - Request camera permission first
  void _onScanFoodTapped(HomeProvider homeProvider) async {
    // Keep test override behavior: if a scanFoodPageBuilder is provided,
    // route to that builder instead of the default FoodScannerPage.
    final builder = widget.scanFoodPageBuilder;
    if (builder != null) {
      final homeProviderFromContext = context.read<HomeProvider>();
      final bool isTodaySelected = DateUtils.isSameDay(
        homeProviderFromContext.selectedDate,
        DateTime.now(),
      );
      if (!isTodaySelected) {
        SnackBarHelper.showInfo(
          context,
          'Bạn chỉ có thể quét món ăn cho ngày hôm nay.',
        );
        return;
      }

      final hasPermission = await homeProviderFromContext
          .requestCameraPermission();
      if (!hasPermission) {
        if (!mounted) return;
        final localizations = AppLocalizations.of(context);
        SnackBarHelper.showWarning(
          context,
          localizations?.permissionCameraRequired ??
              'Vui lòng cấp quyền truy cập máy ảnh để sử dụng tính năng này.',
        );
        return;
      }

      if (!mounted) return;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: builder));
      if (mounted) {
        context.read<RecordCubit>().loadFoodRecords();
      }
      return;
    }

    await HomeNavigationHandlers.navigateToScanFood(context);
  }

  /// Handle report action
  void _onReportTapped() {
    HomeNavigationHandlers.navigateToReport(context);
  }

  void _navigateToVideoUpload() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const VideoProcessingPage()));
  }

  /// Handle bottom navigation tap
  void _onBottomNavTap(HomeProvider provider, int index) {
    HomeNavigationHandlers.onBottomNavTap(context, index);
  }
}
