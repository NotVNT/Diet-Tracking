import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/custom_button.dart';
import '../../../l10n/app_localizations.dart';
import 'gender_selector.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Color get _bgColor => const Color(0xFFF2C94C); // Vàng ấm theo ảnh
  Color get _textColor => const Color(0xFF2D3A4A); // Xanh đậm cho chữ
  Color get _buttonColor => const Color(0xFF1F2A37); // Nút xanh than đậm

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Cỡ chữ đáp ứng theo chiều rộng màn hình
    final double titleFontSize = (size.width * 0.12).clamp(36.0, 56.0);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)?.tellUsAboutYourself ??
                    'Hãy cho chúng tôi biết về bản thân bạn',
                style: GoogleFonts.inter(
                  fontSize: titleFontSize,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: _textColor,
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)?.weWillCreatePersonalizedPlan ??
                    'Chúng tôi sẽ tạo kế hoạch cá nhân hóa cho '
                        'bạn dựa trên các chi tiết như tuổi và cân nặng'
                        'hiện tại của bạn.',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 1.6,
                  color: _textColor.withValues(alpha: 0.85),
                ),
              ),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/welcome_screen/user_information.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Row(
                children: [
                  // Nút back bo góc vuông tròn như ảnh
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _bgColor,
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
                        child: Icon(Icons.arrow_back, color: _textColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: AppLocalizations.of(context)?.start ?? 'Bắt đầu',
                      backgroundColor: _buttonColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GenderSelector(),
                          ),
                        );
                      },
                      height: 64,
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
