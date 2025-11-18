import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../domain/entities/scanned_food_entity.dart';
import '../../domain/repositories/scanned_food_repository.dart';
import '../datasources/scanned_food_local_datasource.dart';
import '../datasources/scanned_food_remote_datasource.dart';
import '../models/scanned_food_model.dart';
import '../../../../services/cloudinary_service.dart';

/// Implementation of ScannedFoodRepository
class ScannedFoodRepositoryImpl implements ScannedFoodRepository {
  final ScannedFoodLocalDataSource? localDataSource;
  final ScannedFoodRemoteDataSource remoteDataSource;
  final CloudinaryService cloudinaryService;

  ScannedFoodRepositoryImpl({
    ScannedFoodLocalDataSource? localDataSource,
    ScannedFoodRemoteDataSource? remoteDataSource,
    CloudinaryService? cloudinaryService,
  }) : localDataSource = localDataSource,
       remoteDataSource = remoteDataSource ?? ScannedFoodRemoteDataSource(),
       cloudinaryService = cloudinaryService ?? CloudinaryService.fromConfig();

  @override
  Future<void> saveScannedFood(ScannedFoodEntity food) async {
    final file = File(food.imagePath);
    if (!file.existsSync()) {
      throw StateError('Image file ${food.imagePath} was not found');
    }

    final uploadedUrl = await cloudinaryService.uploadImage(file);
    final remoteModel = ScannedFoodModel(
      id: uploadedUrl,
      imagePath: uploadedUrl,
      scanType: food.scanType,
      scanDate: food.scanDate,
      isProcessed: food.isProcessed,
    );

    await remoteDataSource.saveScannedFood(remoteModel);
    if (localDataSource != null) {
      await localDataSource!.saveScannedFood(remoteModel);
    }
  }

  @override
  Future<List<ScannedFoodEntity>> getAllScannedFoods() async {
    try {
      final remoteModels = await remoteDataSource.getAllScannedFoods();
      return remoteModels.cast<ScannedFoodEntity>();
    } catch (e, stackTrace) {
      debugPrint('Failed to fetch remote scanned foods: $e\n$stackTrace');
      if (localDataSource != null) {
        final localModels = await localDataSource!.getAllScannedFoods();
        return localModels.cast<ScannedFoodEntity>();
      }
      return [];
    }
  }

  @override
  Future<List<ScannedFoodEntity>> getRecentScannedFoods({
    int limit = 10,
  }) async {
    try {
      final models = await remoteDataSource.getRecentScannedFoods(limit: limit);
      return models.cast<ScannedFoodEntity>();
    } catch (e, stackTrace) {
      debugPrint('Failed to fetch remote recent foods: $e\n$stackTrace');
      if (localDataSource != null) {
        final models = await localDataSource!.getAllScannedFoods();
        return models.take(limit).cast<ScannedFoodEntity>().toList();
      }
      return [];
    }
  }

  @override
  Future<void> deleteScannedFood(String id) async {
    await remoteDataSource.deleteScannedFood(id);
    if (localDataSource != null) {
      await localDataSource!.deleteScannedFood(id);
    }
  }

  @override
  Future<void> clearAllScannedFoods() async {
    await remoteDataSource.clearAllScannedFoods();
    if (localDataSource != null) {
      await localDataSource!.clearAllScannedFoods();
    }
  }

  @override
  Future<void> markAsProcessed(String id) async {
    await remoteDataSource.markAsProcessed(id);
    if (localDataSource != null) {
      await localDataSource!.markAsProcessed(id);
    }
  }
}
