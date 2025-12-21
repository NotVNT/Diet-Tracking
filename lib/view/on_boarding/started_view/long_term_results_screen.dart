import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user_information/user_start_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/progress_bar/started_progress_bar.dart';

class LongTermResultsScreen extends StatelessWidget {
  final List<String> selectedMainGoals;
  final List<String> selectedWeightReasons;
  final List<String> selectedDietReasons;

  const LongTermResultsScreen({
    super.key,
    required this.selectedMainGoals,
    required this.selectedWeightReasons,
    required this.selectedDietReasons,
  });

  Color get _bg => const Color(0xFFF6F3EB);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _muted => const Color(0xFF6B7280);
  Color get _primary => const Color(0xFFFF7A00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              StartedProgressBar(
                currentStep: 1,
                totalSteps: 1,
                activeColor: _primary,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 28),
              Text(
                AppLocalizations.of(context)?.weBringYouBestResults ??
                    'Chúng tôi mang đến cho bạn hiệu quả tốt nhất',
                textAlign: TextAlign.left,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppLocalizations.of(context)?.personalizedPathwayBasedOnGoals ??
                    'Lộ trình cá nhân hóa dựa trên mục tiêu và thói quen của bạn. Bắt đầu ngay để thấy sự thay đổi bền vững.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.6,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Image.asset(
                  'assets/icon/like.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StartScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
