import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import '../../../database/local_storage_service.dart';
import '../../../model/nutrition_calculation_model.dart';
import '../../../database/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'interface_confirmation.dart';
import '../../../widget/nutrition_summary/goal_card.dart';
import '../../../widget/nutrition_summary/nutrition_card.dart';
import '../../../widget/nutrition_summary/warning_card.dart';
import '../../../widget/nutrition_summary/recommendation_card.dart';

/// Màn hình tổng kết thông tin dinh dưỡng và cảnh báo
class NutritionSummary extends StatefulWidget {
  const NutritionSummary({super.key});

  @override
  State<NutritionSummary> createState() => _NutritionSummaryState();
}

class _NutritionSummaryState extends State<NutritionSummary> {
  final LocalStorageService _local = LocalStorageService();

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
          _errorMessage = AppLocalizations.of(context)!.noCalculationData;
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
        _errorMessage = AppLocalizations.of(context)!.errorLoadingData(e.toString());
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
              child: Text(AppLocalizations.of(context)!.back),
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
                GoalCard(userInfo: _userInfo!, targetDays: _targetDays!),
                const SizedBox(height: 16),
                NutritionCard(calculation: _calculation!),
                const SizedBox(height: 16),
                if (!_calculation!.isHealthy) ...[
                  WarningCard(calculation: _calculation!),
                  const SizedBox(height: 16),
                ],
                RecommendationCard(userInfo: _userInfo!),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
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
              AppLocalizations.of(context)!.planSummary,
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

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
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
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    // Nếu đã đăng nhập, lưu trực tiếp lên Firestore
                    await AuthService().saveNutritionPlan(user.uid, planData);
                  } else {
                    // Nếu là guest, lưu vào local storage
                    await _local.saveData('nutrition_plan', planData);
                  }

                  if (!_calculation!.isHealthy) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.planSavedWarning,
                          ),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  }

                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InterfaceConfirmation(
                          currentWeightKg: _userInfo?.currentWeightKg.round(),
                          goalWeightKg: _userInfo?.targetWeightKg.round(),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  _calculation!.isHealthy
                      ? AppLocalizations.of(context)!.confirm
                      : AppLocalizations.of(context)!.understandRisk,
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
