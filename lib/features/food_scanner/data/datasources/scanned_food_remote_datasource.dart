import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/scanned_food_entity.dart';
import '../models/scanned_food_model.dart';

/// Remote datasource that stores scanned food photos under the current user's document.
class ScannedFoodRemoteDataSource {
  static const String _usersCollection = 'users';
  static const String _dietField = 'diet';

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final int maxStoredItems;

  ScannedFoodRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    this.maxStoredItems = 24,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> _requireUid() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User must be logged in to use the scanner feature.');
    }
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection(_usersCollection).doc(uid);
  }

  Future<void> saveScannedFood(ScannedFoodModel food) async {
    final uid = await _requireUid();
    final docRef = _userDoc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final existing = _readDietUrls(snapshot.data());

      existing.removeWhere((url) => url == food.imagePath);
      existing.insert(0, food.imagePath);

      if (existing.length > maxStoredItems) {
        existing.removeRange(maxStoredItems, existing.length);
      }

      transaction.set(docRef, {_dietField: existing}, SetOptions(merge: true));
    });
  }

  Future<List<ScannedFoodModel>> getAllScannedFoods() async {
    final uid = await _requireUid();
    final snapshot = await _userDoc(uid).get();
    return _readDietModels(snapshot.data());
  }

  Future<List<ScannedFoodModel>> getRecentScannedFoods({int limit = 10}) async {
    final models = await getAllScannedFoods();
    return models.take(limit).toList();
  }

  Future<void> deleteScannedFood(String id) async {
    final uid = await _requireUid();
    final docRef = _userDoc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final rawList = _rawDietList(snapshot.data());
      final filtered = <String>[];

      for (final entry in rawList) {
        final url = _extractImageUrl(entry);
        if (url == null) continue;
        final entryId = _extractId(entry);
        if (entryId == id || url == id) {
          continue;
        }
        if (!filtered.contains(url)) {
          filtered.add(url);
        }
      }

      transaction.set(docRef, {_dietField: filtered}, SetOptions(merge: true));
    });
  }

  Future<void> clearAllScannedFoods() async {
    final uid = await _requireUid();
    await _userDoc(uid).set({_dietField: []}, SetOptions(merge: true));
  }

  Future<void> markAsProcessed(String id) async {
    final uid = await _requireUid();
    final docRef = _userDoc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final rawList = _rawDietList(snapshot.data());
      bool updated = false;

      final nextList = rawList.map((entry) {
        if (entry is Map<String, dynamic> && entry['id'] == id) {
          updated = true;
          return {...entry, 'isProcessed': true};
        }
        return entry;
      }).toList();

      if (updated) {
        transaction.set(docRef, {
          _dietField: nextList,
        }, SetOptions(merge: true));
      }
    });
  }

  List<dynamic> _rawDietList(Map<String, dynamic>? rawData) {
    if (rawData == null) return <dynamic>[];
    final dynamic rawList = rawData[_dietField];
    if (rawList is! List) return <dynamic>[];
    return List<dynamic>.from(rawList);
  }

  List<String> _readDietUrls(Map<String, dynamic>? rawData) {
    final rawList = _rawDietList(rawData);
    return _normalizeDietUrls(rawList);
  }

  List<String> _normalizeDietUrls(List<dynamic> rawList) {
    final urls = <String>[];
    final seen = <String>{};
    for (final entry in rawList) {
      final url = _extractImageUrl(entry);
      if (url != null && seen.add(url)) {
        urls.add(url);
      }
    }
    return urls;
  }

  List<ScannedFoodModel> _readDietModels(Map<String, dynamic>? rawData) {
    final rawList = _rawDietList(rawData);
    final models = <ScannedFoodModel>[];
    for (var i = 0; i < rawList.length; i++) {
      final model = _modelFromEntry(rawList[i], i);
      if (model != null) {
        models.add(model);
      }
    }
    return models;
  }

  ScannedFoodModel? _modelFromEntry(dynamic entry, int index) {
    if (entry is Map) {
      final map = Map<String, dynamic>.from(entry.cast<String, dynamic>());
      return ScannedFoodModel.fromJson(map);
    }

    final url = _extractImageUrl(entry);
    if (url == null) return null;

    return ScannedFoodModel(
      id: url,
      imagePath: url,
      scanType: ScanType.food,
      scanDate: DateTime.now().subtract(Duration(minutes: index)),
      isProcessed: false,
    );
  }

  String? _extractImageUrl(dynamic entry) {
    if (entry is String) return entry;
    if (entry is Map) {
      final map = Map<String, dynamic>.from(entry.cast<String, dynamic>());
      final imagePath = map['imagePath'] ?? map['imageUrl'];
      if (imagePath is String && imagePath.isNotEmpty) {
        return imagePath;
      }
    }
    return null;
  }

  String? _extractId(dynamic entry) {
    if (entry is Map) {
      final map = Map<String, dynamic>.from(entry.cast<String, dynamic>());
      final id = map['id'];
      if (id is String) {
        return id;
      }
    }
    if (entry is String) {
      return entry;
    }
    return null;
  }
}
