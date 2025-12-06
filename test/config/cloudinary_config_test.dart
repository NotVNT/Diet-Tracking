import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/config/cloudinary_config.dart';

void main() {
  group('CloudinaryConfig', () {
    test('should have correct default constants', () {
      expect(CloudinaryConfig.cloudName, 'dci3aehg5');
      expect(CloudinaryConfig.uploadPreset, 'avatar_preset');
      expect(CloudinaryConfig.apiKey, ''); // empty by default
      expect(CloudinaryConfig.folder, 'avatars');
    });

    test('cloudName and uploadPreset should be non-empty', () {
      expect(CloudinaryConfig.cloudName.isNotEmpty, true);
      expect(CloudinaryConfig.uploadPreset.isNotEmpty, true);
    });
  });
}

