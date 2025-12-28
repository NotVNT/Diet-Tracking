import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'diet_reason_screen.dart';
import '../../../database/local_storage_service.dart';
import '../../../database/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/progress_bar/started_progress_bar.dart';

/// Màn hình hỏi lý do tại sao người dùng chọn mục tiêu cụ thể
/// (giảm cân, tăng cân, duy trì cân nặng, tăng cơ)
class GoalReasonScreen extends StatefulWidget {
  final List<String> selectedMainGoals;
  final LocalStorageService? localStorageService;
  final AuthService? authService;

  const GoalReasonScreen({
    super.key,
    required this.selectedMainGoals,
    this.localStorageService,
    this.authService,
  });

  @override
  State<GoalReasonScreen> createState() => _GoalReasonScreenState();
}

class _GoalReasonScreenState extends State<GoalReasonScreen> {
  // Theme colors
  Color get _bg => const Color(0xFFF6F3EB);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _muted => const Color(0xFF6B7280);
  Color get _primary => const Color(0xFFFF7A00);

  final Set<int> _selectedIndices = <int>{};
  late LocalStorageService _local;
  late AuthService _auth;

  @override
  void initState() {
    super.initState();
    _local = widget.localStorageService ?? LocalStorageService();
    _auth = widget.authService ?? AuthService();
  }

  /// Lấy danh sách lý do dựa trên mục tiêu đã chọn
  List<_ReasonItem> _getReasonsForGoal(BuildContext context) {
    final goal = widget.selectedMainGoals.isNotEmpty
        ? widget.selectedMainGoals.first
        : '';

    // Kiểm tra mục tiêu bằng cách so sánh với localized strings
    final loseWeight = AppLocalizations.of(context)?.loseWeight ?? 'Giảm cân';
    final gainWeight = AppLocalizations.of(context)?.gainWeight ?? 'Tăng cân';
    final maintainWeight =
        AppLocalizations.of(context)?.maintainWeight ?? 'Duy trì cân nặng';
    final buildMuscle = AppLocalizations.of(context)?.buildMuscle ?? 'Tăng cơ';

    if (goal.startsWith(loseWeight)) {
      return _loseWeightReasons;
    } else if (goal.startsWith(gainWeight)) {
      return _gainWeightReasons;
    } else if (goal.startsWith(maintainWeight)) {
      return _maintainWeightReasons;
    } else if (goal.startsWith(buildMuscle)) {
      return _buildMuscleReasons;
    }

    // Default fallback
    return _loseWeightReasons;
  }

  /// Lấy câu hỏi phù hợp với mục tiêu
  String _getQuestionForGoal(BuildContext context) {
    final goal = widget.selectedMainGoals.isNotEmpty
        ? widget.selectedMainGoals.first
        : '';

    final loseWeight = AppLocalizations.of(context)?.loseWeight ?? 'Giảm cân';
    final gainWeight = AppLocalizations.of(context)?.gainWeight ?? 'Tăng cân';
    final maintainWeight =
        AppLocalizations.of(context)?.maintainWeight ?? 'Duy trì cân nặng';
    final buildMuscle = AppLocalizations.of(context)?.buildMuscle ?? 'Tăng cơ';

    if (goal.startsWith(loseWeight)) {
      return AppLocalizations.of(context)?.whyDoYouWantToLoseWeight ??
          'Tại sao bạn muốn giảm cân?';
    } else if (goal.startsWith(gainWeight)) {
      return AppLocalizations.of(context)?.whyDoYouWantToGainWeight ??
          'Tại sao bạn muốn tăng cân?';
    } else if (goal.startsWith(maintainWeight)) {
      return AppLocalizations.of(context)?.whyDoYouWantToMaintainWeight ??
          'Tại sao bạn muốn duy trì cân nặng?';
    } else if (goal.startsWith(buildMuscle)) {
      return AppLocalizations.of(context)?.whyDoYouWantToBuildMuscle ??
          'Tại sao bạn muốn tăng cơ?';
    }

    return AppLocalizations.of(context)?.whyDidYouChooseThisGoal ??
        'Tại sao bạn chọn mục tiêu này?';
  }

