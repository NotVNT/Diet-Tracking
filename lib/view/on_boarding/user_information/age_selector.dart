import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/health_info_screen.dart';
import '../../../database/local_storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/progress_bar/user_progress_bar.dart';

class AgeSelector extends StatefulWidget {
  final dynamic selectedGender;
  const AgeSelector({super.key, this.selectedGender});

  @override
  State<AgeSelector> createState() => _AgeSelectorState();
}

class _AgeSelectorState extends State<AgeSelector> {
  Color get _bg => const Color(0xFFFDF0D7);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _title => const Color(0xFF2D3A4A);

  FixedExtentScrollController scrollController = FixedExtentScrollController(
    initialItem: 18, // mặc định 30 tuổi khi base = 12
  );
  final LocalStorageService _local = LocalStorageService();

  int get currentAge => 12 + scrollController.selectedItem;

  @override
  void dispose() {
    scrollController.dispose();
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
              const ProgressBarWidget(
                progress: 2 / 8, // Bước 2/8
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)?.age ?? 'Tuổi',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _title,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)?.howOldAreYou ??
                    'Bạn bao nhiêu tuổi?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 1.6,
                  color: _title.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ListWheelScrollView.useDelegate(
                        controller: scrollController,
                        physics: const FixedExtentScrollPhysics(),
                        itemExtent: 64,
                        perspective: 0.002,
                        onSelectedItemChanged: (_) => setState(() {}),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 69, // 12..80
                          builder: (context, index) {
                            final age = 12 + index;
                            final isCurrent = age == currentAge;
                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              opacity: isCurrent ? 1 : 0.35,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: isCurrent
                                    ? BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                            blurRadius: 18,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      )
                                    : null,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$age',
                                      style: GoogleFonts.inter(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: _accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 28,
                        child: Transform.rotate(
                          angle: 3.14159,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 44,
                            color: _accent.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                          // Lưu tạm tuổi
                          await _local.saveGuestData(age: currentAge);
                          if (mounted) {
                            await Navigator.of(this.context).push(
                              MaterialPageRoute(
                                builder: (_) => const HealthInfoScreen(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)?.next ?? 'Tiếp theo',
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
