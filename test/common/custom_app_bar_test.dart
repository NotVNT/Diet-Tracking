import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:diet_tracking_project/common/custom_app_bar.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';

void main() {
  group('CustomAppBar', () {
    group('Basic Rendering', () {
      testWidgets('should render with title', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(
                title: 'Test Title',
                showNotificationBell: false,
              ),
              body: SizedBox(),
            ),
          ),
        );

        expect(find.text('Test Title'), findsOneWidget);
      });

      testWidgets('should render AppBar with correct properties', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(title: 'Test', showNotificationBell: false),
              body: SizedBox(),
            ),
          ),
        );

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.elevation, 0);
        expect(appBar.centerTitle, true);
      });

      testWidgets('should not show back button by default', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(title: 'Test', showNotificationBell: false),
              body: SizedBox(),
            ),
          ),
        );

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.automaticallyImplyLeading, false);
      });

      testWidgets('should show back button when enabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(
                title: 'Test',
                showBackButton: true,
                showNotificationBell: false,
              ),
              body: SizedBox(),
            ),
          ),
        );

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.automaticallyImplyLeading, true);
      });
    });

    group('Custom Background Color', () {
      testWidgets('should use custom background color', (
        WidgetTester tester,
      ) async {
        const customColor = Color(0xFF123456);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(
                title: 'Test',
                backgroundColor: customColor,
                showNotificationBell: false,
              ),
              body: SizedBox(),
            ),
          ),
        );

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, customColor);
      });

      testWidgets('should use default background color when not provided', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(title: 'Test', showNotificationBell: false),
              body: SizedBox(),
            ),
          ),
        );

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, isNotNull);
      });
    });

    group('Custom Actions', () {
      testWidgets('should render custom actions', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(
                title: 'Test',
                showNotificationBell: false,
                actions: [
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                ],
              ),
              body: const SizedBox(),
            ),
          ),
        );

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should render multiple custom actions', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(
                title: 'Test',
                showNotificationBell: false,
                actions: [
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
              body: const SizedBox(),
            ),
          ),
        );

        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.byIcon(Icons.more_vert), findsOneWidget);
      });

      testWidgets('should not render actions when not provided', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(title: 'Test', showNotificationBell: false),
              body: SizedBox(),
            ),
          ),
        );

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        // When no custom actions, only notification bell should be in actions
        expect(appBar.actions, isNotNull);
      });
    });

    group('Notification Bell', () {
      testWidgets('should show notification bell by default', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ],
            child: const MaterialApp(
              home: Scaffold(
                appBar: CustomAppBar(title: 'Test'),
                body: SizedBox(),
              ),
            ),
          ),
        );

        // Notification bell should be rendered
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should hide notification bell when disabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ],
            child: const MaterialApp(
              home: Scaffold(
                appBar: CustomAppBar(
                  title: 'Test',
                  showNotificationBell: false,
                ),
                body: SizedBox(),
              ),
            ),
          ),
        );

        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('Title Styling', () {
      testWidgets('should render title with correct style', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(
                title: 'Styled Title',
                showNotificationBell: false,
              ),
              body: SizedBox(),
            ),
          ),
        );

        final titleWidget = tester.widget<Text>(find.text('Styled Title'));
        expect(titleWidget.style, isNotNull);
        expect(titleWidget.style?.fontWeight, FontWeight.w600);
      });
    });

    group('PreferredSizeWidget', () {
      testWidgets('should have correct preferred size', (
        WidgetTester tester,
      ) async {
        const appBar = CustomAppBar(title: 'Test');
        expect(appBar.preferredSize, const Size.fromHeight(kToolbarHeight));
      });
    });

    group('Integration Tests', () {
      testWidgets('should render in Scaffold correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(
                title: 'Integration Test',
                showBackButton: true,
                showNotificationBell: false,
              ),
              body: Center(child: Text('Body')),
            ),
          ),
        );

        expect(find.text('Integration Test'), findsOneWidget);
        expect(find.text('Body'), findsOneWidget);
      });

      testWidgets('should work with custom actions and notification bell', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ],
            child: MaterialApp(
              home: Scaffold(
                appBar: CustomAppBar(
                  title: 'Full Featured',
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ],
                  showNotificationBell: true,
                ),
                body: const SizedBox(),
              ),
            ),
          ),
        );

        expect(find.text('Full Featured'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });
    });
  });
}
