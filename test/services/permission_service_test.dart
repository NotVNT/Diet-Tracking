import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/services/permission_service.dart';

void main() {
  group('PermissionService', () {
    test('factory returns singleton instance', () {
      final a = PermissionService();
      final b = PermissionService();
      expect(identical(a, b), isTrue);
    });

    test('methods exist (no platform invocation)', () async {
      // We do not call request/status methods to avoid platform channel deps.
      final svc = PermissionService();
      expect(svc.openAppSettings, isA<Function>());
    });
  });
}

