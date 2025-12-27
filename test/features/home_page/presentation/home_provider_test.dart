import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/features/home_page/domain/entities/home_info.dart';
import 'package:diet_tracking_project/features/home_page/presentation/providers/home_provider.dart';

import '../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> flushAsync([int times = 6]) async {
    for (var i = 0; i < times; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('HomeProvider', () {
    test('initializes by loading HomeInfo and notifies listeners', () async {
      final usecase = MockGetHomeInfoUseCase();
      final repo = MockHomeRepository();
      final permission = MockPermissionService();
      final notifications = MockLocalNotificationService();

      when(usecase()).thenAnswer((_) async => HomeInfo(currentIndex: 1));
      when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => true);

      var notifyCount = 0;
      final provider = HomeProvider(
        getHomeInfoUseCase: usecase,
        repository: repo,
        permissionService: permission,
        notificationService: notifications,
      )..addListener(() => notifyCount++);

      // Allow async constructor init to complete.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(provider.currentIndex, 1);
      expect(notifyCount, greaterThanOrEqualTo(1));

      verify(usecase()).called(1);
    });

    test('setCurrentIndex updates repository and notifies', () async {
      final usecase = MockGetHomeInfoUseCase();
      final repo = MockHomeRepository();
      final permission = MockPermissionService();
      final notifications = MockLocalNotificationService();

      when(usecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
      when(repo.updateCurrentIndex(3)).thenAnswer((_) async {});
      when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => true);

      var notified = 0;
      final provider = HomeProvider(
        getHomeInfoUseCase: usecase,
        repository: repo,
        permissionService: permission,
        notificationService: notifications,
      )..addListener(() => notified++);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      await provider.setCurrentIndex(3);

      expect(provider.currentIndex, 3);
      verify(repo.updateCurrentIndex(3)).called(1);
      expect(notified, greaterThanOrEqualTo(1));
    });

    test('ensureNotificationPermissionAndWelcome shows welcome once', () async {
      final usecase = MockGetHomeInfoUseCase();
      final repo = MockHomeRepository();
      final permission = MockPermissionService();
      final notifications = MockLocalNotificationService();

      when(usecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
      when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => false);
      when(permission.requestNotificationPermission()).thenAnswer((_) async => true);
      when(notifications.showSimpleNotification(title: anyNamed('title'), body: anyNamed('body')))
          .thenAnswer((_) async {});

      final provider = HomeProvider(
        getHomeInfoUseCase: usecase,
        repository: repo,
        permissionService: permission,
        notificationService: notifications,
      );

      await flushAsync();

      // First call: should show
      await provider.ensureNotificationPermissionAndWelcome();
      verify(notifications.showSimpleNotification(title: anyNamed('title'), body: anyNamed('body')))
          .called(1);

      // Second call: should not show again
      await provider.ensureNotificationPermissionAndWelcome();
      verifyNoMoreInteractions(notifications);
    });

    test('ensureNotificationPermissionAndWelcome: permission already granted shows once and sets pref', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final usecase = MockGetHomeInfoUseCase();
      final repo = MockHomeRepository();
      final permission = MockPermissionService();
      final notifications = MockLocalNotificationService();

      when(usecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
      when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => true);
      when(notifications.showSimpleNotification(title: anyNamed('title'), body: anyNamed('body')))
          .thenAnswer((_) async {});

      // Constructor init should trigger it once.
      final provider = HomeProvider(
        getHomeInfoUseCase: usecase,
        repository: repo,
        permissionService: permission,
        notificationService: notifications,
      );

      await flushAsync();

      verify(notifications.showSimpleNotification(title: anyNamed('title'), body: anyNamed('body')))
          .called(1);

      // Calling again should not show again.
      await provider.ensureNotificationPermissionAndWelcome();
      verifyNoMoreInteractions(notifications);
    });

    test('ensureNotificationPermissionAndWelcome: permission denied does not show notification', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final usecase = MockGetHomeInfoUseCase();
      final repo = MockHomeRepository();
      final permission = MockPermissionService();
      final notifications = MockLocalNotificationService();

      when(usecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
      when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => false);
      when(permission.requestNotificationPermission()).thenAnswer((_) async => false);

      final provider = HomeProvider(
        getHomeInfoUseCase: usecase,
        repository: repo,
        permissionService: permission,
        notificationService: notifications,
      );

      await flushAsync();

      verifyNever(notifications.showSimpleNotification(title: anyNamed('title'), body: anyNamed('body')));

      // Even explicit calls should remain no-op for notifications.
      await provider.ensureNotificationPermissionAndWelcome();
      verifyNever(notifications.showSimpleNotification(title: anyNamed('title'), body: anyNamed('body')));
    });

    test('ensureNotificationPermissionAndWelcome: already shown in prefs never shows again', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'notification_welcome_shown_v1': true,
      });

      final usecase = MockGetHomeInfoUseCase();
      final repo = MockHomeRepository();
      final permission = MockPermissionService();
      final notifications = MockLocalNotificationService();

      when(usecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
      when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => true);

      final provider = HomeProvider(
        getHomeInfoUseCase: usecase,
        repository: repo,
        permissionService: permission,
        notificationService: notifications,
      );

      await flushAsync();

      verifyNever(notifications.showSimpleNotification(title: anyNamed('title'), body: anyNamed('body')));

      await provider.ensureNotificationPermissionAndWelcome();
      verifyNever(notifications.showSimpleNotification(title: anyNamed('title'), body: anyNamed('body')));
    });
  });
}
