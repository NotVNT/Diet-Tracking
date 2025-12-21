import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'long_term_results_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/progress_bar/started_progress_bar.dart';

class DietReasonScreen extends StatefulWidget {
  final List<String> selectedMainGoals;
  final List<String> selectedWeightReasons;
  const DietReasonScreen({
    super.key,
    required this.selectedMainGoals,
    required this.selectedWeightReasons,
  });

  @override
  State<DietReasonScreen> createState() => _DietReasonScreenState();
}

class _DietReasonScreenState extends State<DietReasonScreen> {
  Color get _bg => const Color(0xFFF6F3EB);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _muted => const Color(0xFF6B7280);
  Color get _primary => const Color(0xFFFF7A00);

  final Set<int> _selectedIndices = <int>{};

  final List<_ReasonItem> _reasons = const [
    _ReasonItem(icon: '📱', title: 'findSuitableMealPlan'),
    _ReasonItem(icon: '🧠', title: 'wantToBuildGoodHabits'),
    _ReasonItem(icon: '🕒', title: 'lackTimeToCook'),
    _ReasonItem(icon: '💼', title: 'improveWorkPerformance'),
    _ReasonItem(icon: '😴', title: 'poorSleep'),
    _ReasonItem(icon: '❤️', title: 'careAboutHeartHealth'),
    _ReasonItem(icon: '🧪', title: 'poorHealthIndicators'),
    _ReasonItem(icon: '💸', title: 'optimizeMealCosts'),
    _ReasonItem(icon: '✍️', title: 'other'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            StartedProgressBar(
              currentStep: 4,
              totalSteps: 4,
              activeColor: _primary,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)?.whatBroughtYouToUs ??
                      'Điều gì đã đưa bạn đến với chúng tôi?',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: _reasons.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildReasonTile(index),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedIndices.isEmpty
                      ? null
                      : () {
                          final reasons = _selectedIndices
                              .map(
                                (i) => _getLocalizedDietReasonTitle(
                                  context,
                                  _reasons[i].title,
                                ),
                              )
                              .toList(growable: false);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LongTermResultsScreen(
                                selectedMainGoals: widget.selectedMainGoals,
                                selectedWeightReasons:
                                    widget.selectedWeightReasons,
                                selectedDietReasons: reasons,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    disabledBackgroundColor: Colors.black.withValues(
                      alpha: 0.1,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.next ?? 'Tiếp theo',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonTile(int index) {
    final item = _reasons[index];
    final bool selected = _selectedIndices.contains(index);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() {
        if (selected) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: selected ? _primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(item.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _getLocalizedDietReasonTitle(context, item.title),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _accent,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? _primary : _muted,
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedDietReasonTitle(BuildContext context, String key) {
    switch (key) {
      case 'findSuitableMealPlan':
        return AppLocalizations.of(context)?.findSuitableMealPlan ??
            'Tìm kiếm kế hoạch ăn phù hợp';
      case 'wantToBuildGoodHabits':
        return AppLocalizations.of(context)?.wantToBuildGoodHabits ??
            'Muốn xây thói quen tốt';
      case 'lackTimeToCook':
        return AppLocalizations.of(context)?.lackTimeToCook ??
            'Thiếu thời gian nấu ăn';
      case 'improveWorkPerformance':
        return AppLocalizations.of(context)?.improveWorkPerformance ??
            'Cải thiện hiệu suất làm việc';
      case 'poorSleep':
        return AppLocalizations.of(context)?.poorSleep ?? 'Ngủ không ngon';
      case 'careAboutHeartHealth':
        return AppLocalizations.of(context)?.careAboutHeartHealth ??
            'Quan tâm sức khỏe tim mạch';
      case 'poorHealthIndicators':
        return AppLocalizations.of(context)?.poorHealthIndicators ??
            'Chỉ số sức khỏe chưa tốt';
      case 'optimizeMealCosts':
        return AppLocalizations.of(context)?.optimizeMealCosts ??
            'Muốn tối ưu chi phí bữa ăn';
      case 'other':
        return AppLocalizations.of(context)?.other ?? 'Khác';
      default:
        return key;
    }
  }
}

class _ReasonItem {
  final String icon;
  final String title;
  const _ReasonItem({required this.icon, required this.title});
}
