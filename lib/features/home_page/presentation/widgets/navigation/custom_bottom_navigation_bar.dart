import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../responsive/responsive.dart';

/// Custom bottom navigation bar for home page
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final localizations = AppLocalizations.of(context);

    // Map current page index to bottom nav display index
    final displayIndex = _getDisplayIndex(currentIndex);

    return BottomNavigationBar(
      currentIndex: displayIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _handleTap(index),
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
    );
  }

  /// Map page index to bottom navigation display index
  int _getDisplayIndex(int pageIndex) {
    // Pages: 0 Trang chủ, 1 Ghi nhận, 2 Chat bot, 3 Hồ sơ
    // Bottom nav: 0 Home, 1 FAB (empty), 2 Profile
    if (pageIndex == 1 || pageIndex == 2) {
      return 0; // Show Home as selected when on Record or Chat bot pages
    } else if (pageIndex > 2) {
      return 2; // Profile is index 2 in bottom nav
    }
    return pageIndex;
  }

  /// Handle bottom navigation tap
  void _handleTap(int index) {
    // Ignore tap on center item (FAB placeholder)
    if (index == 1) return;

    // Map bottom nav index to actual page index
    // 0 -> Home (0), 2 -> Profile (3)
    final pageIndex = index == 0 ? 0 : 3;
    onTap(pageIndex);
  }
}
