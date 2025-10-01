import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/widget/weight/unit_toggle.dart';
import 'package:diet_tracking_project/widget/weight/weight_display.dart';
import 'package:diet_tracking_project/widget/weight/weight_ruler.dart';
import 'package:diet_tracking_project/widget/weight/weight_responsive_design.dart';
import 'package:diet_tracking_project/widget/weight/bmi_card.dart';
import '../../../database/local_storage_service.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'interface_confirmation.dart';

class GoalWeightSelector extends StatefulWidget {
  final int currentWeightKg;
  const GoalWeightSelector({super.key, required this.currentWeightKg});

  @override
  State<GoalWeightSelector> createState() => _GoalWeightSelectorState();
}

class _GoalWeightSelectorState extends State<GoalWeightSelector> {
  Color get _pageBg =>
      const Color(0xFFF8F7FF); // match weight screen background
  Color get _titleColor => const Color(0xFF111827);
  Color get _subtitleColor => const Color(0xFF6B7280);
  Color get _accent => const Color(0xFF1F2A37); // dark navy like weight screen

  static const double _minWeightKg = 20.0;
  static const double _maxWeightKg = 240.0;

  bool _isKg = true;
  late double _goalWeightKg;
  late final TextEditingController _controller;
  final LocalStorageService _local = LocalStorageService();
  double? _heightCm;

  @override
  void initState() {
    super.initState();
    _goalWeightKg = widget.currentWeightKg.toDouble();
    _controller = TextEditingController(text: _goalWeightKg.toStringAsFixed(1));
    _loadHeightForBmi();
  }

  Future<void> _loadHeightForBmi() async {
    final data = await _local.readGuestData();
    setState(() {
      _heightCm = (data['heightCm'] as double?);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = WeightResponsive.of(context);
    final displayedValue = _isKg ? _goalWeightKg : _goalWeightKg * 2.2046226218;
    final valueText = displayedValue.toStringAsFixed(1);
    final bmi = _computeBmi(_goalWeightKg, _heightCm);
    final bmiText = _bmiDescription(context, bmi);

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.space(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.space(12)),
              // Titles (keep static text as requested)
              Text(
                AppLocalizations.of(context)?.goalWeight ?? 'Goal Weight',
                style: GoogleFonts.inter(
                  fontSize: r.font(24),
                  fontWeight: FontWeight.w800,
                  color: _titleColor,
                ),
              ),
              SizedBox(height: r.space(6)),
              Text(
                AppLocalizations.of(context)?.whatIsYourGoalWeight ??
                    'What weight do you want to achieve?',
                style: GoogleFonts.inter(
                  fontSize: r.font(16),
                  height: 1.5,
                  color: _subtitleColor,
                ),
              ),
              SizedBox(height: r.space(16)),
              Center(
                child: UnitToggle(
                  isKg: _isKg,
                  onChanged: (v) {
                    setState(() {
                      _isKg = v;
                      final displayed = _isKg
                          ? _goalWeightKg
                          : _goalWeightKg * 2.2046226218;
                      _controller.text = displayed.toStringAsFixed(1);
                    });
                  },
                ),
              ),
              SizedBox(height: r.space(14)),
              Center(
                child: WeightDisplay(
                  valueText: valueText,
                  unit: _isKg ? 'kg' : 'lb',
                ),
              ),
              SizedBox(height: r.space(8)),
              Center(
                child: SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: r.font(16),
                      fontWeight: FontWeight.w600,
                      color: _titleColor,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: r.space(8),
                        horizontal: r.space(10),
                      ),
                      suffixText: _isKg ? 'kg' : 'lb',
                      suffixStyle: GoogleFonts.inter(
                        fontSize: r.font(14),
                        color: _subtitleColor,
                        fontWeight: FontWeight.w700,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(r.radius(10)),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(r.radius(10)),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(r.radius(10)),
                        borderSide: BorderSide(color: _accent),
                      ),
                    ),
                    onChanged: (txt) {
                      final parsed = double.tryParse(txt.replaceAll(',', '.'));
                      if (parsed == null) return;
                      setState(() {
                        final newKg = _isKg ? parsed : parsed / 2.2046226218;
                        _goalWeightKg = newKg.clamp(_minWeightKg, _maxWeightKg);
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: r.space(8)),
              WeightRuler(
                min: _minWeightKg,
                max: _maxWeightKg,
                value: _goalWeightKg,
                isKg: _isKg,
                accent: _accent,
                onChanged: (v) => setState(() {
                  _goalWeightKg = v;
                  final displayed = _isKg
                      ? _goalWeightKg
                      : _goalWeightKg * 2.2046226218;
                  _controller.text = displayed.toStringAsFixed(1);
                }),
              ),
              SizedBox(height: r.space(10)),
              BmiCard(bmi: bmi, description: bmiText),
              const Spacer(),
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
                        onTap: () => Navigator.of(context).maybePop(),
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
                          backgroundColor: _accent,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InterfaceConfirmation(
                                currentWeightKg: widget.currentWeightKg,
                                goalWeightKg: _goalWeightKg.round(),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)?.done ?? 'Xong',
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
              SizedBox(height: r.space(16)),
            ],
          ),
        ),
      ),
    );
  }
}

double _computeBmi(double weightKg, double? heightCm) {
  if (heightCm == null || heightCm <= 0) return 0;
  final h = heightCm / 100.0;
  return weightKg / (h * h);
}

String _bmiDescription(BuildContext context, double bmi) {
  final l10n = AppLocalizations.of(context);
  if (bmi == 0) {
    return l10n?.bmiEnterHeightToCalculate ?? 'Hãy nhập chiều cao để tính BMI.';
  }
  if (bmi < 18.5) {
    return l10n?.bmiUnderweight ?? 'Bạn đang thiếu cân.';
  }
  if (bmi < 25) {
    return l10n?.bmiNormal ?? 'Bạn có cân nặng bình thường.';
  }
  if (bmi < 30) {
    return l10n?.bmiOverweight ?? 'Bạn đang thừa cân.';
  }
  return l10n?.bmiObese ?? 'Bạn cần giảm cân nghiêm túc để bảo vệ sức khỏe';
}
