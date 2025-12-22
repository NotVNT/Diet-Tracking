import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/goal_weight_selector.dart';
import '../../../database/local_storage_service.dart';
import '../../../database/auth_service.dart';
import 'package:diet_tracking_project/widget/weight/unit_toggle.dart';
import 'package:diet_tracking_project/widget/weight/weight_display.dart';
import 'package:diet_tracking_project/widget/weight/weight_ruler.dart';
import 'package:diet_tracking_project/widget/weight/bmi_card.dart';
import 'package:diet_tracking_project/widget/weight/weight_responsive_design.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/utils/bmi_calculator.dart';
import 'package:diet_tracking_project/widget/progress_bar/user_progress_bar.dart';

class WeightSelector extends StatefulWidget {
  final AuthService? authService;
  const WeightSelector({super.key, this.authService});

  @override
  State<WeightSelector> createState() => _WeightSelectorState();
}

class _WeightSelectorState extends State<WeightSelector> {
  // Colors tuned to match the reference screenshot
  Color get _pageBg => const Color(0xFFF8F7FF);
  Color get _titleColor => const Color(0xFF111827);
  Color get _subtitleColor => const Color(0xFF6B7280);
  Color get _accent => const Color(0xFF1F2A37); // dark navy like screenshot

  static const double _minWeightKg = 20.0;
  static const double _maxWeightKg = 240.0;

  final LocalStorageService _local = LocalStorageService();
  AuthService? _auth;

  // State
  bool _isKg = true;
  double _weightKg = 70.0; // store canonical value in kg
  double? _heightCm; // loaded from local storage for BMI
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _loadHeightForBmi();
    _controller = TextEditingController(text: _weightKg.toStringAsFixed(1));
    _auth = widget.authService; // dùng injected để tránh Firebase trong test
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
    final displayedValue = _isKg
        ? _weightKg
        : _weightKg * 2.2046226218; // kg -> lb
    final valueText = displayedValue.toStringAsFixed(1);
    final bmi = BmiCalculator.computeBmi(_weightKg, _heightCm);
    final bmiText = BmiCalculator.bmiDescription(context, bmi);

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.space(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.space(12)),
              // Progress bar
              const ProgressBarWidget(
                progress: 5 / 8, // Bước 5/8
              ),
              SizedBox(height: r.space(18)),
              // Titles
              Text(
                AppLocalizations.of(context)?.weight ?? 'Weight',
                style: GoogleFonts.inter(
                  fontSize: r.font(24),
                  fontWeight: FontWeight.w800,
                  color: _titleColor,
                ),
              ),
              SizedBox(height: r.space(6)),
              Text(
                AppLocalizations.of(context)?.whatIsYourWeight ??
                    'What is your weight?',
                style: GoogleFonts.inter(
                  fontSize: r.font(16),
                  height: 1.5,
                  color: _subtitleColor,
                ),
              ),
              SizedBox(height: r.space(16)),
              // Unit toggle centered
              Center(
                child: UnitToggle(
                  isKg: _isKg,
                  onChanged: (v) {
                    setState(() {
                      _isKg = v;
                      final displayed = _isKg
                          ? _weightKg
                          : _weightKg * 2.2046226218;
                      _controller.text = displayed.toStringAsFixed(1);
                    });
                  },
                ),
              ),
              SizedBox(height: r.space(14)),
              // Big number
              Center(
                child: WeightDisplay(
                  valueText: valueText,
                  unit: _isKg ? 'kg' : 'lb',
                ),
              ),
              SizedBox(height: r.space(8)),
              // Manual input textbox
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
                        final newKg = _isKg
                            ? parsed
                            : parsed / 2.2046226218; // lb -> kg
                        _weightKg = newKg.clamp(_minWeightKg, _maxWeightKg);
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: r.space(8)),
              // Ruler slider
              WeightRuler(
                min: _minWeightKg,
                max: _maxWeightKg,
                value: _weightKg,
                isKg: _isKg,
                accent: _accent,
                onChanged: (v) => setState(() {
                  _weightKg = v;
                  final displayed = _isKg
                      ? _weightKg
                      : _weightKg * 2.2046226218;
                  _controller.text = displayed.toStringAsFixed(1);
                }),
              ),
              SizedBox(height: r.space(10)),
              // BMI card
              BmiCard(bmi: bmi, description: bmiText),
              const Spacer(),
              // Bottom navigation buttons styled like height selector
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
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.08),
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
                        onPressed: () async {
                          final uid = _auth?.currentUser?.uid;
                          if (uid != null) {
                            await _auth!.updateUserData(uid, {
                              'bodyInfo.weightKg': _weightKg,
                            });
                          } else {
                            await _local.saveGuestData(weightKg: _weightKg);
                          }
                          if (mounted && context.mounted) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GoalWeightSelector(
                                  currentWeightKg: _weightKg.round(),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)?.next ?? 'Next',
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
