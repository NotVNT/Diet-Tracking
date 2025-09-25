import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/weight_selector.dart';
import '../../../database/local_storage_service.dart';

class HeightSelector extends StatefulWidget {
  final dynamic selectedGender;
  const HeightSelector({super.key, this.selectedGender});

  @override
  State<HeightSelector> createState() => _HeightSelectorState();
}

class _HeightSelectorState extends State<HeightSelector> {
  Color get _bg => const Color(0xFFFDF0D7);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _title => const Color(0xFF2D3A4A);
  Color get _progress => const Color(0xFFF2C94C);

  // Chiều cao từ 120cm đến 220cm
  static const int _minHeight = 120;
  static const int _maxHeight = 220;
  static const int _defaultHeight = 170;

  late final FixedExtentScrollController scrollController =
      FixedExtentScrollController(initialItem: _defaultHeight - _minHeight);

  int get currentHeightCm => _minHeight + scrollController.selectedItem;

  final LocalStorageService _local = LocalStorageService();

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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: 0.8,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(_progress),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'CHIỀU CAO',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _title,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn cao bao nhiêu?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 1.6,
                  color: _title.withOpacity(0.8),
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
                          childCount: (_maxHeight - _minHeight) + 1,
                          builder: (context, index) {
                            final height = _minHeight + index;
                            final isCurrent = height == currentHeightCm;
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
                                            color: Colors.black.withOpacity(
                                              0.08,
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
                                      '$height',
                                      style: GoogleFonts.inter(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: _accent,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'cm',
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: _accent.withOpacity(0.9),
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
                            color: _accent.withOpacity(0.9),
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
                          // Lưu tạm chiều cao
                          await _local.saveGuestData(
                            heightCm: currentHeightCm.toDouble(),
                          );
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const WeightSelector(),
                            ),
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
