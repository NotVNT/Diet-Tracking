import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:diet_tracking_project/features/food_scanner/domain/usecases/request_camera_permission.dart';
import 'package:diet_tracking_project/services/permission_service.dart';

class FakeCameraPermissionService implements PermissionService {
  ph.PermissionStatus status = ph.PermissionStatus.denied;
  ph.PermissionStatus requested = ph.PermissionStatus.denied;

  @override
  Future<ph.PermissionStatus> getCameraPermissionStatus() async => status;

  @override
  Future<ph.PermissionStatus> requestCameraPermissionStatus({bool useSessionCache = false}) async => requested;

  @override
  Future<bool> requestCameraPermission() async {
    final s = await requestCameraPermissionStatus();
    return s == ph.PermissionStatus.granted || s == ph.PermissionStatus.limited;
  }

  @override
  Future<bool> isCameraPermissionGranted() async {
    final s = await getCameraPermissionStatus();
    return s == ph.PermissionStatus.granted || s == ph.PermissionStatus.limited;
  }

  @override
  Future<bool> openAppSettings() async => false;

  @override
  void resetSessionState() {}

  @override
  Map<String, bool> getSessionState() => const {
        'cameraPermissionGrantedInSession': false,
        'cameraPermissionDeniedInSession': false,
      };

  // Unused by these tests
  @override
  Future<bool> requestNotificationPermission() async => false;

  @override
  Future<bool> isNotificationPermissionGranted() async => false;

  @override
  Future<bool> requestMicrophonePermission() async => false;

  @override
  Future<ph.PermissionStatus> requestMicrophonePermissionStatus() async => ph.PermissionStatus.denied;
}

void main() {
  group('RequestCameraPermission', () {
    test('returns granted when already granted', () async {
      final service = FakeCameraPermissionService();
      final usecase = RequestCameraPermission(service);

      service.status = ph.PermissionStatus.granted;

      final result = await usecase();

      expect(result.hasPermission, isTrue);
      expect(result.isPermanentlyDenied, isFalse);
      expect(result.errorMessage, isNull);
    });

    test('returns permanently denied result when permanently denied', () async {
      final service = FakeCameraPermissionService();
      final usecase = RequestCameraPermission(service);

      service.status = ph.PermissionStatus.permanentlyDenied;

      final result = await usecase();

      expect(result.hasPermission, isFalse);
      expect(result.isPermanentlyDenied, isTrue);
      expect(result.errorMessage, isNotEmpty);
    });

    test('requests permission when denied and returns granted if user accepts', () async {
      final service = FakeCameraPermissionService();
      final usecase = RequestCameraPermission(service);

      service.status = ph.PermissionStatus.denied;
      service.requested = ph.PermissionStatus.granted;

      final result = await usecase();

      expect(result.hasPermission, isTrue);
      expect(result.isPermanentlyDenied, isFalse);
    });

    test('requests permission when denied and returns permanently denied if user permanently denies', () async {
      final service = FakeCameraPermissionService();
      final usecase = RequestCameraPermission(service);

      service.status = ph.PermissionStatus.denied;
      service.requested = ph.PermissionStatus.permanentlyDenied;

      final result = await usecase();

      expect(result.hasPermission, isFalse);
      expect(result.isPermanentlyDenied, isTrue);
      expect(result.errorMessage, isNotEmpty);
    });

    test('requests permission when denied and returns denied result if user denies', () async {
      final service = FakeCameraPermissionService();
      final usecase = RequestCameraPermission(service);

      service.status = ph.PermissionStatus.denied;
      service.requested = ph.PermissionStatus.denied;

      final result = await usecase();

      expect(result.hasPermission, isFalse);
      expect(result.isPermanentlyDenied, isFalse);
      expect(result.errorMessage, isNotEmpty);
    });
  });
}
