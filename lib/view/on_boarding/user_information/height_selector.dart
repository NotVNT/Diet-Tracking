import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widget/height/height_selector_widget.dart';
import '../../../database/local_storage_service.dart';
import '../../../l10n/app_localizations.dart';
import 'weight_selector.dart';

class HeightSelector extends StatefulWidget {
  final dynamic selectedGender;
  final int? selectedAge;

  const HeightSelector({super.key, this.selectedGender, this.selectedAge});

  @override
  State<HeightSelector> createState() => _HeightSelectorState();
}

class _HeightSelectorState extends State<HeightSelector> {
  Color get _accent => const Color(0xFF1F2A37);
  Color get _title => const Color(0xFF2D3A4A);
  Color get _progress => const Color(0xFFF2C94C);

  double _selectedHeight = 172.0;
  final LocalStorageService _local = LocalStorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background like in the image
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: 0.8, // Further along in the onboarding process
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_progress),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                AppLocalizations.of(context)?.whatIsYourHeight ??
                    'Cân nặng hiện tại của bạn là bao nhiêu?',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _title,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: HeightSelectorWidget(
                  initialHeight: _selectedHeight,
                  onHeightChanged: (height) {
                    setState(() {
                      _selectedHeight = height;
                    });
                  },
                  onUnitChanged: (isCm) {
                    // Unit change handled internally by the widget
                  },
                ),
              ),

              // Navigation buttons
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                          // Save height then go to weight selector
                          await _local.saveGuestData(heightCm: _selectedHeight);
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WeightSelector(),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)?.next ?? 'Next',
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
