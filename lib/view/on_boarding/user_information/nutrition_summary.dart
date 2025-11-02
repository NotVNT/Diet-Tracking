import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../database/local_storage_service.dart';
import '../../../model/nutrition_calculation_model.dart';
import '../../../services/nutrition_calculator_service.dart';
import '../../../database/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'interface_confirmation.dart';

/// Màn hình tổng kết thông tin dinh dưỡng và cảnh báo
class NutritionSummary extends StatefulWidget {
  const NutritionSummary({super.key});

  @override
  State<NutritionSummary> createState() => _NutritionSummaryState();
}

class _NutritionSummaryState extends State<NutritionSummary> {
  final LocalStorageService _local = LocalStorageService();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserNutritionInfo? _userInfo;
  NutritionCalculation? _calculation;
  int? _targetDays;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _local.readGuestData();
      final targetDays = await _local.getData('targetDays') as int?;
      final calculationJson =
          await _local.getData('nutritionCalculation') as Map<String, dynamic>?;

      if (targetDays == null || calculationJson == null) {
        setState(() {
          _errorMessage = 'Không tìm thấy dữ liệu tính toán.';
          _isLoading = false;
        });
        return;
      }

      _userInfo = UserNutritionInfo(
        age: data['age'] as int,
        gender: data['gender'] as String,
        heightCm: data['heightCm'] as double,
        currentWeightKg: data['weightKg'] as double,
        targetWeightKg: data['goalWeightKg'] as double,
        activityLevel: data['activityLevel'] as String,
      );

      _targetDays = targetDays;
      _calculation = NutritionCalculation.fromJson(calculationJson);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorView()
            : _buildMainContent(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGoalCard(),
                const SizedBox(height: 16),
                _buildNutritionCard(),
                const SizedBox(height: 16),
                if (!_calculation!.isHealthy) ...[
                  _buildWarningCard(),
                  const SizedBox(height: 16),
                ],
                _buildRecommendationCard(),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2A37),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.summarize_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Tổng kết kế hoạch',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _userInfo!.isLosingWeight
                    ? Icons.trending_down
                    : Icons.trending_up,
                color: const Color(0xFF1F2A37),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Mục tiêu của bạn',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Cân nặng hiện tại',
            '${_userInfo!.currentWeightKg.toStringAsFixed(1)} kg',
          ),
          _buildInfoRow(
            'Cân nặng mục tiêu',
            '${_userInfo!.targetWeightKg.toStringAsFixed(1)} kg',
          ),
          _buildInfoRow(
            'Chênh lệch',
            '${_userInfo!.weightDifference.toStringAsFixed(1)} kg',
            isHighlight: true,
          ),
          _buildInfoRow(
            'Thời gian',
            '$_targetDays ngày (≈ ${(_targetDays! / 7).toStringAsFixed(1)} tuần)',
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu,
                color: Color(0xFF1F2A37),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Thông tin dinh dưỡng',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'BMR',
            '${_calculation!.bmr.toStringAsFixed(0)} cal/ngày',
          ),
          _buildInfoRow(
            'TDEE',
            '${_calculation!.tdee.toStringAsFixed(0)} cal/ngày',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            'Calories mục tiêu',
            '${_calculation!.targetCalories.toStringAsFixed(0)} cal/ngày',
            isHighlight: true,
          ),
          _buildInfoRow(
            'Khoảng an toàn',
            '${_calculation!.caloriesMin.toStringAsFixed(0)} - ${_calculation!.caloriesMax.toStringAsFixed(0)} cal',
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '⚠️ Cảnh báo',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _calculation!.warningMessage ??
                'Chế độ này có thể không phù hợp với sức khỏe của bạn.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF991B1B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    final recommendedDays = NutritionCalculatorService.calculateRecommendedDays(
      userInfo: _userInfo!,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF10B981),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Khuyến nghị',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF065F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Khuyến nghị: $recommendedDays ngày (≈ ${(recommendedDays / 7).toStringAsFixed(1)} tuần)',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF065F46),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight
                  ? const Color(0xFF1F2A37)
                  : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(18),
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
                child: const Icon(Icons.arrow_back, color: Color(0xFF2D3A4A)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 64,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _calculation!.isHealthy
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () async {
                  final planData = _calculation!.toJson();
                  final user = _auth.currentUser;

                  if (user != null) {
                    // Nếu đã đăng nhập, lưu trực tiếp lên Firestore
                    await _authService.saveNutritionPlan(user.uid, planData);
                  } else {
                    // Nếu là guest, lưu vào local storage
                    await _local.saveData('nutrition_plan', planData);
                  }

                  if (!_calculation!.isHealthy) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Kế hoạch đã được lưu. Vui lòng tham khảo ý kiến chuyên gia.',
                          ),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                    }
                  }

                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InterfaceConfirmation(),
                      ),
                    );
                  }
                },
                child: Text(
                  _calculation!.isHealthy ? 'Xác nhận' : 'Tôi hiểu rủi ro',
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
    );
  }
}
