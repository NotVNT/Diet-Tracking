import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/food_record_entity.dart';
import '../../domain/repositories/food_record_repository.dart';
import '../models/food_record_model.dart';
import '../../../../database/local_storage_service.dart';

class FoodRecordRepositoryImpl implements FoodRecordRepository {
  final LocalStorageService _localStorageService;
  final FirebaseFirestore _firestore;

  FoodRecordRepositoryImpl(
    this._localStorageService, {
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _key = 'food_records';

  List<dynamic> _coerceToJsonList(dynamic data) {
    if (data == null) return <dynamic>[];
    if (data is List) return data;
    if (data is String) {
      final s = data.trim();
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) return decoded;
        // if decoded is a map wrap into list
        if (decoded is Map<String, dynamic>) return [decoded];
      } catch (_) {
        // swallow and fallback
      }
    }
    // Unknown format -> return empty
    return <dynamic>[];
  }

  Future<void> _saveToFirestore(FoodRecordModel model) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // chưa đăng nhập thì bỏ qua Firestore
    final uid = user.uid;
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('food_records')
        .doc(model.id);
    await docRef.set(model.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> saveFoodRecord(FoodRecordEntity foodRecord) async {
    final model = FoodRecordModel.fromEntity(foodRecord);

    // Read existing data robustly (handles legacy string storage)
    final raw = await _localStorageService.getData(_key);
    final currentList = _coerceToJsonList(raw)
        .map(
          (e) => FoodRecordModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    final updatedRecords = [...currentList, model];

    final jsonList = updatedRecords
        .map((record) => FoodRecordModel.fromEntity(record).toJson())
        .toList();

    await _localStorageService.saveData(_key, jsonList);

    // Save to Firestore in parallel (best-effort)
    try {
      await _saveToFirestore(model);
    } catch (_) {
      // Không chặn luồng nếu Firestore lỗi
    }
  }

  @override
  Future<List<FoodRecordEntity>> getFoodRecords() async {
    final data = await _localStorageService.getData(_key);
    final list = _coerceToJsonList(data);
    return list
        .where((e) => e is Map)
        .map(
          (json) =>
              FoodRecordModel.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }

  @override
  Future<void> deleteFoodRecord(String id) async {
    final records = await getFoodRecords();
    final updatedRecords = records.where((record) => record.id != id).toList();

    final jsonList = updatedRecords
        .map((record) => FoodRecordModel.fromEntity(record).toJson())
        .toList();

    await _localStorageService.saveData(_key, jsonList);

    // Xóa trên Firestore nếu có đăng nhập
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('food_records')
          .doc(id)
          .delete()
          .catchError((_) {});
    }
  }
}
