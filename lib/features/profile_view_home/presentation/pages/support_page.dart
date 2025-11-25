import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'help_center_page.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../../common/snackbar_helper.dart';

/// Support and about page
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.supportTitle,
        showBackButton: true,
        showNotificationBell: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            _buildSettingCard(
              context,
              children: [
                const Divider(height: 1),
                _buildActionTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: AppLocalizations.of(context)!.supportPrivacyPolicy,
                                    onTap: () {
                    SnackBarHelper.showInfo(
                      context,
                      AppLocalizations.of(context)!.supportOpeningPrivacyPolicy,
                    );
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  context,
                  icon: Icons.description_outlined,
                  title: AppLocalizations.of(context)!.supportTermsOfService,
                                    onTap: () {
                    SnackBarHelper.showInfo(
                      context,
                      AppLocalizations.of(context)!.supportOpeningTermsOfService,
                    );
                  },
                ),
               const Divider(height: 1),
                 _buildActionTile(
                  context,
                  icon: Icons.lightbulb_outline,
                  title: AppLocalizations.of(context)!.supportRecommendationSources,
                                    onTap: () {
                    SnackBarHelper.showInfo(
                      context,
                      AppLocalizations.of(context)!.supportOpeningRecommendationSources,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Social Media Section
            _buildSocialMediaSection(context),
            
            const SizedBox(height: 16),
            
            // Support Center Section
            _buildSupportCenterSection(context),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF2D1B5E),
                  const Color(0xFF1F1B2E),
                ]
              : [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.15).toInt()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.supportFindVGPOnSocialMedia,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialMediaButton(
                context,
                imagePath: 'assets/icon/tiktok.png',
                label: AppLocalizations.of(context)!.supportTiktok,
                                onTap: () {
                  SnackBarHelper.showInfo(
                    context,
                    AppLocalizations.of(context)!.supportOpeningTiktok,
                  );
                },
              ),
              _buildSocialMediaButton(
                context,
                imagePath: 'assets/icon/facebook.png',
                label: AppLocalizations.of(context)!.supportFacebook,
                                onTap: () {
                  SnackBarHelper.showInfo(
                    context,
                    AppLocalizations.of(context)!.supportOpeningFacebook,
                  );
                },
              ),
              _buildSocialMediaButton(
                context,
                imagePath: 'assets/icon/instagram.png',
                label: AppLocalizations.of(context)!.supportInstagram,
                                onTap: () {
                  SnackBarHelper.showInfo(
                    context,
                    AppLocalizations.of(context)!.supportOpeningInstagram,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaButton(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF2D2842)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withAlpha((255 * 0.1).toInt())
                : Theme.of(context).colorScheme.outline.withAlpha((255 * 0.2).toInt()),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withAlpha((255 * 0.3).toInt())
                  : Theme.of(context).colorScheme.primary.withAlpha((255 * 0.08).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withAlpha((255 * 0.05).toInt())
                    : Theme.of(context).colorScheme.primary.withAlpha((255 * 0.05).toInt()),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.image,
                        color: isDarkMode
                            ? Colors.white.withAlpha((255 * 0.5).toInt())
                            : Colors.grey[600],
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCenterSection(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HelpCenterPage(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha((255 * 0.04).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.supportHelpCenter,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.supportAlwaysHereToHelp,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha((255 * 0.04).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha((255 * 0.3).toInt()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
