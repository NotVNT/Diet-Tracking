import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../login/login_screen.dart';
import '../on_boarding/welcome_screen.dart';

import '../../model/user.dart' as app_user;
import '../../database/auth_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthService _authService = AuthService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  app_user.User? _appUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final fb_auth.User? current = _authService.currentUser;
    if (current == null) {
      setState(() {
        _appUser = null; // clear cached profile when signed out
        _loading = false;
      });
      return;
    }
    final app_user.User? user = await _authService.getUserData(current.uid);
    setState(() {
      _appUser = user;
      _loading = false;
    });
  }

  String _defaultAvatarAsset() {
    final gender = _appUser?.gender;
    if (gender == app_user.GenderType.male) {
      return 'assets/gender/men.jpg';
    }
    if (gender == app_user.GenderType.female) {
      return 'assets/gender/women.jpg';
    }
    return 'assets/gender/men.jpg';
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final fb_auth.User? current = _authService.currentUser;
      if (current == null) return;

      final String path = 'avatars/${current.uid}.jpg';
      final Reference ref = _storage.ref().child(path);
      await ref.putFile(File(picked.path));
      final String url = await ref.getDownloadURL();

      await _authService.updateUserData(current.uid, {'avatarUrl': url});

      setState(() {
        _appUser = (_appUser ?? const app_user.User()).copyWith(avatarUrl: url);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể cập nhật ảnh: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final fb_auth.User? fbUser = _authService.currentUser;
    final String displayName =
        _appUser?.fullName ?? fbUser?.displayName ?? 'Người dùng';
    final String email = _appUser?.email ?? fbUser?.email ?? '';
    final String? avatarUrl = _appUser?.avatarUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.white,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : AssetImage(_defaultAvatarAsset()) as ImageProvider,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: InkWell(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                email,
                style: const TextStyle(color: Color(0xFF3B4A6B)),
              ),
            ),
            const SizedBox(height: 20),
            _MenuCard(
              children: [
                _MenuItem(
                  icon: Icons.edit_outlined,
                  label: 'Chỉnh sửa hồ sơ',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  label: 'Thêm mã PIN',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Cài đặt',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.group_add_outlined,
                  label: 'Mời bạn bè',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            _MenuCard(
              children: [
                if (fbUser != null)
                  _MenuItem(
                    icon: Icons.logout,
                    label: 'Đăng xuất',
                    isDanger: true,
                    onTap: () async {
                      await _authService.signOut();
                      if (!mounted) return;

                      // Chuyển về màn hình Welcome Screen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                        (route) => false, // Xóa tất cả các route trước đó
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã đăng xuất')),
                      );
                    },
                  )
                else
                  _MenuItem(
                    icon: Icons.login,
                    label: 'Đăng nhập',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isDanger
        ? const Color(0xFFE74C3C)
        : const Color(0xFF3B4A6B);
    final Color textColor = isDanger
        ? const Color(0xFFE74C3C)
        : const Color(0xFF111827);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
