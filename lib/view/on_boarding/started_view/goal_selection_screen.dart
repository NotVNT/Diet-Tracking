import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'goal_reason_screen.dart';
import '../../../database/local_storage_service.dart';
import '../../../database/auth_service.dart';
import '../../../features/profile_view_home/presentation/widgets/profile_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/progress_bar/started_progress_bar.dart';

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
  int? _selectedSubIndex;
  late LocalStorageService _local;
  late AuthService _auth;

  final List<_GoalItem> _goals = const [
    _GoalItem(
      icon: '📉',
      title: 'loseWeight',
      subOptions: [
        _GoalItem(icon: '🥗', title: 'normalWeightLoss'),
        _GoalItem(icon: '🥑', title: 'keto'),
        _GoalItem(icon: '🥦', title: 'lowCarb'),
      ],
    ),
    _GoalItem(icon: '📈', title: 'gainWeight'),
    _GoalItem(icon: '⚖️', title: 'maintainWeight'),
    _GoalItem(icon: '🏋️', title: 'buildMuscle'),
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
            StartedProgressBar(
              currentStep: 1,
              totalSteps: 4,
              activeColor: _primary,
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
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemCount: _goals.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_selectedIndex == null ||
                          (_goals[_selectedIndex!].subOptions != null &&
                              _goals[_selectedIndex!].subOptions!.isNotEmpty &&
                              _selectedSubIndex == null))
                      ? null
                      : () async {
                          final selectedTitle = _buildPersistedGoalKey();

                          // Lưu goal vào localStorage (luôn lưu để có sẵn cho signup flow)
                          debugPrint(
                            'Saving goal to localStorage: $selectedTitle',
                          );
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
                    disabledBackgroundColor: Colors.black.withValues(
                      alpha: 0.1,
                    ),
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
    final bool hasSubOptions =
        item.subOptions != null && item.subOptions!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: selected ? _primary.withValues(alpha: 0.05) : Colors.white,
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
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(18),
              bottom: (selected && hasSubOptions)
                  ? Radius.zero
                  : const Radius.circular(18),
            ),
            onTap: () => setState(() {
              if (_selectedIndex != index) {
                _selectedIndex = index;
                _selectedSubIndex = null;
              } else {
                _selectedIndex = null;
                _selectedSubIndex = null;
              }
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    child: Text(
                      item.icon,
                      style: const TextStyle(fontSize: 22),
                    ),
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
          ),
          if (selected && hasSubOptions)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(item.subOptions!.length, (subIndex) {
                    final subOption = item.subOptions![subIndex];
                    final isSubSelected = _selectedSubIndex == subIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isSubSelected
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSubSelected
                            ? Border.all(color: _primary.withValues(alpha: 0.2))
                            : null,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedSubIndex = subIndex;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Text(
                                subOption.icon,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _getLocalizedTitle(context, subOption.title),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSubSelected ? _primary : _muted,
                                  ),
                                ),
                              ),
                              if (isSubSelected)
                                Icon(Icons.check, color: _primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
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
      case 'normalWeightLoss':
        return AppLocalizations.of(context)?.normalWeightLoss ??
            'Giảm cân thông thường';
      case 'keto':
        return AppLocalizations.of(context)?.keto ?? 'Keto';
      case 'lowCarb':
        // Localization key in ARB is `lowCarbs`
        return AppLocalizations.of(context)?.lowCarbs ?? 'Low Carbs';
      default:
        return key;
    }
  }

  /// Build the goal value that must be persisted.
  ///
  /// IMPORTANT: This value is meant for backend/storage and must stay stable
  /// across locales (do NOT store localized labels).
  String _buildPersistedGoalKey() {
    final mainKey = _goals[_selectedIndex!].title;
    if (mainKey == 'loseWeight') {
      final subKey =
          (_selectedSubIndex != null &&
              _goals[_selectedIndex!].subOptions != null)
          ? _goals[_selectedIndex!].subOptions![_selectedSubIndex!].title
          : null;

      switch (subKey) {
        case 'keto':
          return GoalConstants.loseWeightKeto;
        case 'lowCarb':
          return GoalConstants.loseWeightLowCarb;
        case 'normalWeightLoss':
        default:
          return GoalConstants.loseWeight;
      }
    }

    switch (mainKey) {
      case 'gainWeight':
        return GoalConstants.gainWeight;
      case 'maintainWeight':
        return GoalConstants.maintainWeight;
      case 'buildMuscle':
        return GoalConstants.buildMuscle;
      default:
        // Fallback: return raw key (still stable, non-localized)
        return mainKey;
    }
  }
}

class _GoalItem {
  final String icon;
  final String title;
  final List<_GoalItem>? subOptions;
  const _GoalItem({required this.icon, required this.title, this.subOptions});
}
