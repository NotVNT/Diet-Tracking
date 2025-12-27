import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/record_view_home/presentation/widgets/search_bar.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SearchBar widget', () {
    testWidgets('debounces onSearchChanged and trims value', (tester) async {
      final calls = <String>[];

      await tester.pumpWidget(
        _wrap(
          SearchBar(
            debounce: const Duration(milliseconds: 200),
            onSearchChanged: calls.add,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '  apple  ');

      // Not fired yet (debounce)
      await tester.pump(const Duration(milliseconds: 150));
      expect(calls, isEmpty);

      // Debounce completes
      await tester.pump(const Duration(milliseconds: 60));
      expect(calls, ['apple']);
    });

    testWidgets('clear button clears text and calls onSearchChanged with empty', (tester) async {
      final calls = <String>[];

      await tester.pumpWidget(
        _wrap(
          SearchBar(
            debounce: const Duration(milliseconds: 200),
            onSearchChanged: calls.add,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'banana');
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text ?? '', '');

      // Clear triggers immediate call with empty string
      expect(calls.last, '');
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('onSubmitted trims value', (tester) async {
      String? submitted;

      await tester.pumpWidget(
        _wrap(
          SearchBar(
            onSubmitted: (v) => submitted = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '  kiwi  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, 'kiwi');
    });
  });
}
