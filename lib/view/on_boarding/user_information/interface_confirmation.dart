import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../identities/register/register_main_screen.dart';
import '../../../database/local_storage_service.dart';
import '../../../database/auth_service.dart';
import '../../../features/home_page/presentation/pages/home_page.dart';
import '../../../features/home_page/di/home_di.dart';
import '../../../l10n/app_localizations.dart';

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
  final AuthService _authService = AuthService();

  // UI Colors
  Color get _backgroundColor => const Color(0xFFFDF0D7);
  Color get _accentColor => const Color(0xFF1F2A37);
  Color get _titleColor => const Color(0xFF2D3A4A);

  // UI Text
  String _getHeadlineText(BuildContext context) =>
      AppLocalizations.of(context)?.youCanDoIt ?? 'Bạn sẽ làm được!';

  /// Tạo thông điệp động dựa trên mục tiêu cân nặng
  String _buildMotivationalMessage(BuildContext context) {
    if (widget.currentWeightKg != null && widget.goalWeightKg != null) {
      final weightDifference = (widget.currentWeightKg! - widget.goalWeightKg!)
          .abs();

      if (weightDifference == 0) {
        return AppLocalizations.of(context)?.maintainCurrentWeightIsHealthy ??
            'Duy trì cân nặng hiện tại là một lựa chọn lành mạnh';
      }

      final isWeightLoss = widget.goalWeightKg! < widget.currentWeightKg!;
      return isWeightLoss
          ? '${AppLocalizations.of(context)?.loseWeightGoalPrefix ?? 'Giảm'} $weightDifference kg ${AppLocalizations.of(context)?.loseWeightGoalSuffix ?? 'là mục tiêu thách thức nhưng hoàn toàn khả thi'}'
          : '${AppLocalizations.of(context)?.gainWeightGoalPrefix ?? 'Tăng'} $weightDifference kg ${AppLocalizations.of(context)?.gainWeightGoalSuffix ?? 'sẽ giúp bạn đạt trạng thái cân bằng tốt hơn'}';
    }

    return AppLocalizations.of(context)?.setClearGoalsMessage ??
        'Đặt mục tiêu rõ ràng giúp bạn tiến gần hơn mỗi ngày';
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
  Future<void> _navigateAsGuest(BuildContext context) async {
    await _saveGuestWeightData(context);

    if (!mounted) return;

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

  /// Lưu thông tin cân nặng vào local storage cho guest
  Future<void> _saveGuestWeightData(BuildContext context) async {
    await _localStorage.saveGuestData(
      weightKg: widget.currentWeightKg?.toDouble(),
      goal:
          '${AppLocalizations.of(context)?.goalWeightPrefix ?? 'Cân nặng mục tiêu'}: ${widget.goalWeightKg}kg',
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
            color: const Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _buildMotivationalMessage(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              height: 1.6,
              color: _titleColor.withAlpha((255 * 0.85).round()),
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
            AppLocalizations.of(context)?.userProgressMessage ??
                'người dùng ghi nhận tiến bộ rõ rệt sau 4 tuần theo kế hoạch',
            style: GoogleFonts.inter(
              fontSize: 18,
              height: 1.6,
              color: _titleColor.withAlpha((255 * 0.9).round()),
            ),
          ),
        ),
      ],
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
            side: BorderSide(
              color: _accentColor.withAlpha((255 * 0.2).round()),
              width: 1,
            ),
          ),
        ),
        onPressed: () => _navigateAsGuest(context),
        child: Text(
          AppLocalizations.of(context)?.continueAsGuest ?? 'Tiếp tục với Guest',
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
            await _saveOnboardingDataToFirestore();

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
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
      ),
    );
  }

  /// Lưu thông tin onboarding từ localStorage lên Firestore
  Future<void> _saveOnboardingDataToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final hasData = await _localStorage.hasGuestData();
      if (!hasData) {
        return;
      }

      final data = await _localStorage.readGuestData();

      final Map<String, dynamic> update = {};

      // Tạo BodyInfoModel từ dữ liệu guest
      final bodyInfo = {
        if (data['heightCm'] != null) 'heightCm': data['heightCm'],
        if (data['weightKg'] != null) 'weightKg': data['weightKg'],
        if (data['goalWeightKg'] != null) 'goalWeightKg': data['goalWeightKg'],
        if (data['medicalConditions'] != null)
          'medicalConditions': data['medicalConditions'],
        if (data['allergies'] != null) 'allergies': data['allergies'],
        if (data['activityLevel'] != null)
          'activityLevel': data['activityLevel'],
      };

      if (bodyInfo.isNotEmpty) {
        update['bodyInfo'] = bodyInfo;
      }

      if (data['age'] != null) {
        update['age'] = data['age'];
      }
      if (data['gender'] != null && (data['gender'] as String).isNotEmpty) {
        update['gender'] = data['gender'];
      }
      if (data['goal'] != null && (data['goal'] as String).isNotEmpty) {
        update['goal'] = data['goal'];
      }

      // Thêm targetDays vào dữ liệu cập nhật
      final targetDays = await _localStorage.getData('targetDays') as int?;
      if (targetDays != null) {
        update['targetDays'] = targetDays;
      }

      if (update.isEmpty) {
        return;
      }

      await _authService.updateUserData(user.uid, update);

      // Xóa dữ liệu guest sau khi lưu thành công
      await _localStorage.clearGuestData();
    } catch (e) {
      // Consider logging the error to a service
    }
  }
}
