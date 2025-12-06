import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:diet_tracking_project/services/user_avatar_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserAvatarService', () {
    test('singleton instance', () {
      expect(identical(UserAvatarService.instance, UserAvatarService.instance), isTrue);
    });

    test('updateAvatarUrl affects imageProvider (NetworkImage)', () {
      final svc = UserAvatarService.instance;
      svc.updateAvatarUrl('https://example.com/a.png');
      final provider = svc.imageProvider;
      expect(provider, isA<NetworkImage>());
      final net = provider as NetworkImage;
      expect(net.url, 'https://example.com/a.png');
    });

    test('falls back to gender asset when no avatar', () {
      final svc = UserAvatarService.instance;
      svc.updateAvatarUrl(null);
      final provider = svc.imageProvider;
      // gender is unknown -> defaults to men asset per implementation
      expect(provider, isA<AssetImage>());
      final asset = provider as AssetImage;
      expect(asset.assetName, 'assets/gender/men.jpg');
    });
  });
}

