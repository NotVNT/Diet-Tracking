import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/health_info_screen.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:diet_tracking_project/widget/progress_bar/user_progress_bar.dart';

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

  testWidgets('HealthInfoScreen displays progress bar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HealthInfoScreen(),
      ),
    );

    // Tìm ProgressBarWidget
    final progressBarFinder = find.byType(ProgressBarWidget);

    // Kiểm tra xem widget có tồn tại không
    expect(progressBarFinder, findsOneWidget);
  });
}
