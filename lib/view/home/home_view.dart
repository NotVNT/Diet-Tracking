import 'package:diet_tracking_project/features/record_view_home/presentation/pages/record_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/chat_bot_view_home/presentation/pages/chat_bot_page.dart';
import '../profile/profile_view.dart';
import '../../features/record_view_home/di/record_di.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  // Pages: 0 Trang chủ, 1 Ghi nhận, 2 Chat bot, 3 Hồ sơ
  final List<Widget> _pages = [
    const _HomePage(),
    const RecordPage(),
    // Provide RecordCubit for ChatBotPage so the "Thêm vào danh sách" button can access it
    BlocProvider(
      create: (_) => RecordDI.getRecordCubit(),
      child: const ChatBotPage(),
    ),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
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
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: const Center(child: Text('Nội dung Trang chủ (đang phát triển)')),
    );
  }
}

// Profile page provided by ProfileView in ../profile/profile_view.dart
