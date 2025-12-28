import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import '../../../services/language_service.dart';
import 'goal_selection_screen.dart';

class StartScreen extends StatefulWidget {
  final WidgetBuilder? goalSelectionBuilder;
  const StartScreen({super.key, this.goalSelectionBuilder});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  Color get _accent => const Color(0xFF1F2A37); // chữ đậm
  @override
  void initState() {
    super.initState();
    _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    await LanguageService.initialize();
    if (mounted) {
      setState(() {});
    }
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/welcome_screen/Goal.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF63DAB8),
              Color(0xFFA7E4C0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Ngôn ngữ ở góc phải như ảnh

                Text(
                  AppLocalizations.of(context)?.defineYourGoal ??
                      'Xác định mục tiêu của bạn',
                  style: GoogleFonts.inter(
                    fontSize: 56,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: _accent,
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
                  AppLocalizations.of(context)?.weWillBuild ??
                      'Chúng tôi sẽ xây dựng cho bạn một kế hoạch tùy chỉnh nhằm giúp bạn duy trì động lực và đạt được mục tiêu của mình.',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    height: 1.6,
                    color: _accent.withValues(alpha: 0.85),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: RepaintBoundary(
                      child: Image.asset(
                        'assets/welcome_screen/Goal.png',
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    // Nút quay lại
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
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
                            shadowColor: Colors.black.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    widget.goalSelectionBuilder ??
                                    (_) => const GoalSelection(),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)?.getStartedNow ??
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
      ),
    );
  }
}
