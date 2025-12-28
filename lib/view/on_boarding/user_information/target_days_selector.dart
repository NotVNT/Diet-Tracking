import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../widget/progress_bar/user_progress_bar.dart';
import '../../../widget/target_days/days_slider_card.dart';
import '../../../widget/target_days/nutrition_info_card.dart';
import '../../../widget/target_days/warning_card.dart';
import 'nutrition_summary.dart';
import '../../../model/target_days_view_model.dart';

/// Màn hình chọn số ngày để đạt mục tiêu cân nặng
class TargetDaysSelector extends StatelessWidget {
  const TargetDaysSelector({super.key});

  static const List<int> _daysOptions = [7, 14, 30, 60, 90, 180, 365];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TargetDaysViewModel(),
      child: Consumer<TargetDaysViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F7FF),
            body: SafeArea(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null
                      ? _ErrorView(errorMessage: vm.errorMessage!)
                      : _MainContent(
                          daysOptions: _daysOptions,
                          onNext: () async {
                            final ok = await vm.persistSelection();
                            if (!ok) return;
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NutritionSummary(),
                              ),
                            );
                          },
                        ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
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
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.daysOptions,
    required this.onNext,
  });

  final List<int> daysOptions;
  final Future<void> Function() onNext;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TargetDaysViewModel>();
    final userInfo = vm.userInfo;
    if (userInfo == null) {
      return const SizedBox.shrink();
    }
    final calculation = vm.calculation;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: ProgressBarWidget(
              progress: 8 / 8,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.howLongToReachGoal,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userInfo.isLosingWeight
                ? AppLocalizations.of(context)!.loseWeightAmount(
                    userInfo.weightDifference.toStringAsFixed(1))
                : AppLocalizations.of(context)!.gainWeightAmount(
                    userInfo.weightDifference.toStringAsFixed(1)),
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
                  DaysSliderCard(
                    selectedDays: vm.selectedDays,
                    onDaysChanged: vm.setSelectedDays,
                  ),
                  const SizedBox(height: 24),
                  _QuickOptions(
                    daysOptions: daysOptions,
                    selectedDays: vm.selectedDays,
                    onTap: vm.setSelectedDays,
                  ),
                  const SizedBox(height: 24),
                  if (calculation != null) ...[
                    NutritionInfoCard(calculation: calculation),
                    const SizedBox(height: 24),
                    if (!calculation.isHealthy)
                      WarningCard(
                        warningMessage: calculation.warningMessage ??
                            AppLocalizations.of(context)!.unhealthyPlanWarning,
                        recommendedDays: vm.recommendedDays ?? 0,
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _BottomButtons(onNext: onNext),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuickOptions extends StatelessWidget {
  const _QuickOptions({
    required this.daysOptions,
    required this.selectedDays,
    required this.onTap,
  });

  final List<int> daysOptions;
  final int selectedDays;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: daysOptions.map((days) {
        final isSelected = selectedDays == days;
        return InkWell(
          onTap: () => onTap(days),
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
              AppLocalizations.of(context)!.daysSuffix(days),
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
}

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({required this.onNext});

  final Future<void> Function() onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
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
              onPressed: () => onNext(),
              child: Text(
                AppLocalizations.of(context)!.next,
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
