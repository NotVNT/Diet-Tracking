import 'package:flutter/material.dart';
import '../features/chat_bot_view_home/presentation/pages/chat_bot_page.dart';
import '../features/profile_view_home/di/profile_di.dart';
import '../features/profile_view_home/presentation/pages/profile_page.dart';
import '../features/record_view_home/presentation/pages/record_page.dart';

/// Configuration class for home page
/// Quản lý danh sách các trang và index mapping
class HomePageConfig {
  /// Page indices
  static const int homeIndex = 0;
  static const int recordIndex = 1;
  static const int chatBotIndex = 2;
  static const int profileIndex = 3;

  /// Get all pages with their providers (excluding home which is built inline)
  static List<Widget> getPages() {
    return [
      const SizedBox.shrink(), // Home is built inline in HomePage
      const RecordPage(),
      const ChatBotPage(),
      ProfilePage(profileProvider: ProfileDI.getProfileProvider()),
    ];
  }

  /// Check if the given index is valid
  static bool isValidIndex(int index) {
    return index >= 0 && index <= profileIndex;
  }
}
