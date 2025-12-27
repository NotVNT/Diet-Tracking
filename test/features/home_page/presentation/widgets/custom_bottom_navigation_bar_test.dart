import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/home_page/presentation/widgets/navigation/bottom_navigation_bar.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: const SizedBox.shrink(),
      bottomNavigationBar: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('maps page currentIndex to bottom nav display index', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Future<int> pumpAndGetDisplayIndex(int currentIndex) async {
      await tester.pumpWidget(
        _wrap(
          CustomBottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      return bar.currentIndex;
    }

    expect(await pumpAndGetDisplayIndex(0), 0, reason: 'Home -> Home');
    expect(await pumpAndGetDisplayIndex(1), 1, reason: 'Record -> center placeholder');
    expect(await pumpAndGetDisplayIndex(2), 1, reason: 'Chat -> center placeholder');
    expect(await pumpAndGetDisplayIndex(3), 2, reason: 'Profile -> Profile');
  });

  testWidgets('tapping Home calls onTap(0), tapping Profile calls onTap(3)', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final tapped = <int>[];

    await tester.pumpWidget(
      _wrap(
        CustomBottomNavigationBar(
          currentIndex: 0,
          onTap: tapped.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    expect(tapped, [3, 0]);
  });

  testWidgets('tapping center placeholder does not call onTap', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var called = false;

    await tester.pumpWidget(
      _wrap(
        CustomBottomNavigationBar(
          currentIndex: 0,
          onTap: (_) => called = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the middle item by tapping near the center bottom.
    final navBarRect = tester.getRect(find.byType(BottomNavigationBar));
    final center = Offset(navBarRect.center.dx, navBarRect.center.dy);
    await tester.tapAt(center);
    await tester.pumpAndSettle();

    expect(called, isFalse);
  });
}
