import 'package:flutter/material.dart';
import '../utils/bottom_sheet_utils.dart';
import 'package:google_fonts/google_fonts.dart';

/// Supported units
enum UnitSystem { metric, imperial }

/// Unit information
class _UnitInfo {
  final String name;
  final String description;
  final String displayName;
  
  const _UnitInfo({
    required this.name,
    required this.description,
    required this.displayName,
  });
}

_UnitInfo _unitInfo(UnitSystem unit) {
  switch (unit) {
    case UnitSystem.metric:
      return const _UnitInfo(
        name: 'Hệ mét',
        description: 'gam, kg, ml, lít',
        displayName: 'Metric (kg, cm)',
      );
    case UnitSystem.imperial:
      return const _UnitInfo(
        name: 'Mỹ',
        description: 'pao, ounce, cốc',
        displayName: 'Imperial (lb, in)',
      );
  }
}

/// Unit selector widget with modal bottom sheet
class UnitSelector extends StatelessWidget {
  final UnitSystem selected;
  final ValueChanged<UnitSystem> onChanged;
  final EdgeInsetsGeometry padding;
  final List<UnitSystem> availableUnits;

  const UnitSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.padding = const EdgeInsets.all(0),
    this.availableUnits = const [UnitSystem.metric, UnitSystem.imperial],
  });

  @override
  Widget build(BuildContext context) {
    final info = _unitInfo(selected);
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: () => _openUnitSheet(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              info.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _openUnitSheet(BuildContext context) {
    UnitSystem tempSelection = selected;
    showCustomBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1F2937)
                    : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25), // 0.1 * 255
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(77), // 0.3 * 255
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bạn muốn sử dụng đơn vị nào?',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Unit options
                  ...availableUnits.map((unit) {
                    final info = _unitInfo(unit);
                    final isSelected = tempSelection == unit;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              tempSelection = unit;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF374151)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(128), // 0.5 * 255
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        info.name,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        info.description,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (tempSelection != selected) {
                          onChanged(tempSelection);
                          _showUnitChangeSuccess(context, tempSelection);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Áp dụng',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUnitChangeSuccess(BuildContext context, UnitSystem newUnit) {
    final info = _unitInfo(newUnit);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đã chuyển sang ${info.name}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
