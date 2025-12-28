import 'package:diet_tracking_project/features/food_scanner/data/models/food_scanner_models.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/widgets/scanner_bottom_overlay.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/widgets/scanner_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Finder captureOuterFinder() {
    return find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.constraints != null &&
          w.constraints!.minWidth == ScannerDims.captureOuter &&
          w.constraints!.maxWidth == ScannerDims.captureOuter &&
          w.constraints!.minHeight == ScannerDims.captureOuter &&
          w.constraints!.maxHeight == ScannerDims.captureOuter,
      description: 'Capture outer button container',
    );
  }

  testWidgets('ScannerBottomOverlay shows capture button for food', (tester) async {
    const actions = [
      ScannerActionConfig(
        type: ScannerActionType.food,
        label: 'Food',
        icon: Icons.restaurant_outlined,
      ),
      ScannerActionConfig(
        type: ScannerActionType.barcode,
        label: 'Barcode',
        icon: Icons.qr_code_scanner,
      ),
      ScannerActionConfig(
        type: ScannerActionType.gallery,
        label: 'Gallery',
        icon: Icons.photo_library_outlined,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScannerBottomOverlay(
            actions: actions,
            selectedAction: ScannerActionType.food,
            onActionSelected: (_) {},
            onCapture: () {},
          ),
        ),
      ),
    );

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Barcode'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);

    expect(captureOuterFinder(), findsOneWidget);
  });

  testWidgets('ScannerBottomOverlay hides capture button for barcode', (tester) async {
    const actions = [
      ScannerActionConfig(
        type: ScannerActionType.food,
        label: 'Food',
        icon: Icons.restaurant_outlined,
      ),
      ScannerActionConfig(
        type: ScannerActionType.barcode,
        label: 'Barcode',
        icon: Icons.qr_code_scanner,
      ),
      ScannerActionConfig(
        type: ScannerActionType.gallery,
        label: 'Gallery',
        icon: Icons.photo_library_outlined,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScannerBottomOverlay(
            actions: actions,
            selectedAction: ScannerActionType.barcode,
            onActionSelected: (_) {},
            onCapture: () {},
          ),
        ),
      ),
    );

    // In barcode mode, capture button is not rendered.
    expect(captureOuterFinder(), findsNothing);
  });
}
