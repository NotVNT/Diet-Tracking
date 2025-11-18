import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../themes/theme_provider.dart';
import '../../../../common/language_selector.dart';
import '../../../../common/unit_selector.dart';
import '../../../../services/language_service.dart';
import '../../../../common/custom_app_bar.dart';

/// Settings page for app configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkModeEnabled = false;
  Language _selectedLanguage = Language.vi;
  UnitSystem _selectedUnit = UnitSystem.metric;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'vi';
    final unitCode = prefs.getString('unit') ?? 'metric';
    setState(() {
      _darkModeEnabled = themeProvider.isDarkMode;
      _selectedLanguage = languageCode == 'en' ? Language.en : Language.vi;
      _selectedUnit = unitCode == 'imperial' ? UnitSystem.imperial : UnitSystem.metric;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage == Language.vi ? 'vi' : 'en');
    await prefs.setString('unit', _selectedUnit == UnitSystem.metric ? 'metric' : 'imperial');
    // Dark mode is handled by ThemeProvider, no need to save separately
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.settingsTitle,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Giao diện
            _buildSectionTitle(AppLocalizations.of(context)!.settingsAppearance),
            _buildSettingCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: AppLocalizations.of(context)!.settingsDarkMode,
                  subtitle: AppLocalizations.of(context)!.settingsDarkModeSubtitle,
                  value: _darkModeEnabled,
                  onChanged: (value) async {
                    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                    setState(() {
                      _darkModeEnabled = value;
                    });
                    await themeProvider.toggleTheme();
                  },
                ),
                const Divider(height: 1),
                _buildLanguageTile(),
              ],
            ),
            const SizedBox(height: 24),
            
            // Đơn vị đo lường
            _buildSectionTitle(AppLocalizations.of(context)!.settingsUnits),
            _buildSettingCard(
              children: [
                _buildUnitTile(),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.language_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.settingsLanguage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          LanguageSelector(
            selected: _selectedLanguage,
            onChanged: (Language newLanguage) async {
              setState(() {
                _selectedLanguage = newLanguage;
              });
              await _saveSettings();
              
              // Change app language using LanguageService
              await LanguageService.changeLanguage(newLanguage);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnitTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.straighten_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.settingsUnitSystem,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          UnitSelector(
            selected: _selectedUnit,
            onChanged: (UnitSystem newUnit) async {
              setState(() {
                _selectedUnit = newUnit;
              });
              await _saveSettings();
            },
          ),
        ],
      ),
    );
  }
}
