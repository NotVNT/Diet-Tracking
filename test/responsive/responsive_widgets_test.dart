import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/responsive/responsive_widgets.dart';

void main() {
  Future<void> _withSize(
    WidgetTester tester,
    Size size,
    Widget child,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(home: child),
      ),
    );
  }

  group('ResponsiveBuilder', () {
    testWidgets('selects widgets based on device type', (tester) async {
      const mobileKey = Key('mobile');
      const smallKey = Key('small');

      // Small phone
      await _withSize(
        tester,
        const Size(350, 700),
        ResponsiveBuilder(
          mobile: const SizedBox(key: mobileKey),
          smallPhone: const SizedBox(key: smallKey),
        ),
      );
      expect(find.byKey(smallKey), findsOneWidget);

      // Phone (fallback to mobile when phone/smallPhone null)
      await _withSize(
        tester,
        const Size(380, 700),
        const ResponsiveBuilder(mobile: SizedBox(key: mobileKey)),
      );
      expect(find.byKey(mobileKey), findsOneWidget);
    });
  });

  group('ResponsiveContainer', () {
    testWidgets('applies width/height/padding', (tester) async {
      const cKey = Key('container');
      await _withSize(
        tester,
        const Size(390, 844),
        ResponsiveContainer(
          key: cKey,
          baseWidth: 100,
          baseHeight: 80,
          basePadding: 16,
          child: const Text('x'),
        ),
      );

      final size = tester.getSize(find.byKey(cKey));
      expect(size.width > 0, true);
      expect(size.height > 0, true);
    });
  });

  group('ResponsiveText', () {
    testWidgets('applies responsive text style', (tester) async {
      await _withSize(
        tester,
        const Size(390, 844),
        const ResponsiveText('Hello', style: TextStyle(fontSize: 20)),
      );
      final text = tester.widget<Text>(find.text('Hello'));
      expect(text.style, isNotNull);
    });
  });

  group('ResponsiveCard', () {
    testWidgets('renders and handles onTap', (tester) async {
      int tapped = 0;
      await _withSize(
        tester,
        const Size(390, 844),
        ResponsiveCard(
          child: const Text('Card'),
          onTap: () => tapped++,
        ),
      );

      // InkWell is present when onTap provided
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(tapped, 1);
    });
  });

  group('ResponsiveIcon', () {
    testWidgets('uses responsive icon size', (tester) async {
      await _withSize(
        tester,
        const Size(390, 844),
        const ResponsiveIcon(Icons.add, baseSize: 24),
      );
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size! > 0, true);
    });
  });

  group('ResponsiveButton', () {
    testWidgets('renders and triggers onPressed', (tester) async {
      int pressed = 0;
      await _withSize(
        tester,
        const Size(390, 844),
        ResponsiveButton(
          child: const Text('Press'),
          onPressed: () => pressed++,
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, 1);

      final sized = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sized.height != null && sized.height! > 0, true);
    });
  });

  group('ResponsiveSpacer', () {
    testWidgets('produces SizedBox with non-zero dimension', (tester) async {
      await _withSize(
        tester,
        const Size(390, 844),
        const ResponsiveSpacer(baseHeight: 16),
      );
      final box = tester.widget<SizedBox>(find.byType(SizedBox));
      expect((box.height ?? 0) > 0, true);
    });
  });

  group('ResponsiveGridView', () {
    testWidgets('renders children and adapts crossAxisCount', (tester) async {
      final kids = List<Widget>.generate(4, (i) => Text('Item $i', key: Key('k$i')));

      await _withSize(
        tester,
        const Size(390, 844),
        ResponsiveGridView(
          children: kids,
          shrinkWrap: true,
        ),
      );

      for (var i = 0; i < 4; i++) {
        expect(find.byKey(Key('k$i')), findsOneWidget);
      }
    });
  });
}

