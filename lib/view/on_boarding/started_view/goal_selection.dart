import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'goal_reason_screen.dart';
import '../../../database/local_storage_service.dart';
import '../../../database/auth_service.dart';
import '../../../l10n/app_localizations.dart';

class GoalSelection extends StatefulWidget {
  final LocalStorageService? localStorageService;
  final AuthService? authService;
  const GoalSelection({super.key, this.localStorageService, this.authService});

  @override
  State<GoalSelection> createState() => _GoalSelectionState();
}

class _GoalSelectionState extends State<GoalSelection> {
  Color get _bg => const Color(0xFFF6F3EB);
  Color get _accent => const Color(0xFF1F2A37);
  Color get _muted => const Color(0xFF6B7280);
  Color get _primary => const Color(0xFFFF7A00);

  int? _selectedIndex;
  late LocalStorageService _local;
  late AuthService _auth;

  final List<_GoalItem> _goals = const [
    _GoalItem(icon: '🔥', title: 'loseWeight'),
    _GoalItem(icon: '🍽️', title: 'gainWeight'),
    _GoalItem(icon: '⚖️', title: 'maintainWeight'),
    _GoalItem(icon: '💪', title: 'buildMuscle'),
  ];

  @override
  Widget build(BuildContext context) {
    _local = widget.localStorageService ?? LocalStorageService();
    _auth = widget.authService ?? AuthService();
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
                  // progress line like screenshot (step 1/4)
                  Expanded(
                    child: Row(
                      children: [
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
                              color: Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
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
                  AppLocalizations.of(context)?.whatIsYourMainGoal ??
                      'Mục tiêu chính của bạn là gì?',
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
                itemBuilder: (context, index) => _buildGoalTile(index),
                separatorBuilder: (_,_) => const SizedBox(height: 12),
                itemCount: _goals.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedIndex == null
                      ? null
                      : () async {
                          final selectedTitle = _getLocalizedTitle(
                            context,
                            _goals[_selectedIndex!].title,
                          );

                          // Lưu goal vào localStorage (luôn lưu để có sẵn cho signup flow)
                          debugPrint('🔍 Saving goal to localStorage: $selectedTitle');
                          await _local.saveGuestData(goal: selectedTitle);

                          // Nếu đã đăng nhập: cũng lưu trực tiếp vào Firestore
                          final uid = _auth.currentUser?.uid;
                          if (uid != null) {
                            try {
                              await _auth.updateUserData(uid, {
                                'goal': [selectedTitle],
                              });
                            } catch (_) {}
                          }

                          if (mounted && context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GoalReasonScreen(
                                  selectedMainGoals: [selectedTitle],
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    disabledBackgroundColor: Colors.black.withValues(alpha: 0.1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.next ?? 'Tiếp theo',
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

  Widget _buildGoalTile(int index) {
    final item = _goals[index];
    final bool selected = _selectedIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() {
        _selectedIndex = selected ? null : index;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
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
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(item.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _getLocalizedTitle(context, item.title),
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
        color: Colors.black.withValues(alpha: 0.05),
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

  String _getLocalizedTitle(BuildContext context, String key) {
    switch (key) {
      case 'loseWeight':
        return AppLocalizations.of(context)?.loseWeight ?? 'Giảm cân';
      case 'maintainWeight':
        return AppLocalizations.of(context)?.maintainWeight ??
            'Duy trì cân nặng';
      case 'gainWeight':
        return AppLocalizations.of(context)?.gainWeight ?? 'Tăng cân';
      case 'buildMuscle':
        return AppLocalizations.of(context)?.buildMuscle ?? 'Tăng cơ';
      default:
        return key;
    }
  }
}

class _GoalItem {
  final String icon;
  final String title;
  const _GoalItem({required this.icon, required this.title});
}
