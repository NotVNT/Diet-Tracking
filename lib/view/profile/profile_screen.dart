import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../database/auth_service.dart';
import '../login/login_screen.dart';

/// Profile screen that displays user information or login prompt
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Constants
  static const Color _primaryColor = Color(0xFF4CAF50);
  static const Color _backgroundColor = Colors.white;
  static const Color _errorColor = Colors.red;
  static const double _borderRadius = 12.0;
  static const double _avatarSize = 100.0;
  static const double _buttonHeight = 50.0;

  // Services and state
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  // Profile options configuration
  static const List<Map<String, dynamic>> _profileOptions = [
    {
      'icon': Icons.person_outline,
      'title': 'Thông tin cá nhân',
      'requiresAuth': true,
    },
    {
      'icon': Icons.settings_outlined,
      'title': 'Cài đặt',
      'requiresAuth': false,
    },
    {'icon': Icons.help_outline, 'title': 'Trợ giúp', 'requiresAuth': false},
    {'icon': Icons.info_outline, 'title': 'Giới thiệu', 'requiresAuth': false},
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    _currentUser = _authService.currentUser;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return _buildMainScreen();
  }

  // Initialization Methods

  // UI Build Methods

  /// Builds loading screen
  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(child: CircularProgressIndicator()),
    );
  }

  /// Builds main profile screen
  Widget _buildMainScreen() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  40,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildProfileHeader(),
                  const SizedBox(height: 40),
                  _buildProfileOptions(),
                  const Spacer(),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds profile header based on authentication state
  Widget _buildProfileHeader() {
    if (_currentUser != null) {
      return _buildAuthenticatedUserHeader();
    } else {
      return _buildUnauthenticatedUserHeader();
    }
  }

  /// Builds header for authenticated users
  Widget _buildAuthenticatedUserHeader() {
    return Column(
      children: [
        _buildUserAvatar(isAuthenticated: true),
        const SizedBox(height: 16),
        _buildUserName(),
        const SizedBox(height: 8),
        _buildUserEmail(),
        const SizedBox(height: 8),
        _buildAuthStatusBadge(),
      ],
    );
  }

  /// Builds header for unauthenticated users
  Widget _buildUnauthenticatedUserHeader() {
    return Column(
      children: [
        _buildUserAvatar(isAuthenticated: false),
        const SizedBox(height: 16),
        _buildUnauthenticatedTitle(),
        const SizedBox(height: 8),
        _buildUnauthenticatedSubtitle(),
        const SizedBox(height: 20),
        _buildLoginButton(),
      ],
    );
  }

  /// Builds user avatar
  Widget _buildUserAvatar({required bool isAuthenticated}) {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: isAuthenticated ? _primaryColor : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(
        isAuthenticated ? Icons.person : Icons.person_outline,
        size: 50,
        color: isAuthenticated ? Colors.white : Colors.grey,
      ),
    );
  }

  /// Builds user name text
  Widget _buildUserName() {
    return Text(
      _currentUser?.displayName ?? 'Người dùng',
      style: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  /// Builds user email text
  Widget _buildUserEmail() {
    return Text(
      _currentUser?.email ?? 'user@example.com',
      style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
    );
  }

  /// Builds authentication status badge
  Widget _buildAuthStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Đã đăng nhập',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: _primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Builds unauthenticated title
  Widget _buildUnauthenticatedTitle() {
    return Text(
      'Chưa đăng nhập',
      style: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  /// Builds unauthenticated subtitle
  Widget _buildUnauthenticatedSubtitle() {
    return Text(
      'Đăng nhập để sử dụng đầy đủ tính năng',
      style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
      textAlign: TextAlign.center,
    );
  }

  /// Builds login button
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
        onPressed: _navigateToLogin,
        child: Text(
          'Đăng nhập ngay',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Builds profile options list
  Widget _buildProfileOptions() {
    return Column(
      children: _profileOptions
          .map((option) => _buildOptionItem(option))
          .toList(),
    );
  }

  /// Builds individual option item
  Widget _buildOptionItem(Map<String, dynamic> option) {
    final requiresAuth = option['requiresAuth'] as bool;
    final isDisabled = requiresAuth && _currentUser == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey[100] : Colors.grey[50],
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: isDisabled ? Colors.grey[300]! : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        leading: Icon(
          option['icon'] as IconData,
          color: isDisabled ? Colors.grey[400] : Colors.grey[600],
        ),
        title: Text(
          option['title'] as String,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDisabled ? Colors.grey[400] : Colors.black,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () => _onOptionTapped(option, isDisabled),
      ),
    );
  }

  /// Builds action buttons based on authentication state
  Widget _buildActionButtons() {
    if (_currentUser != null) {
      return _buildLogoutButton();
    } else {
      return _buildSignupButton();
    }
  }

  /// Builds logout button for authenticated users
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _errorColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
        onPressed: _handleLogout,
        child: Text(
          'Đăng xuất',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Builds signup button for unauthenticated users
  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
        onPressed: _navigateToLogin,
        child: Text(
          'Đăng ký tài khoản',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Event Handlers

  /// Handles option tap
  void _onOptionTapped(Map<String, dynamic> option, bool isDisabled) {
    if (isDisabled) {
      _showLoginRequiredDialog();
    } else {
      _handleOptionTap(option['title'] as String);
    }
  }

  /// Handles logout
  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      setState(() {
        _currentUser = null;
      });
    }
  }

  /// Navigates to login screen
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    ).then((_) {
      _checkAuthState();
    });
  }

  /// Shows login required dialog
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cần đăng nhập',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn cần đăng nhập để sử dụng tính năng này.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            _buildDialogCancelButton(context),
            _buildDialogLoginButton(context),
          ],
        );
      },
    );
  }

  /// Builds dialog cancel button
  Widget _buildDialogCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text('Hủy', style: GoogleFonts.inter(color: Colors.grey[600])),
    );
  }

  /// Builds dialog login button
  Widget _buildDialogLoginButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        _navigateToLogin();
      },
      child: Text(
        'Đăng nhập',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Handles option tap for authenticated users
  void _handleOptionTap(String option) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tính năng "$option" đang được phát triển',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: _primaryColor,
      ),
    );
  }
}
