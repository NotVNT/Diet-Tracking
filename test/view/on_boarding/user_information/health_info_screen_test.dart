import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/health_info_screen.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;

class _LocalFake extends LocalStorageService {
  Map<String, dynamic>? saved;
  @override
  Future<void> saveGuestData({
    String? goal,
    double? heightCm,
    double? weightKg,
    double? goalWeightKg,
    double? goalHeightCm,
    String? health,
    List<String>? medicalConditions,
    List<String>? allergies,
    int? age,
    String? gender,
    String? language,
  }) async {
    saved = {'medicalConditions': medicalConditions, 'allergies': allergies};
  }
}

class _NoAuth {}

void main() {
  flutter_test.setUpAll(() async {
    flutter_test.TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('HealthInfoScreen continue without input', (tester) async {
    final local = _LocalFake();
    await tester.pumpWidget(
      MaterialApp(
        home: HealthInfoScreen(localStorageService: local, authService: null),
      ),
    );

    // Bấm tiếp tục không nhập gì
    final continueFinder = find.text('Tiếp tục');
    await tester.ensureVisible(continueFinder);
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    // Không crash và không lưu gì
    expect(local.saved, isNull);
  });
}
