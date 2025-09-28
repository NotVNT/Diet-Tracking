import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'age_selector.dart';
import '../../../database/local_storage_service.dart';
import '../../../l10n/app_localizations.dart';

class GenderSelector extends StatefulWidget {
  const GenderSelector({super.key});

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

enum Gender { male, female }

class _GenderSelectorState extends State<GenderSelector> {
  Gender? _selected = Gender.male;
  final LocalStorageService _local = LocalStorageService();

  Color get _bg => const Color(0xFFFDF0D7);
  Color get _card => Colors.white;
  Color get _accent => const Color(0xFF1F2A37);
  Color get _highlight => const Color(0xFFF2C94C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -40,
              left: -40,
              child: _softBlob(140, const Color(0xFFFFE4A3).withOpacity(0.5)),
            ),
            Positioned(
              bottom: 120,
              right: -30,
              child: _softBlob(180, const Color(0xFFFFE9C2).withOpacity(0.6)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Thanh tiến trình đơn giản (placeholder)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: 0.4,
                      minHeight: 10,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(_highlight),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)?.gender ?? 'Giới tính',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D3A4A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)?.weWillUseThisInfo ??
                        'Chúng tôi sẽ sử dụng thông tin này để tính toán nhu cầu năng lượng hằng ngày của bạn.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.6,
                      color: const Color(0xFF2D3A4A).withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _GenderOption(
                    title: AppLocalizations.of(context)?.male ?? 'Nam',
                    asset: 'assets/gender/male.png',
                    selected: _selected == Gender.male,
                    onTap: () => setState(() => _selected = Gender.male),
                    cardColor: _card,
                    checkColor: _accent,
                    highlight: _highlight,
                  ),
                  const SizedBox(height: 16),
                  _GenderOption(
                    title: AppLocalizations.of(context)?.female ?? 'Nữ',
                    asset: 'assets/gender/female.png',
                    selected: _selected == Gender.female,
                    onTap: () => setState(() => _selected = Gender.female),
                    cardColor: _card,
                    checkColor: _accent,
                    highlight: _highlight,
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
                              // Lưu tạm giới tính
                              await _local.saveGuestData(
                                gender: _selected == Gender.male
                                    ? 'male'
                                    : 'female',
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AgeSelector(selectedGender: _selected),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)?.continueButton ??
                                  'Tiếp tục',
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
          ],
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String title;
  final String asset;
  final bool selected;
  final VoidCallback onTap;
  final Color cardColor;
  final Color checkColor;
  final Color highlight;

  const _GenderOption({
    required this.title,
    required this.asset,
    required this.selected,
    required this.onTap,
    required this.cardColor,
    required this.checkColor,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: selected ? 1.02 : 1.0,
        child: Container(
          padding: EdgeInsets.all(selected ? 3 : 0),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFFFFF1B5), Color(0xFFF7D27D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(22),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: selected ? highlight.withOpacity(0.55) : cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(selected ? 0.12 : 0.06),
                  blurRadius: selected ? 18 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2D3A4A),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFF4F6F9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        asset,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      right: -4,
                      top: -6,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: selected ? 1.0 : 0.7,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: selected ? 1 : 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: checkColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _softBlob(double size, Color color) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.6),
          blurRadius: 60,
          spreadRadius: 10,
        ),
      ],
    ),
  );
}
