import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/common/snackbar_helper.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('SnackBarHelper', () {
    group('showSnackBar (basic)', () {
      testWidgets('shows snackbar with message', (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapWithApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    SnackBarHelper.showSnackBar(context, 'Test message'),
                child: const Text('Show SnackBar'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show SnackBar'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Test message'), findsOneWidget);
      });

      testWidgets('uses floating behavior and margin', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _wrapWithApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => SnackBarHelper.showSnackBar(context, 'Msg'),
                child: const Text('Show SnackBar'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show SnackBar'));
        await tester.pumpAndSettle();

        final bar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(bar.behavior, SnackBarBehavior.floating);
        expect(bar.margin, const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 70.0));
      });
    });

    group('pre-styled helpers (minimal assertions)', () {
      testWidgets('showSuccess shows a SnackBar', (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapWithApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    SnackBarHelper.showSuccess(context, 'Success message'),
                child: const Text('Show Success'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Success'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('showError shows a SnackBar', (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapWithApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    SnackBarHelper.showError(context, 'Error message'),
                child: const Text('Show Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('showInfo shows a SnackBar', (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapWithApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    SnackBarHelper.showInfo(context, 'Info message'),
                child: const Text('Show Info'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Info'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('showWarning shows a SnackBar', (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapWithApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    SnackBarHelper.showWarning(context, 'Warning message'),
                child: const Text('Show Warning'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Warning'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
      });
    });
  });
}
