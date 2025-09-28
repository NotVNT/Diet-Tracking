import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/database/exceptions.dart';

void main() {
  group('Exceptions', () {
    test('AuthException toString', () {
      const ex = AuthException('Loi auth', 'code-x');
      expect(ex.toString(), contains('AuthException'));
      expect(ex.message, 'Loi auth');
      expect(ex.code, 'code-x');
    });

    test('FirestoreException toString', () {
      const ex = FirestoreException('Loi firestore', 'f-code');
      expect(ex.toString(), contains('FirestoreException'));
      expect(ex.message, 'Loi firestore');
      expect(ex.code, 'f-code');
    });

    test('NetworkException toString', () {
      const ex = NetworkException('Loi network');
      expect(ex.toString(), contains('NetworkException'));
      expect(ex.message, 'Loi network');
    });
  });
}

