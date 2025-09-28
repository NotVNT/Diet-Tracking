import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:diet_tracking_project/view/profile/profile_view.dart';
import 'package:diet_tracking_project/database/auth_service.dart';

import 'profile_view_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  group('ProfileView', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    test('ProfileView có thể được tạo với AuthService', () {
      // Arrange & Act
      final profileView = ProfileView(authService: mockAuthService);

      // Assert
      expect(profileView, isNotNull);
      expect(profileView.authService, equals(mockAuthService));
    });

    test('ProfileView có thể được tạo mà không cần AuthService', () {
      // Arrange & Act
      final profileView = const ProfileView();

      // Assert
      expect(profileView, isNotNull);
      expect(profileView.authService, isNull);
    });

    test('ProfileView có key được set đúng', () {
      // Arrange
      const key = Key('test_key');

      // Act
      final profileView = ProfileView(key: key, authService: mockAuthService);

      // Assert
      expect(profileView.key, equals(key));
    });

    test('ProfileView có widget type đúng', () {
      // Arrange
      final profileView = ProfileView(authService: mockAuthService);

      // Assert
      expect(profileView, isA<StatefulWidget>());
    });
  });
}
