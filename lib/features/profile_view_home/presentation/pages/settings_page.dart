import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../../themes/theme_provider.dart';

/// Settings page for app configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoSyncEnabled = true;
  String _selectedLanguage = 'Tiếng Việt';
  String _selectedUnit = 'Metric (kg, cm)';

  final List<String> _languages = [
    'Tiếng Việt',
    'English',
  ];

  final List<String> _units = [
    'Metric (kg, cm)',
    'Imperial (lb, in)',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = themeProvider.isDarkMode;
      _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'Tiếng Việt';
      _selectedUnit = prefs.getString('unit') ?? 'Metric (kg, cm)';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('auto_sync_enabled', _autoSyncEnabled);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('unit', _selectedUnit);
    // Dark mode is handled by ThemeProvider, no need to save separately
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Thông báo
            _buildSectionTitle('Thông báo'),
            _buildSettingCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Thông báo',
                  subtitle: 'Nhận thông báo về bữa ăn và mục tiêu',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Giao diện
            _buildSectionTitle('Giao diện'),
            _buildSettingCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Chế độ tối',
                  subtitle: 'Sử dụng giao diện tối',
                  value: _darkModeEnabled,
                  onChanged: (value) async {
                    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                    setState(() {
                      _darkModeEnabled = value;
                    });
                    await themeProvider.toggleTheme();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_darkModeEnabled 
                            ? 'Đã chuyển sang chế độ tối' 
                            : 'Đã chuyển sang chế độ sáng'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSelectTile(
                  icon: Icons.language_outlined,
                  title: 'Ngôn ngữ',
                  value: _selectedLanguage,
                  onTap: () => _showLanguageDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Đơn vị đo lường
            _buildSectionTitle('Đơn vị đo lường'),
            _buildSettingCard(
              children: [
                _buildSelectTile(
                  icon: Icons.straighten_outlined,
                  title: 'Hệ đo lường',
                  value: _selectedUnit,
                  onTap: () => _showUnitDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Dữ liệu & Đồng bộ
            _buildSectionTitle('Dữ liệu & Đồng bộ'),
            _buildSettingCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.sync_outlined,
                  title: 'Tự động đồng bộ',
                  subtitle: 'Đồng bộ dữ liệu tự động với cloud',
                  value: _autoSyncEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoSyncEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.backup_outlined,
                  title: 'Sao lưu dữ liệu',
                  subtitle: 'Sao lưu dữ liệu của bạn',
                  onTap: () {
                    _showBackupDialog();
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.delete_outline,
                  title: 'Xóa cache',
                  subtitle: 'Xóa dữ liệu tạm thời',
                  onTap: () {
                    _showClearCacheDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Về ứng dụng
            _buildSectionTitle('Về ứng dụng'),
            _buildSettingCard(
              children: [
                _buildInfoTile(
                  icon: Icons.info_outline,
                  title: 'Phiên bản',
                  value: '1.0.0',
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Chính sách bảo mật',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang mở chính sách bảo mật...')),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.description_outlined,
                  title: 'Điều khoản sử dụng',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang mở điều khoản sử dụng...')),
                    );
                  },
                ),
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

  Widget _buildSelectTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && selected != _selectedLanguage) {
      setState(() {
        _selectedLanguage = selected;
      });
      await _saveSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã chuyển sang $selected')),
      );
    }
  }

  Future<void> _showUnitDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn hệ đo lường'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _units.map((unit) {
            return RadioListTile<String>(
              title: Text(unit),
              value: unit,
              groupValue: _selectedUnit,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && selected != _selectedUnit) {
      setState(() {
        _selectedUnit = selected;
      });
      await _saveSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã chuyển sang $selected')),
      );
    }
  }

  Future<void> _showBackupDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sao lưu dữ liệu'),
        content: const Text('Bạn có muốn sao lưu toàn bộ dữ liệu của mình không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sao lưu'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      // TODO: Implement backup logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang sao lưu dữ liệu...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showClearCacheDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa cache'),
        content: const Text('Bạn có chắc chắn muốn xóa dữ liệu tạm thời không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      // TODO: Implement clear cache logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa cache thành công'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
