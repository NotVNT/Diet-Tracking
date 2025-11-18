import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/custom_floating_action_button.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'home_page_config.dart';
import '../../../../common/permission_service.dart';
import '../../../food_scanner/presentation/pages/food_scanner_page.dart';

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
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final pages = HomePageConfig.getPages();

        return Scaffold(
          body: pages[homeProvider.currentIndex],
          floatingActionButton: CustomFloatingActionButton(
            onRecordSelected: () => _navigateToRecord(homeProvider),
            onChatBotSelected: () => _navigateToChatBot(homeProvider),
            onScanFoodSelected: () => _onScanFoodTapped(),
            onReportSelected: () => _onReportTapped(),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
      onPermissionGranted: () {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const FoodScannerPage(),
          ),
        );
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
