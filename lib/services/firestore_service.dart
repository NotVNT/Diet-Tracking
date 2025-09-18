import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    final Map<String, dynamic> payload = {
      ...data,
      'uid': uid,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!data.containsKey('createdAt'))
        'createdAt': FieldValue.serverTimestamp(),
    };
    await _usersCol.doc(uid).set(payload, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    return doc.data();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    final Map<String, dynamic> payload = {
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _usersCol.doc(uid).update(payload);
  }
}
