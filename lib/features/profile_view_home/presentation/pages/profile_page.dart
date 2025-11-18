import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../l10n/app_localizations.dart';
import '../providers/profile_provider.dart';
import '../../../../view/identities/login/login_main_screen.dart';
import '../../../../view/on_boarding/welcome_screen.dart';
import '../../../chat_bot_view_home/presentation/providers/chat_provider_factory.dart';
import '../widgets/app_info_section.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'data_sync_page.dart';
import 'support_page.dart';
import '../../../../common/custom_app_bar.dart';

/// Profile page with Clean Architecture
class ProfilePage extends StatefulWidget {
  final ProfileProvider profileProvider;

  const ProfilePage({
    super.key,
    required this.profileProvider,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    widget.profileProvider.loadProfile();
    widget.profileProvider.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    widget.profileProvider.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      await widget.profileProvider.uploadAvatar(File(picked.path));

      if (!mounted) return;
      debugPrint('Avatar updated successfully');
    } catch (e) {
      if (!mounted) return;
      debugPrint('Cannot update avatar: $e');
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await widget.profileProvider.signOut();

      // Clear chat history when logging out
      ChatProviderFactory.dispose();

      if (!mounted) return;

      // Navigate to Welcome Screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
        (route) => false,
      );

      debugPrint('User signed out successfully');
    } catch (e) {
      if (!mounted) return;
      debugPrint('Cannot sign out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.profileProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = widget.profileProvider.profile;
    final String displayName = profile?.displayName ?? AppLocalizations.of(context)!.profileUser;
    final String email = profile?.email ?? '';
    final bool isLoggedIn = widget.profileProvider.isLoggedIn;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.profileTitle,
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
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  backgroundImage: widget.profileProvider.getAvatarImage(),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                email,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _MenuCard(
              children: [
                _MenuItem(
                  icon: Icons.edit_outlined,
                  label: AppLocalizations.of(context)!.profileEditProfile,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          profileProvider: widget.profileProvider,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, thickness: 3),
                _MenuItem(
                  icon: Icons.bar_chart_rounded,
                  label: AppLocalizations.of(context)!.profileViewStatistics,
                  onTap: () {
                    // TODO: Navigate to statistics/report page
                    debugPrint('Feature in development');
                  },
                ),
                const Divider(height: 1, thickness: 3),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: AppLocalizations.of(context)!.profileSettings,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, thickness: 3),
                _MenuItem(
                  icon: Icons.cloud_sync_outlined,
                  label: AppLocalizations.of(context)!.profileDataAndSync,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DataSyncPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, thickness: 3),
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: AppLocalizations.of(context)!.profileSupport,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16), 
            _MenuCard(
              children: [
                if (isLoggedIn)
                  _MenuItem(
                    icon: Icons.logout,
                    label: AppLocalizations.of(context)!.profileSignOut,
                    isDanger: true,
                    onTap: _handleSignOut,
                  )
                else
                  _MenuItem(
                    icon: Icons.login,
                    label: AppLocalizations.of(context)!.profileSignIn,
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
            const SizedBox(height: 24), 
            AppInfoSection(
              appName: AppLocalizations.of(context)!.profileAppName,
              version: '1.0.0',
              description: AppLocalizations.of(context)!.profileAppDescription,
              // logoAsset: 'assets/logo/app_logo.png', // Uncomment nếu có logo
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
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
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    final Color textColor = isDanger
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

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
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
