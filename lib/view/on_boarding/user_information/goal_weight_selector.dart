import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/interface_confirmation.dart';

class GoalWeightSelector extends StatefulWidget {
  final int? currentWeightKg;
  const GoalWeightSelector({super.key, this.currentWeightKg});

  @override
  State<GoalWeightSelector> createState() => _GoalWeightSelectorState();
}

class _GoalWeightSelectorState extends State<GoalWeightSelector> {
  Color get _bg => const Color(0xFFFDF0D7);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _title => const Color(0xFF2D3A4A);
  Color get _progress => const Color(0xFFF2C94C);

  static const int _minWeight = 30;
  static const int _maxWeight = 200;

  late final int _defaultWeight = widget.currentWeightKg != null
      ? widget.currentWeightKg!.clamp(_minWeight, _maxWeight)
      : 65;

  late final FixedExtentScrollController scrollController =
      FixedExtentScrollController(initialItem: _defaultWeight - _minWeight);

  int get currentGoalWeightKg => _minWeight + scrollController.selectedItem;

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
                  value: 1.0,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(_progress),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Cân nặng mục tiêu',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _title,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn muốn đạt cân nặng bao nhiêu?',
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
                          childCount: (_maxWeight - _minWeight) + 1,
                          builder: (context, index) {
                            final weight = _minWeight + index;
                            final isCurrent = weight == currentGoalWeightKg;
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
                                      '$weight',
                                      style: GoogleFonts.inter(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: _accent,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'kg',
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
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InterfaceConfirmation(
                                currentWeightKg: widget.currentWeightKg,
                                goalWeightKg: currentGoalWeightKg,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Xong',
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
