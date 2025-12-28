import 'dart:convert';

import 'package:diet_tracking_project/view/splash/splash_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  static final Uint8List _transparentPng = base64Decode(
    // 1x1 transparent PNG
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+X2ZcAAAAASUVORK5CYII=',
  );

  static final ByteData _emptyAssetManifestBin =
      const StandardMessageCodec().encodeMessage(<String, dynamic>{})!;

  static ByteData _utf8(String value) {
    final bytes = utf8.encode(value);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  @override
  Future<ByteData> load(String key) async {
    // Flutter may ask for asset manifests during widget tests.
    if (key == 'AssetManifest.bin') return _emptyAssetManifestBin;
    if (key == 'AssetManifest.json') return _utf8('{}');
    if (key == 'FontManifest.json') return _utf8('[]');

    // App splash image.
    if (key == 'assets/logo/load_image.png') {
      return ByteData.view(_transparentPng.buffer);
    }

    // Default to an empty payload for any other asset.
    return _utf8('');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'AssetManifest.json') return '{}';
    if (key == 'FontManifest.json') return '[]';
    return '';
  }
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    home: DefaultAssetBundle(
      bundle: _FakeAssetBundle(),
      child: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashScreen', () {
    testWidgets('shows background image, progress bar and loading text',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          SplashScreen(
            auth: MockFirebaseAuth(signedIn: false),
            welcomeBuilder: (_) => const SizedBox(),
            homeBuilder: (_) => const SizedBox(),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('Đang tải...'), findsOneWidget);

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, isNotNull);
      expect(indicator.value!, closeTo(0.0, 0.0001));
    });

    testWidgets('navigates to welcome when user is null after loading completes',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          SplashScreen(
            auth: MockFirebaseAuth(signedIn: false),
            welcomeBuilder: (_) => const Scaffold(body: Text('WELCOME')),
            homeBuilder: (_) => const Scaffold(body: Text('HOME')),
          ),
        ),
      );

      // ~2s to reach 100% progress (20ms tick * 100 steps).
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();

      expect(find.text('WELCOME'), findsOneWidget);
      expect(find.text('HOME'), findsNothing);
    });

    testWidgets('navigates to home when user is signed in after loading completes',
        (tester) async {
      final mockUser = MockUser(uid: 'uid-1');
      final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      await tester.pumpWidget(
        _buildTestApp(
          SplashScreen(
            auth: auth,
            welcomeBuilder: (_) => const Scaffold(body: Text('WELCOME')),
            homeBuilder: (_) => const Scaffold(body: Text('HOME')),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('WELCOME'), findsNothing);
    });
  });
}
