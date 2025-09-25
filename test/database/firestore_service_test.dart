import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:diet_tracking_project/database/firestore_service.dart';

void main() {
  group('FirestoreService', () {
    late FakeFirebaseFirestore firestore;
    late FirestoreService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = FirestoreService(firestore: firestore);
    });

    test('testConnection trả true khi get() không throw', () async {
      await firestore.collection('test').add({'ping': true});
      expect(await service.testConnection(), isTrue);
    });

    test('userExists trả về true khi doc.exists = true', () async {
      await firestore.collection('users').doc('uid').set({'name': 'A'});
      expect(await service.userExists('uid'), isTrue);
    });

    test('getUserById gọi đúng đường dẫn', () async {
      await firestore.collection('users').doc('abc').set({'x': 1});
      final res = await service.getUserById('abc');
      expect(res.exists, isTrue);
    });

    test('deleteUser gọi đúng doc.delete()', () async {
      await service.deleteUser('abc');
      final doc = await firestore.collection('users').doc('abc').get();
      expect(doc.exists, isFalse);
    });
  });
}
