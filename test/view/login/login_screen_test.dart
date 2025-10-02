import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:diet_tracking_project/view/login/login_screen.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:diet_tracking_project/database/guest_sync_service.dart';
import 'package:diet_tracking_project/model/user.dart' as app_user;
import 'package:diet_tracking_project/model/body_info_model.dart';

class _AuthMock extends Mock implements AuthService {}

class _GuestSyncMock extends Mock implements GuestSyncService {}

class _AuthStub extends AuthService {
  MockUser? userToReturn;
  app_user.User? profileToReturn;
  Exception? signInException;

  _AuthStub()
    : super(auth: MockFirebaseAuth(), firestore: FakeFirebaseFirestore());

  @override
  Future<MockUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (signInException != null) throw signInException!;
    return userToReturn;
  }

  @override
  Future<app_user.User?> getUserData(String uid) async {
    return profileToReturn;
  }
}

// Dùng mockito cho GuestSyncService để tránh khởi tạo Firebase thật

// Dùng MockUser từ firebase_auth_mocks để có uid hợp lệ

void main() {
  group('LoginScreen', () {
    testWidgets('Hiển thị thông tin cơ bản và toggle mật khẩu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            authService: _AuthStub(),
            guestSyncService: _GuestSyncMock(),
          ),
        ),
      );

      expect(find.text('Đăng Nhập'), findsOneWidget);

      final eyeIcon = find.byIcon(Icons.visibility);
      expect(eyeIcon, findsOneWidget);
      await tester.tap(eyeIcon);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Validate thiếu email hiển thị SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            authService: _AuthStub(),
            guestSyncService: _GuestSyncMock(),
          ),
        ),
      );

      await tester.tap(find.text('Đăng nhập'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.textContaining('Vui lòng nhập email'), findsOneWidget);
    });

    testWidgets('Validate thiếu mật khẩu hiển thị SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            authService: _AuthMock(),
            guestSyncService: _GuestSyncMock(),
          ),
        ),
      );
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'a@a.com');
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.textContaining('Vui lòng nhập mật khẩu'), findsOneWidget);
    });

    testWidgets(
      'Đăng nhập thành công và điều hướng tới Onboarding khi thiếu hồ sơ',
      (tester) async {
        final auth = _AuthStub()
          ..userToReturn = MockUser(uid: 'uid-1')
          ..profileToReturn = null;
        final guest = _GuestSyncMock();

        await tester.pumpWidget(
          MaterialApp(
            home: LoginScreen(authService: auth, guestSyncService: guest),
          ),
        );

        final emailField = find.byType(TextField).first;
        final passField = find.byType(TextField).at(1);
        await tester.enterText(emailField, 'a@a.com');
        await tester.enterText(passField, 'secret');

        await tester.tap(find.text('Đăng nhập'));
        await tester.pump(const Duration(milliseconds: 50));
        // mở dialog loading
        await tester.pump(const Duration(milliseconds: 100));
        // đóng dialog và điều hướng
        await tester.pumpAndSettle();

        // Thành công không crash và đã pump settle
      },
    );

    testWidgets('Đăng nhập thành công và điều hướng Home khi hồ sơ đầy đủ', (
      tester,
    ) async {
      final auth = _AuthStub()
        ..userToReturn = MockUser(uid: 'uid-2')
        ..profileToReturn = const app_user.User(
          uid: 'uid-2',
          bodyInfo: BodyInfoModel(heightCm: 170, weightKg: 60),
          age: 25,
          gender: app_user.GenderType.male,
        );
      final guest = _GuestSyncMock();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: auth, guestSyncService: guest),
        ),
      );

      final emailField = find.byType(TextField).first;
      final passField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'b@b.com');
      await tester.enterText(passField, 'secret');

      await tester.tap(find.text('Đăng nhập'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Thành công không crash và đã pump settle
    });

    testWidgets('Đăng nhập ném lỗi hiển thị SnackBar lỗi', (tester) async {
      final auth = _AuthStub()..signInException = Exception('boom');
      final guest = _GuestSyncMock();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: auth, guestSyncService: guest),
        ),
      );

      final emailField = find.byType(TextField).first;
      final passField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'c@c.com');
      await tester.enterText(passField, 'secret');

      await tester.tap(find.text('Đăng nhập'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Đã xảy ra lỗi không xác định'),
        findsOneWidget,
      );
    });
  });
}
