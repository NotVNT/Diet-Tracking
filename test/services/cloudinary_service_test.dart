import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/services/cloudinary_service.dart';
import 'package:diet_tracking_project/config/cloudinary_config.dart';

void main() {
  group('CloudinaryService', () {
    test('fromConfig returns service with expected values', () {
      final svc = CloudinaryService.fromConfig();
      expect(svc.cloudName, CloudinaryConfig.cloudName);
      expect(svc.uploadPreset, CloudinaryConfig.uploadPreset);
      // apiKey may be null when empty in config
      if (CloudinaryConfig.apiKey.isEmpty) {
        expect(svc.apiKey, isNull);
      } else {
        expect(svc.apiKey, CloudinaryConfig.apiKey);
      }
    });

    test('can be constructed directly without apiKey', () {
      final svc = CloudinaryService(
        cloudName: 'demo',
        uploadPreset: 'unsigned',
      );
      expect(svc.cloudName, 'demo');
      expect(svc.uploadPreset, 'unsigned');
      expect(svc.apiKey, isNull);
    });
  });
}

