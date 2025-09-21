import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

/// Main navigation screen with bottom navigation bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Constants
  static const Color _backgroundColor = Colors.white;
  static const Color _selectedColor = Colors.black;
  static const Color _unselectedColor = Color(0xFF6B7280);
  static const double _borderRadius = 20.0;
  static const double _iconSize = 20.0;
  static const double _textSize = 14.0;

  // State
  int _currentIndex = 0;

  // Navigation configuration
  static const List<Map<String, dynamic>> _navigationItems = [
    {'icon': Icons.home, 'label': 'Home'},
    {'icon': Icons.person_outline, 'label': 'Profile'},
  ];

  // Screens
  final List<Widget> _screens = [const HomeScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // UI Build Methods

  /// Builds the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(),
          ),
        ),
      ),
    );
  }

  /// Builds all navigation items
  List<Widget> _buildNavigationItems() {
    return List.generate(_navigationItems.length, (index) {
      final item = _navigationItems[index];
      return _buildNavItem(
        index: index,
        icon: item['icon'] as IconData,
        label: item['label'] as String,
        isSelected: _currentIndex == index,
      );
    });
  }

  /// Builds individual navigation item
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : _unselectedColor,
              size: _iconSize,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : _unselectedColor,
                fontSize: _textSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event Handlers

  /// Handles navigation item tap
  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
