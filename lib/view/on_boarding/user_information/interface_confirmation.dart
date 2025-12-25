import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../identities/register/register_main_screen.dart';
import '../../../database/local_storage_service.dart';
import '../../../database/auth_service.dart';
import '../../../services/onboarding_data_sync_service.dart';
import '../../../features/home_page/presentation/pages/home_page.dart';
import '../../../features/home_page/di/home_di.dart';
import '../../../l10n/app_localizations.dart';

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
  final AuthService _authService = AuthService();
  late final OnboardingDataSyncService _onboardingSyncService =
      OnboardingDataSyncService(
        localStorage: _localStorage,
        authService: _authService,
      );

  static const String _successAssetPath = 'assets/welcome_screen/success.png';

  // UI Colors
  Color get _backgroundColor => const Color(0xFFFDF0D7);
  Color get _accentColor => const Color(0xFF1F2A37);
  Color get _titleColor => const Color(0xFF2D3A4A);

  // UI Text
  String _getHeadlineText(BuildContext context) =>
      AppLocalizations.of(context)?.youCanDoIt ?? 'Bạn sẽ làm được!';

  /// Tạo thông điệp động dựa trên mục tiêu cân nặng
  String _buildMotivationalMessage(BuildContext context) {
    return AppLocalizations.of(context)?.setClearGoalsMessage ??
        'Đặt mục tiêu rõ ràng giúp bạn tiến gần hơn mỗi ngày';
  }

  String _buildPersonalizedLine(BuildContext context) {
    final current = widget.currentWeightKg;
    final goal = widget.goalWeightKg;
    if (current == null || goal == null) return '';

    final diff = (current - goal).abs();
    if (diff == 0) {
      return 'Mục tiêu: duy trì cân nặng hiện tại';
    }

    if (goal < current) {
      return 'Mục tiêu: giảm $diff kg (từng bước một)';
    }
    return 'Mục tiêu: tăng $diff kg (từng bước một)';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMotivationCard(),
                  const SizedBox(height: 20),
                  _buildSuccessIllustration(),
                  const SizedBox(height: 16),
                  _buildMotivationMessages(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionRow(),
    );
  }

  /// Xây dựng card động viên với tiêu đề và thông điệp
  Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _titleColor.withAlpha((255 * 0.06).round()),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _getHeadlineText(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _buildMotivationalMessage(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 17,
              height: 1.65,
              color: _titleColor.withAlpha((255 * 0.85).round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIllustration() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Image.asset(_successAssetPath, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildMotivationMessages() {
    final personalized = _buildPersonalizedLine(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.88).round()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _titleColor.withAlpha((255 * 0.06).round()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn đã sẵn sàng bắt đầu!',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hãy duy trì thói quen nhỏ mỗi ngày — theo dõi bữa ăn và cân nặng để thấy tiến bộ rõ ràng.',
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: _titleColor.withAlpha((255 * 0.88).round()),
            ),
          ),
          if (personalized.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              personalized,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: _accentColor,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Bạn có thể cập nhật mục tiêu bất cứ lúc nào trong hồ sơ.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: _titleColor.withAlpha((255 * 0.75).round()),
            ),
          ),
        ],
      ),
    );
  }

  /// Hàng nút cố định phía dưới: Back + CTA (Đăng ký/Tiếp tục)
  Widget _buildBottomActionRow() {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        boxShadow: const [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          children: [
            _buildBackButton(),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButtons()),
          ],
        ),
      ),
    );
  }

  /// Xây dựng các nút hành động chính
  Widget _buildActionButtons() {
    User? currentUser;
    try {
      currentUser = FirebaseAuth.instance.currentUser;
    } catch (_) {
      currentUser = null;
    }
    final bool isGoogle =
        currentUser?.providerData.any((p) => p.providerId == 'google.com') ==
        true;

    if (isGoogle) {
      return _buildContinueToHomeButton();
    }

    // Chỉ hiển thị nút Đăng ký, không còn chế độ Guest
    return _buildSignupButton();
  }

  /// Xây dựng nút Đăng ký
  Widget _buildSignupButton() {
    return SizedBox(
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
          AppLocalizations.of(context)?.signUpAccount ?? 'Đăng Ký Tài Khoản',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Nút Tiếp tục dành cho trường hợp đăng nhập bằng Google
  Widget _buildContinueToHomeButton() {
    return SizedBox(
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () async {
          // Hiển thị loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );

          try {
            // Lưu thông tin từ localStorage lên Firestore trước khi chuyển trang
            await _onboardingSyncService.syncGuestOnboardingToCurrentUser();

            if (!mounted) return;
            Navigator.of(context).pop(); // Đóng loading dialog

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (_) => HomeDI.getHomeProvider(),
                  child: const HomePage(),
                ),
              ),
              (route) => false,
            );
          } catch (e) {
            if (!mounted) return;
            Navigator.of(context).pop(); // Đóng loading dialog

            // Vẫn chuyển trang ngay cả khi có lỗi
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (_) => HomeDI.getHomeProvider(),
                  child: const HomePage(),
                ),
              ),
              (route) => false,
            );
          }
        },
        child: Text(
          AppLocalizations.of(context)?.continueButton ?? 'Tiếp tục',
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
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: _backgroundColor,
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
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.arrow_back, color: Color(0xFF2D3A4A)),
        ),
      ),
    );
  }
}
