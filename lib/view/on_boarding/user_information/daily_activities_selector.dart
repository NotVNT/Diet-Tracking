import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/widget/progress_bar/user_progress_bar.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

class DailyActivitiesSelector extends StatefulWidget {
  const DailyActivitiesSelector({super.key});

  @override
  State<DailyActivitiesSelector> createState() => _DailyActivitiesSelectorState();
}

class _DailyActivitiesSelectorState extends State<DailyActivitiesSelector> {
  int? _selectedIndex;

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
                child: ListView(
                  children: [
                    _buildActivityOption(
                      index: 0,
                      title: 'Ít vận động (Chủ yếu ngồi, ít hoặc không tập thể dục)',
                      
                      icon: Icons.weekend_outlined,
                    ),
                    _buildActivityOption(
                      index: 1,
                      title: 'Vận động nhẹ (Tập thể dục/thể thao 1-3 ngày/tuần)',
                      
                      icon: Icons.directions_walk,
                    ),
                    _buildActivityOption(
                      index: 2,
                      title: 'Vận động vừa (Tập thể dục/thể thao 3-5 ngày/tuần)',
                      
                      icon: Icons.directions_run,
                    ),
                    _buildActivityOption(
                      index: 3,
                      title: 'Vận động nặng (Tập thể dục/thể thao 6-7 ngày/tuần)',
                      
                      icon: Icons.fitness_center,
                    ),
                     _buildActivityOption(
                      index: 4,
                      title: 'Vận động rất nặng (Tập thể dục 2 lần/ngày, công việc lao động phổ thông)',
                      
                      icon: Icons.local_fire_department_outlined,
                    ),
                  ],
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
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black.withOpacity(0.08),
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
                        onPressed: () {
                          // No action, as requested
                        },
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

  
  Widget _buildActivityOption({
    required int index,
    required String title,
    
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
              border: isSelected ? Border.all(color: const Color(0xFF1F2A37), width: 2) : null,
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
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
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