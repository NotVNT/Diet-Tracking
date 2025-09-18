import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/language_selector.dart';
import 'goal_selection.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Color get _bg => const Color(0xFFA7E4C0); // xanh nhạt giống ảnh
  Color get _accent => const Color(0xFF1F2A37); // chữ đậm

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Ngôn ngữ ở góc phải như ảnh
              Row(
                children: [
                  const Spacer(),
                  LanguageSelector(selected: Language.vi, onChanged: (lang) {}),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Xác định mục tiêu của bạn',
                style: GoogleFonts.inter(
                  fontSize: 56,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chúng tôi sẽ xây dựng cho bạn một kế hoạch tùy chỉnh nhằm giúp bạn duy trì động lực và đạt được mục tiêu của mình.',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 1.6,
                  color: _accent.withOpacity(0.85),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  // Nút quay lại
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _bg,
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
                          backgroundColor: const Color(0xFF1F2A37),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GoalSelection(),
                            ),
                          );
                        },
                        child: Text(
                          'Bắt đầu ngay!',
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
