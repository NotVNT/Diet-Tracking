import 'package:flutter/material.dart';
import '../../../database/local_storage_service.dart';
import '../../../database/auth_service.dart';
import '../../../common/app_styles.dart';
import '../../../common/custom_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/health/add_button.dart';
import '../../../widget/health/health_text_field.dart';
import '../../../widget/health/health_card_widget.dart';
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
  final TextEditingController _diseaseCtrl = TextEditingController();
  final TextEditingController _allergyCtrl = TextEditingController();
  final List<String> _diseases = <String>[];
  final List<String> _allergies = <String>[];
  late final LocalStorageService _local;
  AuthService? _auth;

  @override
  void initState() {
    super.initState();
    _local = widget.localStorageService ?? LocalStorageService();
    _auth = widget.authService; // tránh khởi tạo Firebase khi test
  }

  @override
  void dispose() {
    _diseaseCtrl.dispose();
    _allergyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Thông Tin Sức Khỏe';
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              Text(
                title,
                style: AppStyles.heading1.copyWith(
                  color: const Color(0xFF0FB5A6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Vui lòng cung cấp thông tin về bệnh lý và dị ứng thực phẩm của bạn để chúng tôi có thể hỗ trợ tốt nhất',
                style: AppStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Card 1: Diseases
              HealthCardWidget(
                index: 1,
                title: 'Bệnh Lý',
                description:
                    'Nhập các bệnh lý hiện tại nếu có. Thông tin này giúp chúng tôi tư vấn phù hợp hơn.',
                input: HealthTextField(
                  controller: _diseaseCtrl,
                  hintText: 'Ví dụ: Tiểu đường, Cao huyết áp, Hen suyễn,...',
                ),
                trailingButton: AddButton(
                  onPressed: () {
                    final text = _diseaseCtrl.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      if (!_diseases.contains(text)) {
                        _diseases.add(text);
                      }
                      _diseaseCtrl.clear();
                    });
                  },
                ),
                emptyIcon: Icons.favorite_border,
                emptyText:
                    'Chưa có bệnh lý nào được thêm. Nếu không có, bạn có thể bỏ qua phần này.',
                items: _diseases,
                onRemoveItem: (i) => setState(() => _diseases.removeAt(i)),
              ),
              const SizedBox(height: 14),

              // Card 2: Food allergies
              HealthCardWidget(
                index: 2,
                title: 'Dị Ứng Thực Phẩm',
                description:
                    'Nhập các món ăn hoặc thực phẩm gây dị ứng nếu có. Điều này giúp đảm bảo an toàn cho bạn.',
                input: HealthTextField(
                  controller: _allergyCtrl,
                  hintText: 'Ví dụ: Hải sản, Đậu phộng, Sữa, Trứng...',
                ),
                trailingButton: AddButton(
                  onPressed: () {
                    final text = _allergyCtrl.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      if (!_allergies.contains(text)) {
                        _allergies.add(text);
                      }
                      _allergyCtrl.clear();
                    });
                  },
                ),
                emptyIcon: Icons.info_outline,
                emptyText:
                    'Chưa có dị ứng thực phẩm nào được thêm. Nếu không có, bạn có thể bỏ qua phần này.',
                items: _allergies,
                onRemoveItem: (i) => setState(() => _allergies.removeAt(i)),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF2D3A4A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: AppLocalizations.of(context)?.next ?? 'Tiếp tục',
                      backgroundColor: const Color(0xFF1F2A37),
                      onPressed: () async {
                        final uid = _auth?.currentUser?.uid;
                        final bool hasAny =
                            _diseases.isNotEmpty || _allergies.isNotEmpty;

                        if (uid != null) {
                          if (hasAny) {
                            await _auth!.updateUserData(uid, {
                              if (_diseases.isNotEmpty)
                                'bodyInfo.medicalConditions': _diseases,
                              if (_allergies.isNotEmpty)
                                'bodyInfo.allergies': _allergies,
                            });
                          }
                        } else {
                          if (hasAny) {
                            await _local.saveGuestData(
                              medicalConditions: _diseases.isEmpty
                                  ? null
                                  : _diseases,
                              allergies: _allergies.isEmpty ? null : _allergies,
                            );
                          }
                        }

                        if (!mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HeightSelector(),
                          ),
                        );
                      },
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
