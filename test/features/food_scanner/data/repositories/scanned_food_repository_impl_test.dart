import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/food_scanner/data/repositories/scanned_food_repository_impl.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/entities/scanned_food_entity.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/entities/food_record_entity.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/repositories/food_record_repository.dart';
import 'package:diet_tracking_project/services/cloudinary_service.dart';

class FakeCloudinaryService implements CloudinaryService {
  FakeCloudinaryService({required this.uploadResult});

  final String uploadResult;
  File? lastUploaded;

  @override
  String get cloudName => 'fake';

  @override
  String get uploadPreset => 'fake';

  @override
  String? get apiKey => null;

  @override
  Future<String> uploadImage(File imageFile) async {
    lastUploaded = imageFile;
    return uploadResult;
  }
}

class FakeFoodRecordRepository implements FoodRecordRepository {
  FoodRecordEntity? lastSaved;

  @override
  Future<void> saveFoodRecord(FoodRecordEntity foodRecord) async {
    lastSaved = foodRecord;
  }

  @override
  Future<List<FoodRecordEntity>> getFoodRecords() {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFoodRecord(String id) {
    throw UnimplementedError();
  }
}

void main() {
  group('ScannedFoodRepositoryImpl', () {
    test('uploads local file to Cloudinary and saves FoodRecordEntity', () async {
      final cloudinary = FakeCloudinaryService(
        uploadResult: 'https://cdn.example.com/img.jpg',
      );
      final records = FakeFoodRecordRepository();

      final repo = ScannedFoodRepositoryImpl(
        cloudinaryService: cloudinary,
        foodRecordRepository: records,
      );

      final tmpDir = await Directory.systemTemp.createTemp('food_scanner_test_');
      final file = File('${tmpDir.path}/img.jpg');
      await file.writeAsBytes([1, 2, 3]);

      final entity = ScannedFoodEntity(
        id: '1',
        imagePath: file.path,
        scanType: ScanType.food,
        scanDate: DateTime(2025, 1, 1),
        foodName: 'Apple',
        calories: 10,
        description: 'desc',
        protein: 1,
        carbs: 2,
        fat: 3,
      );

      await repo.saveScannedFood(entity);

      expect(cloudinary.lastUploaded?.path, file.path);

      final saved = records.lastSaved;
      expect(saved, isNotNull);
      expect(saved!, isA<FoodRecordEntity>());
      expect(saved.imagePath, 'https://cdn.example.com/img.jpg');
      expect(saved.foodName, 'Apple');
      expect(saved.calories, 10);
      expect(saved.recordType, RecordType.food);
      expect(saved.nutritionDetails, 'desc');
      expect(saved.protein, 1);
      expect(saved.carbs, 2);
      expect(saved.fat, 3);
    });

    test('does not upload if imagePath is already a URL', () async {
      final cloudinary = FakeCloudinaryService(uploadResult: 'unused');
      final records = FakeFoodRecordRepository();

      final repo = ScannedFoodRepositoryImpl(
        cloudinaryService: cloudinary,
        foodRecordRepository: records,
      );

      final entity = ScannedFoodEntity(
        id: '1',
        imagePath: 'https://example.com/img.jpg',
        scanType: ScanType.barcode,
        scanDate: DateTime(2025, 1, 1),
        foodName: 'P',
        calories: 1,
        barcode: '123',
      );

      await repo.saveScannedFood(entity);

      expect(cloudinary.lastUploaded, isNull);

      final saved = records.lastSaved;
      expect(saved, isNotNull);
      final savedRecord = saved!;
      expect(savedRecord.imagePath, 'https://example.com/img.jpg');
      expect(savedRecord.recordType, RecordType.barcode);
      expect(savedRecord.barcode, '123');
    });

    test('sets imagePath empty when local file does not exist', () async {
      final cloudinary = FakeCloudinaryService(uploadResult: 'unused');
      final records = FakeFoodRecordRepository();

      final repo = ScannedFoodRepositoryImpl(
        cloudinaryService: cloudinary,
        foodRecordRepository: records,
      );

      final entity = ScannedFoodEntity(
        id: '1',
        imagePath: 'C:/definitely-not-exists/404.jpg',
        scanType: ScanType.food,
        scanDate: DateTime(2025, 1, 1),
        foodName: 'X',
        calories: 0,
      );

      await repo.saveScannedFood(entity);

      expect(cloudinary.lastUploaded, isNull);

      final saved = records.lastSaved;
      expect(saved, isNotNull);
      expect(saved!.imagePath, '');
    });
  });
}
