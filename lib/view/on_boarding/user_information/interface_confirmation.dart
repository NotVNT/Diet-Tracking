import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main_navigation/main_navigation_screen.dart';

class InterfaceConfirmation extends StatelessWidget {
  final int? currentWeightKg;
  final int? goalWeightKg;
  const InterfaceConfirmation({
    super.key,
    this.currentWeightKg,
    this.goalWeightKg,
  });

  Color get _bg => const Color(0xFFFDF0D7);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _title => const Color(0xFF2D3A4A);

  String get _headline => 'Bạn sẽ làm được!';

  String getSubTitle() {
    if (currentWeightKg != null && goalWeightKg != null) {
      final diff = (currentWeightKg! - goalWeightKg!).abs();
      if (diff == 0) {
        return 'Duy trì cân nặng hiện tại là một lựa chọn lành mạnh';
      }
      final trend = goalWeightKg! < currentWeightKg!
          ? 'Giảm $diff kg là mục tiêu thách thức nhưng hoàn toàn khả thi'
          : 'Tăng $diff kg sẽ giúp bạn đạt trạng thái cân bằng tốt hơn';
      return trend;
    }
    return 'Đặt mục tiêu rõ ràng giúp bạn tiến gần hơn mỗi ngày';
  }

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
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _headline,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _title,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      getSubTitle(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        height: 1.6,
                        color: _title.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Center(
                child: Image.asset(
                  'assets/icon/like.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '92%',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: _accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'người dùng ghi nhận tiến bộ rõ rệt sau 4 tuần theo kế hoạch',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        height: 1.6,
                        color: _title.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
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
                          backgroundColor: _accent,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          // Navigate to main screen after completing onboarding
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MainNavigationScreen(),
                            ),
                            (route) => false,
                          );
                        },
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
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
