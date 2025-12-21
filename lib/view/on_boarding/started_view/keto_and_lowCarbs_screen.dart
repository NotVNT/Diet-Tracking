import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../database/auth_service.dart';
import '../../../database/local_storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/progress_bar/started_progress_bar.dart';
import 'diet_reason_screen.dart';

class KetoAndLowCarbsScreen extends StatefulWidget {
  final List<String> selectedMainGoals;
  final List<String> selectedWeightReasons;
  final LocalStorageService? localStorageService;
  final AuthService? authService;

  const KetoAndLowCarbsScreen({
    super.key,
    required this.selectedMainGoals,
    required this.selectedWeightReasons,
    this.localStorageService,
    this.authService,
  });

  @override
  State<KetoAndLowCarbsScreen> createState() => _KetoAndLowCarbsScreenState();
}

class _KetoAndLowCarbsScreenState extends State<KetoAndLowCarbsScreen> {
  Color get _bg => const Color(0xFFF6F3EB);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _muted => const Color(0xFF6B7280);
  Color get _primary => const Color(0xFFFF7A00);

  late final LocalStorageService _local =
      widget.localStorageService ?? LocalStorageService();
  late final AuthService _auth = widget.authService ?? AuthService();

  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            StartedProgressBar(
              currentStep: 3,
              totalSteps: 4,
              activeColor: _primary,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)?.chooseYourDietStyle ??
                      'Bạn muốn theo chế độ nào?',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)?.youCanChangeLater ??
                      'Bạn có thể thay đổi sau trong cài đặt.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.4,
                    color: _muted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
          
                  _buildOptionCard(
                    value: 'keto',
                    icon: '🥑',
                    title: AppLocalizations.of(context)?.keto ?? 'Keto',
                    subtitle:
                        AppLocalizations.of(context)?.ketoDescription ??
                        'Giảm carb mạnh, tăng chất béo.',
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    value: 'lowCarbs',
                    icon: '🥦',
                    title:
                        AppLocalizations.of(context)?.lowCarbs ?? 'Low Carbs',
                    subtitle:
                        AppLocalizations.of(context)?.lowCarbsDescription ??
                        'Giảm carb vừa phải, dễ duy trì.',
                  ),
                  const SizedBox(height: 12),
                          _buildOptionCard(
                    value: 'normal',
                    icon: '🥗',
                    title:
                        AppLocalizations.of(context)?.normalWeightLoss ??
                        'Giảm cân bình thường',
                    subtitle:
                        AppLocalizations.of(
                          context,
                        )?.normalWeightLossDescription ??
                        'Cân bằng carb, đạm, béo. Dễ duy trì lâu dài.',
                  ),
                  
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selected == null ? null : _handleNext,
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

  Widget _buildOptionCard({
    required String value,
    required String icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _selected == value;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() => _selected = value),
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
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.35,
                      color: _muted,
                    ),
                  ),
                ],
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
    final selected = _selected;
    if (selected == null) return;

    await _local.saveGuestData(dietPreference: selected);

    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _auth.updateUserData(uid, {'dietPreference': selected});
      } catch (_) {}
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DietReasonScreen(
          selectedMainGoals: widget.selectedMainGoals,
          selectedWeightReasons: widget.selectedWeightReasons,
        ),
      ),
    );
  }
}
