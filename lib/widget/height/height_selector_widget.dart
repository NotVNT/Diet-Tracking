import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'height_scale_painter.dart';
import '../../utils/height_utils.dart';
import 'height_responsive_devices.dart';

class HeightSelectorWidget extends StatefulWidget {
  final double initialHeight;
  final Function(double) onHeightChanged;
  final Function(bool) onUnitChanged;

  const HeightSelectorWidget({
    super.key,
    this.initialHeight = 172.0,
    required this.onHeightChanged,
    required this.onUnitChanged,
  });

  @override
  State<HeightSelectorWidget> createState() => _HeightSelectorWidgetState();
}

class _HeightSelectorWidgetState extends State<HeightSelectorWidget> {
  double _selectedHeight = 172.0;
  bool _isCm = true;
  late FixedExtentScrollController _scrollController;
  final TextEditingController _cmController = TextEditingController();
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedHeight = widget.initialHeight;
    _scrollController = FixedExtentScrollController(
      initialItem: (_selectedHeight - 120).round(),
    );
    _cmController.text = _selectedHeight.toStringAsFixed(1);
    final fi = cmToFeetInches(_selectedHeight);
    _feetController.text = fi['feet'].toString();
    _inchController.text = fi['inches'].toString();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cmController.dispose();
    _feetController.dispose();
    _inchController.dispose();
    super.dispose();
  }

  void _onHeightChanged(int index) {
    setState(() {
      _selectedHeight = 120.0 + index;
      widget.onHeightChanged(_selectedHeight);
      // sync text fields
      _cmController.text = _selectedHeight.toStringAsFixed(1);
      final fi = cmToFeetInches(_selectedHeight);
      _feetController.text = fi['feet'].toString();
      _inchController.text = fi['inches'].toString();
    });
  }

  void _toggleUnit() {
    setState(() {
      _isCm = !_isCm;
      widget.onUnitChanged(_isCm);
      // update controllers when switching units
      _cmController.text = _selectedHeight.toStringAsFixed(1);
      final fi = cmToFeetInches(_selectedHeight);
      _feetController.text = fi['feet'].toString();
      _inchController.text = fi['inches'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizes based on device
    final bigFont = HeightResponsiveDevices.font(context, 48, min: 34, max: 64);
    final toggleWidth = HeightResponsiveDevices.dim(
      context,
      120,
      min: 96,
      max: 168,
    );
    final toggleHeight = HeightResponsiveDevices.dim(
      context,
      40,
      min: 34,
      max: 52,
    );
    final inputWidth = HeightResponsiveDevices.dim(
      context,
      160,
      min: 130,
      max: 220,
    );
    final inputTFWidth = HeightResponsiveDevices.dim(
      context,
      72,
      min: 58,
      max: 92,
    );
    final wheelHeight = HeightResponsiveDevices.wheelHeight(
      context,
      base: 400,
      min: 260,
      max: 560,
    );
    final indicatorLen = HeightResponsiveDevices.dim(
      context,
      64,
      min: 48,
      max: 96,
    );

    return Column(
      children: [
        // Main content area
        Expanded(
          child: Row(
            children: [
              // Left side - Height ruler
              Expanded(
                flex: 2,
                child: Container(
                  height: wheelHeight,
                  child: CustomPaint(
                    painter: HeightScalePainter(
                      selectedHeight: _selectedHeight,
                      isCm: _isCm,
                      indicatorLength: indicatorLen,
                    ),
                    child: ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      physics: const FixedExtentScrollPhysics(),
                      itemExtent: 2.0, // Fine-grained scrolling
                      onSelectedItemChanged: _onHeightChanged,
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 101, // 120-220 cm range
                        builder: (context, index) {
                          return Container(); // Empty container for smooth scrolling
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Right side - Height display and unit toggle
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Input fields above the big value
                    if (_isCm)
                      SizedBox(
                        width: inputWidth,
                        child: TextField(
                          controller: _cmController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            suffixText: 'cm',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (parsed == null) return;
                            final clamped = parsed.clamp(120.0, 220.0);
                            setState(() {
                              _selectedHeight = clamped;
                              widget.onHeightChanged(_selectedHeight);
                              final index = (_selectedHeight - 120)
                                  .round()
                                  .clamp(0, 100);
                              _scrollController.jumpToItem(index);
                            });
                          },
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: inputTFWidth,
                            child: TextField(
                              controller: _feetController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                suffixText: "'",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (_) {
                                final feet =
                                    int.tryParse(_feetController.text) ?? 0;
                                final inches =
                                    int.tryParse(_inchController.text) ?? 0;
                                final cm = feetInchesToCm(
                                  feet,
                                  inches.toDouble(),
                                );
                                final clamped = cm.clamp(120.0, 220.0);
                                setState(() {
                                  _selectedHeight = clamped;
                                  widget.onHeightChanged(_selectedHeight);
                                  final index = (_selectedHeight - 120)
                                      .round()
                                      .clamp(0, 100);
                                  _scrollController.jumpToItem(index);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: inputTFWidth,
                            child: TextField(
                              controller: _inchController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                suffixText: '"',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (_) {
                                final feet =
                                    int.tryParse(_feetController.text) ?? 0;
                                final inches =
                                    int.tryParse(_inchController.text) ?? 0;
                                final cm = feetInchesToCm(
                                  feet,
                                  inches.toDouble(),
                                );
                                final clamped = cm.clamp(120.0, 220.0);
                                setState(() {
                                  _selectedHeight = clamped;
                                  widget.onHeightChanged(_selectedHeight);
                                  final index = (_selectedHeight - 120)
                                      .round()
                                      .clamp(0, 100);
                                  _scrollController.jumpToItem(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    // Height display (prevent unit wrapping)
                    _isCm
                        ? Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: _selectedHeight.toStringAsFixed(1),
                                  style: GoogleFonts.inter(
                                    fontSize: bigFont,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF8B5CF6),
                                  ),
                                ),
                                TextSpan(
                                  text: ' cm',
                                  style: GoogleFonts.inter(
                                    fontSize: (bigFont * 0.48)
                                        .clamp(12, 28)
                                        .toDouble(),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF8B5CF6),
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          )
                        : Text(
                            formatHeight(_selectedHeight, _isCm),
                            style: GoogleFonts.inter(
                              fontSize: bigFont,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8B5CF6),
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                    const SizedBox(height: 8),
                    Text(
                      getFormattedDate(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Unit toggle
                    Container(
                      width: toggleWidth,
                      height: toggleHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isCm ? null : _toggleUnit,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isCm
                                      ? Colors.black
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'CM',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _isCm
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isCm ? _toggleUnit : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_isCm
                                      ? Colors.black
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'FT',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: !_isCm
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