  @override
  Widget build(BuildContext context) {
    final reasons = _getReasonsForGoal(context);
    final question = _getQuestionForGoal(context);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and progress bar
            StartedProgressBar(
              currentStep: 2,
              totalSteps: 4,
              activeColor: _primary,
            ),

            // Question title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  question,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Reasons list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: reasons.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildReasonTile(index, reasons[index]),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedIndices.isEmpty ? null : _handleNext,
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

  Widget _buildReasonTile(int index, _ReasonItem item) {
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
                _getLocalizedReasonTitle(context, item.titleKey),
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

  Future<void> _handleNext() async {
    final reasons = _getReasonsForGoal(context);
    final selectedReasons = _selectedIndices
        .map((i) => _getEnglishReasonTitle(reasons[i].titleKey))
        .toList(growable: false);

    // Lưu reasons vào localStorage
    await _local.saveGuestData(weightReasons: selectedReasons);

    // Nếu đã đăng nhập: cũng lưu trực tiếp vào Firestore
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _auth.updateUserData(uid, {'weightReasons': selectedReasons});
      } catch (_) {}
    }

    if (!mounted) return;

    // Chuyển sang màn hình tiếp theo
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => DietReasonScreen(
              selectedMainGoals: widget.selectedMainGoals,
              selectedWeightReasons: selectedReasons,
            ),
      ),
    );
  }

  String _getEnglishReasonTitle(String key) {
    switch (key) {
      // Lose weight reasons
      case 'improveHealth':
        return 'Improve health';
      case 'feelMoreConfident':
        return 'Feel more confident';
      case 'fitIntoClothes':
        return 'Fit into clothes';
      case 'doctorRecommendation':
        return 'Doctor recommendation';
      case 'improveAppearance':
        return 'Improve appearance';
      case 'moreEnergy':
        return 'Have more energy';
      case 'healthyLifestyle':
        return 'Healthy lifestyle';

      // Gain weight reasons
      case 'buildStrength':
        return 'Build strength';
      case 'improveAthletics':
        return 'Improve athletics';
      case 'lookMoreMuscular':
        return 'Look more muscular';
      case 'recoverFromIllness':
        return 'Recover from illness';
      case 'increaseAppetite':
        return 'Increase appetite';

      // Maintain weight reasons
      case 'stayHealthy':
        return 'Stay healthy';
      case 'preventWeightGain':
        return 'Prevent weight gain';
      case 'balancedLifestyle':
        return 'Balanced lifestyle';
      case 'maintainFitness':
        return 'Maintain fitness';

      // Build muscle reasons
      case 'getStronger':
        return 'Get stronger';
      case 'improveBodyComposition':
        return 'Improve body composition';
      case 'athleticPerformance':
        return 'Athletic performance';
      case 'lookToned':
        return 'Look toned';
      case 'boostMetabolism':
        return 'Boost metabolism';

      case 'other':
        return 'Other';
      default:
        return key;
    }
  }

  String _getLocalizedReasonTitle(BuildContext context, String key) {
    final loc = AppLocalizations.of(context);
    switch (key) {
      // Lose weight reasons
      case 'improveHealth':
        return loc?.improveHealth ?? 'Cải thiện sức khỏe';
      case 'feelMoreConfident':
        return loc?.feelMoreConfident ?? 'Cảm thấy tự tin hơn';
      case 'fitIntoClothes':
        return loc?.fitIntoClothes ?? 'Vừa với quần áo';
      case 'doctorRecommendation':
        return loc?.doctorRecommendation ?? 'Theo khuyến nghị của bác sĩ';
      case 'improveAppearance':
        return loc?.improveAppearance ?? 'Cải thiện ngoại hình';
      case 'moreEnergy':
        return loc?.moreEnergy ?? 'Có nhiều năng lượng hơn';
      case 'healthyLifestyle':
        return loc?.healthyLifestyle ?? 'Lối sống lành mạnh';

      // Gain weight reasons
      case 'buildStrength':
        return loc?.buildStrength ?? 'Tăng sức mạnh';
      case 'improveAthletics':
        return loc?.improveAthletics ?? 'Cải thiện thể thao';
      case 'lookMoreMuscular':
        return loc?.lookMoreMuscular ?? 'Trông cơ bắp hơn';
      case 'recoverFromIllness':
        return loc?.recoverFromIllness ?? 'Hồi phục sau bệnh';
      case 'increaseAppetite':
        return loc?.increaseAppetite ?? 'Tăng cảm giác thèm ăn';

      // Maintain weight reasons
      case 'stayHealthy':
        return loc?.stayHealthy ?? 'Giữ sức khỏe';
      case 'preventWeightGain':
        return loc?.preventWeightGain ?? 'Ngăn tăng cân';
      case 'balancedLifestyle':
        return loc?.balancedLifestyle ?? 'Lối sống cân bằng';
      case 'maintainFitness':
        return loc?.maintainFitness ?? 'Duy trì thể lực';

      // Build muscle reasons
      case 'getStronger':
        return loc?.getStronger ?? 'Trở nên mạnh mẽ hơn';
      case 'improveBodyComposition':
        return loc?.improveBodyComposition ?? 'Cải thiện thành phần cơ thể';
      case 'athleticPerformance':
        return loc?.athleticPerformance ?? 'Hiệu suất thể thao';
      case 'lookToned':
        return loc?.lookToned ?? 'Trông săn chắc';
      case 'boostMetabolism':
        return loc?.boostMetabolism ?? 'Tăng cường trao đổi chất';

      case 'other':
        return loc?.other ?? 'Khác';
      default:
        return key;
    }
  }

  // Danh sách lý do cho mục tiêu giảm cân
  static const List<_ReasonItem> _loseWeightReasons = [
    _ReasonItem(icon: '❤️', titleKey: 'improveHealth'),
    _ReasonItem(icon: '😊', titleKey: 'feelMoreConfident'),
    _ReasonItem(icon: '👕', titleKey: 'fitIntoClothes'),
    _ReasonItem(icon: '🩺', titleKey: 'doctorRecommendation'),
    _ReasonItem(icon: '✨', titleKey: 'improveAppearance'),
    _ReasonItem(icon: '⚡', titleKey: 'moreEnergy'),
    _ReasonItem(icon: '🌱', titleKey: 'healthyLifestyle'),
    _ReasonItem(icon: '✍️', titleKey: 'other'),
  ];

  // Danh sách lý do cho mục tiêu tăng cân
  static const List<_ReasonItem> _gainWeightReasons = [
    _ReasonItem(icon: '💪', titleKey: 'buildStrength'),
    _ReasonItem(icon: '🏃', titleKey: 'improveAthletics'),
    _ReasonItem(icon: '🦾', titleKey: 'lookMoreMuscular'),
    _ReasonItem(icon: '❤️', titleKey: 'improveHealth'),
    _ReasonItem(icon: '🩺', titleKey: 'recoverFromIllness'),
    _ReasonItem(icon: '🍽️', titleKey: 'increaseAppetite'),
    _ReasonItem(icon: '😊', titleKey: 'feelMoreConfident'),
    _ReasonItem(icon: '✍️', titleKey: 'other'),
  ];

  // Danh sách lý do cho mục tiêu duy trì cân nặng
  static const List<_ReasonItem> _maintainWeightReasons = [
    _ReasonItem(icon: '❤️', titleKey: 'stayHealthy'),
    _ReasonItem(icon: '⚖️', titleKey: 'preventWeightGain'),
    _ReasonItem(icon: '🌱', titleKey: 'balancedLifestyle'),
    _ReasonItem(icon: '💪', titleKey: 'maintainFitness'),
    _ReasonItem(icon: '😊', titleKey: 'feelMoreConfident'),
    _ReasonItem(icon: '⚡', titleKey: 'moreEnergy'),
    _ReasonItem(icon: '✍️', titleKey: 'other'),
  ];

  // Danh sách lý do cho mục tiêu tăng cơ
  static const List<_ReasonItem> _buildMuscleReasons = [
    _ReasonItem(icon: '💪', titleKey: 'getStronger'),
    _ReasonItem(icon: '🏋️', titleKey: 'improveBodyComposition'),
    _ReasonItem(icon: '🏃', titleKey: 'athleticPerformance'),
    _ReasonItem(icon: '✨', titleKey: 'lookToned'),
    _ReasonItem(icon: '🔥', titleKey: 'boostMetabolism'),
    _ReasonItem(icon: '😊', titleKey: 'feelMoreConfident'),
    _ReasonItem(icon: '❤️', titleKey: 'improveHealth'),
    _ReasonItem(icon: '✍️', titleKey: 'other'),
  ];
}

/// Model cho mỗi lý do
class _ReasonItem {
  final String icon;
  final String titleKey;

  const _ReasonItem({required this.icon, required this.titleKey});
}
