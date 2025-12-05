import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/identities/register/register_ui_helper.dart';

void main() {
  group('RegisterUIHelper Tests', () {
    testWidgets('showLoadingDialog hiển thị dialog loading', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(key: key, body: const SizedBox.shrink()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);

      RegisterUIHelper.showLoadingDialog(key.currentContext!);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hideLoadingDialog ẩn dialog loading', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(key: key, body: const SizedBox.shrink()),
        ),
      );

      // Hiển thị dialog
      RegisterUIHelper.showLoadingDialog(key.currentContext!);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Ẩn dialog
      RegisterUIHelper.hideLoadingDialog(key.currentContext!);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('showErrorSnackBar hiển thị error snackbar', (tester) async {
      const errorMessage = 'Đây là lỗi';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => RegisterUIHelper.showErrorSnackBar(
                      context,
                      errorMessage,
                    ),
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsNothing);

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('showSuccessSnackBar hiển thị success snackbar', (
      tester,
    ) async {
      const successMessage = 'Thành công!';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => RegisterUIHelper.showSuccessSnackBar(
                      context,
                      successMessage,
                    ),
                    child: const Text('Show Success'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text(successMessage), findsNothing);

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      expect(find.text(successMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('error snackbar có màu đỏ', (tester) async {
      const errorMessage = 'Error message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => RegisterUIHelper.showErrorSnackBar(
                      context,
                      errorMessage,
                    ),
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      final snackBar = find.byType(SnackBar);
      expect(snackBar, findsOneWidget);
    });

    testWidgets('success snackbar có màu xanh', (tester) async {
      const successMessage = 'Success message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => RegisterUIHelper.showSuccessSnackBar(
                      context,
                      successMessage,
                    ),
                    child: const Text('Show Success'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      final snackBar = find.byType(SnackBar);
      expect(snackBar, findsOneWidget);
    });
  });
}
