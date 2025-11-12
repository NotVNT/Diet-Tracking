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

/// Main home page with bottom navigation
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final responsive = ResponsiveHelper.of(context);
        
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.note_add_outlined),
                label: 'Ghi nhận',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy_outlined),
                label: 'Chat bot',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Hồ sơ',
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Main home content page
class _HomeMainPage extends StatelessWidget {
  const _HomeMainPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Trang chủ',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thông báo'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text('Nội dung Trang chủ (đang phát triển)')),
    );
  }
}
