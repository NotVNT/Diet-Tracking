import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/target_days_selector.dart';
import 'package:diet_tracking_project/widget/progress_bar/user_progress_bar.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyActivitiesSelector extends StatefulWidget {
  const DailyActivitiesSelector({super.key});

  @override
  State<DailyActivitiesSelector> createState() =>
      _DailyActivitiesSelectorState();
}

class _DailyActivitiesSelectorState extends State<DailyActivitiesSelector> {
  int? _selectedIndex;
  final LocalStorageService _local = LocalStorageService();

  final List<Map<String, dynamic>> _activityOptions = [
    {
      'title': 'Ít vận động',
      'description': '(Chủ yếu ngồi, ít hoặc không tập thể dục)',
      'icon': Icons.weekend_outlined,
    },
    {
      'title': 'Vận động nhẹ',
      'description': '(Tập thể dục/thể thao 1-3 ngày/tuần)',
      'icon': Icons.directions_walk,
    },
    {
      'title': 'Vận động vừa',
      'description': '(Tập thể dục/thể thao 3-5 ngày/tuần)',
      'icon': Icons.directions_run,
    },
    {
      'title': 'Vận động nặng',
      'description': '(Tập thể dục/thể thao 6-7 ngày/tuần)',
      'icon': Icons.fitness_center,
    },
    {
      'title': 'Vận động rất nặng',
      'description': '(Tập thể dục 2 lần/ngày, công việc lao động phổ thông)',
      'icon': Icons.local_fire_department_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Progress Bar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: ProgressBarWidget(
                  progress: 7 / 7, // Bước 7/7
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bạn hoạt động tích cực như thế nào mỗi ngày?',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _activityOptions.length,
                  itemBuilder: (context, index) {
                    final option = _activityOptions[index];
                    return _buildActivityOption(
                      index: index,
                      title: option['title'],
                      description: option['description'],
                      icon: option['icon'],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: const Color.fromRGBO(0, 0, 0, 0.08),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF2D3A4A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F2A37),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _selectedIndex == null
                            ? null // Disable button if nothing is selected
                            : _saveAndNavigate,
                        child: Text(
                          AppLocalizations.of(context)?.next ?? 'Tiếp theo',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndNavigate() async {
    if (_selectedIndex == null) return;

    final activityLevel = _activityOptions[_selectedIndex!]['title'];
    await _local.saveGuestData(activityLevel: activityLevel);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TargetDaysSelector()),
      );
    }
  }

  Widget _buildActivityOption({
    required int index,
    required String title,
    required String description,
    required IconData icon,
  }) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: const Color(0xFF1F2A37), width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF111827),
                          ),
                          children: [
                            TextSpan(
                              text: title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' $description',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(243, 244, 246, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF374151), size: 28),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF1F2A37),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
