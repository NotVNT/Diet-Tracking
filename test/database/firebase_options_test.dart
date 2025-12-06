import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/database/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    test('web options should be defined and non-empty', () {
      expect(DefaultFirebaseOptions.web.apiKey.isNotEmpty, true);
      expect(DefaultFirebaseOptions.web.projectId, 'diet-tracking-f365a');
      expect(DefaultFirebaseOptions.web.appId.isNotEmpty, true);
    });

    test('android options should be defined and non-empty', () {
      expect(DefaultFirebaseOptions.android.apiKey.isNotEmpty, true);
      expect(DefaultFirebaseOptions.android.projectId, 'diet-tracking-f365a');
      expect(DefaultFirebaseOptions.android.appId.isNotEmpty, true);
    });

    test('ios options should be defined and non-empty', () {
      expect(DefaultFirebaseOptions.ios.apiKey.isNotEmpty, true);
      expect(DefaultFirebaseOptions.ios.projectId, 'diet-tracking-f365a');
      expect(DefaultFirebaseOptions.ios.appId.isNotEmpty, true);
    });

    test('macos options should be defined and non-empty', () {
      expect(DefaultFirebaseOptions.macos.apiKey.isNotEmpty, true);
      expect(DefaultFirebaseOptions.macos.projectId, 'diet-tracking-f365a');
      expect(DefaultFirebaseOptions.macos.appId.isNotEmpty, true);
    });

    test('windows options should be defined and non-empty', () {
      expect(DefaultFirebaseOptions.windows.apiKey.isNotEmpty, true);
      expect(DefaultFirebaseOptions.windows.projectId, 'diet-tracking-f365a');
      expect(DefaultFirebaseOptions.windows.appId.isNotEmpty, true);
    });
  });
}

