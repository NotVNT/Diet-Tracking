import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../login/signup_screen.dart';
import '../../../database/local_storage_service.dart';
import '../../home/home_view.dart';

/// Màn hình xác nhận hoàn thành onboarding
/// Cho phép người dùng chọn tiếp tục với Guest hoặc đăng ký tài khoản
class InterfaceConfirmation extends StatefulWidget {
  final int? currentWeightKg;
  final int? goalWeightKg;

  const InterfaceConfirmation({
    super.key,
    this.currentWeightKg,
    this.goalWeightKg,
  });

  @override
  State<InterfaceConfirmation> createState() => _InterfaceConfirmationState();
}

class _InterfaceConfirmationState extends State<InterfaceConfirmation> {
  // Dependencies
  final LocalStorageService _localStorage = LocalStorageService();

  // UI Colors
  Color get _backgroundColor => const Color(0xFFFDF0D7);
  Color get _accentColor => const Color(0xFF1F2A37);
  Color get _titleColor => const Color(0xFF2D3A4A);

  // UI Text
  String get _headlineText => 'Bạn sẽ làm được!';

  /// Tạo thông điệp động dựa trên mục tiêu cân nặng
  String _buildMotivationalMessage() {
    if (widget.currentWeightKg != null && widget.goalWeightKg != null) {
      final weightDifference = (widget.currentWeightKg! - widget.goalWeightKg!)
          .abs();

      if (weightDifference == 0) {
        return 'Duy trì cân nặng hiện tại là một lựa chọn lành mạnh';
      }

      final isWeightLoss = widget.goalWeightKg! < widget.currentWeightKg!;
      return isWeightLoss
          ? 'Giảm $weightDifference kg là mục tiêu thách thức nhưng hoàn toàn khả thi'
          : 'Tăng $weightDifference kg sẽ giúp bạn đạt trạng thái cân bằng tốt hơn';
    }

    return 'Đặt mục tiêu rõ ràng giúp bạn tiến gần hơn mỗi ngày';
  }

  /// Chuyển đến màn hình đăng ký với dữ liệu onboarding đã có
  Future<void> _navigateToSignup() async {
    final guestData = await _localStorage.readGuestData();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupScreen(preSelectedData: guestData),
      ),
    );
  }

  /// Chuyển đến trang chủ với tư cách guest user
  /// Lưu thông tin cân nặng vào local storage trước khi chuyển
  Future<void> _navigateAsGuest() async {
    await _saveGuestWeightData();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeView()),
      (route) => false,
    );
  }

  /// Lưu thông tin cân nặng vào local storage cho guest
  Future<void> _saveGuestWeightData() async {
    await _localStorage.saveGuestData(
      weightKg: widget.currentWeightKg?.toDouble(),
      goal: 'Cân nặng mục tiêu: ${widget.goalWeightKg}kg',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _buildMotivationCard(),
                const SizedBox(height: 36),
                _buildSuccessIcon(),
                const SizedBox(height: 28),
                _buildProgressStats(),
                const SizedBox(height: 40),
                _buildActionButtons(),
                const SizedBox(height: 24),
                _buildBackButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng card động viên với tiêu đề và thông điệp
  Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
            _headlineText,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _buildMotivationalMessage(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              height: 1.6,
              color: _titleColor.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng icon thành công
  Widget _buildSuccessIcon() {
    return Center(
      child: Image.asset(
        'assets/icon/like.png',
        width: 96,
        height: 96,
        fit: BoxFit.contain,
      ),
    );
  }

  /// Xây dựng thống kê tiến bộ
  Widget _buildProgressStats() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '92%',
          style: GoogleFonts.inter(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: _accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'người dùng ghi nhận tiến bộ rõ rệt sau 4 tuần theo kế hoạch',
            style: GoogleFonts.inter(
              fontSize: 18,
              height: 1.6,
              color: _titleColor.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }

  /// Xây dựng các nút hành động chính
  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildGuestButton(),
        const SizedBox(height: 16),
        _buildSignupButton(),
      ],
    );
  }

  /// Xây dựng nút Guest
  Widget _buildGuestButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: _accentColor.withOpacity(0.2), width: 1),
          ),
        ),
        onPressed: _navigateAsGuest,
        child: Text(
          'Tiếp tục với Guest',
          style: GoogleFonts.inter(
            color: _accentColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Xây dựng nút Đăng ký
  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: _navigateToSignup,
        child: Text(
          'Đăng Ký Tài Khoản',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Xây dựng nút Back
  Widget _buildBackButton() {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.08), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(Icons.arrow_back, color: Color(0xFF2D3A4A)),
          ),
        ),
      ),
    );
  }
}
