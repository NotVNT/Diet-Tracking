import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'diet_reason_screen.dart';

class WeightGoalScreen extends StatefulWidget {
  final List<String> selectedMainGoals;
  const WeightGoalScreen({super.key, required this.selectedMainGoals});

  @override
  State<WeightGoalScreen> createState() => _WeightGoalScreenState();
}

class _WeightGoalScreenState extends State<WeightGoalScreen> {
  Color get _bg => const Color(0xFFF6F3EB);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _muted => const Color(0xFF6B7280);
  Color get _primary => const Color(0xFFFF7A00);

  final Set<int> _selectedIndices = <int>{};

  late final String _title = widget.selectedMainGoals.contains('Giảm cân')
      ? 'Tại sao bạn muốn giảm cân?'
      : 'Tại sao bạn chọn mục tiêu này?';

  final List<_ReasonItem> _reasons = const [
    _ReasonItem(icon: '❤️', title: 'Cải thiện sức khỏe'),
    _ReasonItem(icon: '🌟', title: 'Tăng tự tin'),
    _ReasonItem(icon: '👖', title: 'Mặc vừa quần áo'),
    _ReasonItem(icon: '⚡', title: 'Nhiều năng lượng hơn'),
    _ReasonItem(icon: '📅', title: 'Chuẩn bị cho một sự kiện'),
    _ReasonItem(icon: '🔥', title: 'Giảm mỡ nội tạng'),
    _ReasonItem(icon: '🏃', title: 'Cải thiện thể lực'),
    _ReasonItem(icon: '✍️', title: 'Khác'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildBack(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        // step 1 done (muted), step 2 active
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DietReasonScreen(
                            selectedMainGoals: widget.selectedMainGoals,
                            selectedWeightReasons: const <String>[],
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Bỏ qua',
                      style: GoogleFonts.inter(
                        color: _muted,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _title,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: _reasons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildReasonTile(index),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedIndices.isEmpty
                      ? null
                      : () {
                          final reasons = _selectedIndices
                              .map((i) => _reasons[i].title)
                              .toList(growable: false);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DietReasonScreen(
                                selectedMainGoals: widget.selectedMainGoals,
                                selectedWeightReasons: reasons,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    disabledBackgroundColor: Colors.black.withOpacity(0.1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Tiếp theo',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonTile(int index) {
    final item = _reasons[index];
    final bool selected = _selectedIndices.contains(index);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() {
        if (selected) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: selected ? _primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(item.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _accent,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? _primary : _muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.arrow_back, size: 20),
        ),
      ),
    );
  }
}

class _ReasonItem {
  final String icon;
  final String title;
  const _ReasonItem({required this.icon, required this.title});
}
