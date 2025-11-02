import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../database/local_storage_service.dart';
import '../../../model/nutrition_calculation_model.dart';
import '../../../services/nutrition_calculator_service.dart';
import '../../../widget/progress_bar/user_progress_bar.dart';
import 'nutrition_summary.dart';

/// Màn hình chọn số ngày để đạt mục tiêu cân nặng
class TargetDaysSelector extends StatefulWidget {
  const TargetDaysSelector({super.key});

  @override
  State<TargetDaysSelector> createState() => _TargetDaysSelectorState();
}

class _TargetDaysSelectorState extends State<TargetDaysSelector> {
  final LocalStorageService _local = LocalStorageService();

  int _selectedDays = 30; // Mặc định 30 ngày
  UserNutritionInfo? _userInfo;
  NutritionCalculation? _calculation;
  bool _isLoading = true;
  String? _errorMessage;

  // Các tùy chọn số ngày
  final List<int> _daysOptions = [7, 14, 30, 60, 90, 180, 365];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _local.readGuestData();

      // Kiểm tra dữ liệu cần thiết
      if (data['age'] == null ||
          data['gender'] == null ||
          data['heightCm'] == null ||
          data['weightKg'] == null ||
          data['goalWeightKg'] == null ||
          data['activityLevel'] == null) {
        setState(() {
          _errorMessage =
              'Thiếu thông tin người dùng. Vui lòng quay lại và nhập đầy đủ.';
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

      print(
        '📊 Calculating nutrition with the following user info: $_userInfo',
      );

      // Tính toán với số ngày mặc định
      _calculateNutrition();

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

  void _calculateNutrition() {
    if (_userInfo == null) return;

    _calculation = NutritionCalculatorService.calculate(
      userInfo: _userInfo!,
      targetDays: _selectedDays,
    );
  }

  void _onDaysChanged(int days) {
    setState(() {
      _selectedDays = days;
      _calculateNutrition();
    });
  }

  Future<void> _saveAndNavigate() async {
    if (_calculation == null) return;

    // Lưu số ngày mục tiêu và kết quả tính toán
    await _local.saveData('targetDays', _selectedDays);
    await _local.saveData('nutritionCalculation', _calculation!.toJson());

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NutritionSummary()),
      );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Progress Bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: ProgressBarWidget(
              progress: 7 / 8, // Bước 7/8
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bạn muốn đạt mục tiêu trong bao lâu?',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userInfo!.isLosingWeight
                ? 'Giảm ${_userInfo!.weightDifference.toStringAsFixed(1)} kg'
                : 'Tăng ${_userInfo!.weightDifference.toStringAsFixed(1)} kg',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Slider để chọn số ngày
                  _buildDaysSlider(),
                  const SizedBox(height: 24),
                  // Các tùy chọn nhanh
                  _buildQuickOptions(),
                  const SizedBox(height: 24),
                  // Thông tin tính toán
                  if (_calculation != null) _buildCalculationInfo(),
                  const SizedBox(height: 24),
                  // Cảnh báo nếu có
                  if (_calculation != null && !_calculation!.isHealthy)
                    _buildWarningCard(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildBottomButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDaysSlider() {
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
        children: [
          Text(
            '$_selectedDays ngày',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '≈ ${(_selectedDays / 7).toStringAsFixed(1)} tuần',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedDays.toDouble(),
            min: 7,
            max: 365,
            divisions: 51,
            activeColor: const Color(0xFF1F2A37),
            onChanged: (value) => _onDaysChanged(value.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _daysOptions.map((days) {
        final isSelected = _selectedDays == days;
        return InkWell(
          onTap: () => _onDaysChanged(days),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1F2A37) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1F2A37)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(
              '$days ngày',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalculationInfo() {
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
          Text(
            'Thông tin dinh dưỡng',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
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
            'Điều chỉnh mỗi ngày',
            '${_calculation!.dailyCaloriesAdjustment.toStringAsFixed(0)} cal',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            'Khoảng an toàn',
            '${_calculation!.caloriesMin.toStringAsFixed(0)} - ${_calculation!.caloriesMax.toStringAsFixed(0)} cal',
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
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
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

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFEF4444),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cảnh báo',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _calculation!.warningMessage ??
                      'Chế độ này có thể không phù hợp với sức khỏe của bạn.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Khuyến nghị: ${NutritionCalculatorService.calculateRecommendedDays(userInfo: _userInfo!)} ngày',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
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
                backgroundColor: const Color(0xFF1F2A37),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: _saveAndNavigate,
              child: Text(
                'Tiếp theo',
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
    );
  }
}
