import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/common/custom_app_bar.dart';

void main() {
  group('CustomAppBar', () {
    testWidgets('should render with required title', (
      WidgetTester tester,
    ) async {
      const String title = 'Test Title';
      
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(appBar: CustomAppBar(title: title))),
      );

      expect(find.byType(CustomAppBar), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('should not show back button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(appBar: CustomAppBar(title: 'Test'))),
      );

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('should call onBackPressed when back button is tapped', (
      WidgetTester tester,
    ) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Test',
              onBackPressed: () {
                backPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(backPressed, true);
    });

    testWidgets(
      'should use default back navigation when onBackPressed is null',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(appBar: const CustomAppBar())),
        );

        // Should not throw an error when tapped
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();
      },
    );

    testWidgets('should render with custom actions', (
      WidgetTester tester,
    ) async {
      const actions = [Icon(Icons.search), Icon(Icons.more_vert)];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: const CustomAppBar(actions: actions)),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should use custom backgroundColor', (
      WidgetTester tester,
    ) async {
      const Color customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(backgroundColor: customColor),
          ),
        ),
      );

      final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, customColor);
    });

    testWidgets('should use default backgroundColor when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(appBar: const CustomAppBar())),
      );

      final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.white);
    });

    testWidgets('should center title when centerTitle is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(
              title: 'Centered Title',
              centerTitle: true,
            ),
          ),
        ),
      );

      final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, true);
    });

    testWidgets('should not center title when centerTitle is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(title: 'Left Title', centerTitle: false),
          ),
        ),
      );

      final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, false);
    });

    testWidgets('should have correct preferred size', (
      WidgetTester tester,
    ) async {
      const customAppBar = CustomAppBar();

      expect(customAppBar.preferredSize, const Size.fromHeight(kToolbarHeight));
    });

    testWidgets('should render back button with correct styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(appBar: const CustomAppBar())),
      );

      final IconButton backButton = tester.widget<IconButton>(
        find.byType(IconButton),
      );
      expect(backButton.icon, isA<Container>());

      final Container iconContainer = backButton.icon as Container;
      expect(iconContainer.padding, const EdgeInsets.all(8));
      expect(iconContainer.decoration, isA<BoxDecoration>());
    });

    testWidgets('should render title with correct style', (
      WidgetTester tester,
    ) async {
      const String title = 'Styled Title';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: const CustomAppBar(title: title)),
        ),
      );

      final Text titleWidget = tester.widget<Text>(find.text(title));
      expect(titleWidget.style, AppStyles.heading2);
    });

    testWidgets('should not render title when title is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(appBar: const CustomAppBar())),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should have zero elevation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(appBar: const CustomAppBar())),
      );

      final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.elevation, 0);
    });

    testWidgets('should handle multiple actions correctly', (
      WidgetTester tester,
    ) async {
      const actions = [
        Icon(Icons.search),
        Icon(Icons.favorite),
        Icon(Icons.share),
        Icon(Icons.more_vert),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: const CustomAppBar(actions: actions)),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}


