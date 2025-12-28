import 'package:flutter/material.dart';
import '../../../database/local_storage_service.dart';
import '../../../database/auth_service.dart';
import '../../../widget/progress_bar/user_progress_bar.dart';
import '../../../widget/health/health_background.dart';
import '../../../widget/health/health_header.dart';
import '../../../widget/health/allergy_selection_card.dart';
import '../../../widget/health/health_navigation_bar.dart';
import 'height_selector.dart';

class HealthInfoScreen extends StatefulWidget {
  final AuthService? authService;
  final LocalStorageService? localStorageService;
  const HealthInfoScreen({
    super.key,
    this.authService,
    this.localStorageService,
  });

  @override
  State<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends State<HealthInfoScreen> {
  List<String> _allergies = <String>[];
  late final LocalStorageService _local;
  AuthService? _auth;

  // Chuẩn hóa danh sách: trim, loại bỏ rỗng, bỏ trùng; trả về null nếu trống
  List<String>? _sanitize(List<String>? values) {
    if (values == null) return null;
    final cleaned = values
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    return cleaned.isEmpty ? null : cleaned;
  }

  @override
  void initState() {
    super.initState();
    _local = widget.localStorageService ?? LocalStorageService();
    _auth = widget.authService; // tránh khởi tạo Firebase khi test
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HealthBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ProgressBarWidget(progress: 3 / 8),
              ),
              const SizedBox(height: 20),

              const HealthHeader(
                title: 'Dị Ứng Thực Phẩm',
                subtitle:
                    'Vui lòng cung cấp thông tin về dị ứng thực phẩm của bạn để chúng tôi có thể hỗ trợ tốt nhất',
              ),
              const SizedBox(height: 24),

              // Card: Food allergies
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AllergySelectionCard(
                    selectedAllergies: _allergies,
                    onAllergiesChanged: (newList) {
                      setState(() {
                        _allergies = newList;
                      });
                    },
                  ),
                ),
              ),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: HealthNavigationBar(
                  onBack: () => Navigator.of(context).maybePop(),
                  onNext: () async {
                    final navigator = Navigator.of(context);
                    final uid = _auth?.currentUser?.uid;
                    final bool hasAny = _allergies.isNotEmpty;

                    if (uid != null) {
                      if (hasAny) {
                        final sanitizedAllergies = _sanitize(_allergies);
                        await _auth!.updateUserData(uid, {
                          if (sanitizedAllergies != null)
                            'bodyInfo.allergies': sanitizedAllergies,
                        });
                      }
                    } else {
                      if (hasAny) {
                        await _local.saveGuestData(
                          allergies: _sanitize(_allergies),
                        );
                      }
                    }

                    if (!mounted) return;

                    navigator.push(
                      MaterialPageRoute(builder: (_) => const HeightSelector()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
