import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../login/holding_screen.dart';
import '../../../services/firestore_service.dart';
import '../../../services/authentication_service.dart';

class MedicalAllergyScreen extends StatefulWidget {
  final int age;
  final int heightCm;
  final double weightKg;
  const MedicalAllergyScreen({
    super.key,
    required this.age,
    required this.heightCm,
    required this.weightKg,
  });

  @override
  State<MedicalAllergyScreen> createState() => _MedicalAllergyScreenState();
}

class _MedicalAllergyScreenState extends State<MedicalAllergyScreen> {
  Color get _bg => const Color(0xFFFDF0D7);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _title => const Color(0xFF2D3A4A);
  Color get _progress => const Color(0xFFF2C94C);

  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _medicalController = TextEditingController();

  bool _hasAllergy = false;
  bool _hasMedical = false;

  @override
  void dispose() {
    _allergyController.dispose();
    _medicalController.dispose();
    super.dispose();
  }

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
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: 0.9,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(_progress),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Dị ứng & Bệnh lý',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _title,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn có dị ứng hoặc bệnh lý nào cần lưu ý không?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 1.6,
                  color: _title.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Dị ứng',
                value: _hasAllergy,
                onChanged: (v) => setState(() => _hasAllergy = v),
                controller: _allergyController,
                hint: 'Ví dụ: đậu phộng, hải sản...',
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Bệnh lý',
                value: _hasMedical,
                onChanged: (v) => setState(() => _hasMedical = v),
                controller: _medicalController,
                hint: 'Ví dụ: tiểu đường, gout...',
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
                        onPressed: () async {
                          final allergies = _hasAllergy
                              ? _allergyController.text.trim()
                              : '';
                          final medicals = _hasMedical
                              ? _medicalController.text.trim()
                              : '';

                          // Lưu dữ liệu onboarding vào Firestore
                          final currentUser =
                              AuthenticationService().currentUser;
                          if (currentUser != null) {
                            try {
                              await FirestoreService()
                                  .updateUser(currentUser.uid, {
                                    'age': widget.age,
                                    'heightCm': widget.heightCm,
                                    'weightKg': widget.weightKg,
                                    'allergies': allergies,
                                    'medicalConditions': medicals,
                                    'isOnboardingCompleted': true,
                                  });
                            } catch (e) {
                              print('Lỗi lưu dữ liệu onboarding: $e');
                            }
                          }

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HoldingScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Hoàn tất',
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

  Widget _buildSection({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(value: value, activeColor: _accent, onChanged: onChanged),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _title,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (value)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ),
      ],
    );
  }
}
