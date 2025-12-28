import 'dart:async';
import 'package:diet_tracking_project/features/food_scanner/data/models/food_scanner_models.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_event.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_state.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_bloc.dart'
    as cam;
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_event.dart'
    as cam_event;
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_state.dart'
    as cam_state;
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_event.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_state.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/common/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ScannerController {
  final BuildContext context;
  final FoodScanBloc foodScanBloc;
  final BarcodeBloc barcodeBloc;
  final cam.CameraBloc cameraBloc;

  String? _pendingImagePath;

  ScannerController(this.context)
    : foodScanBloc = context.read<FoodScanBloc>(),
      barcodeBloc = context.read<BarcodeBloc>(),
      cameraBloc = context.read<cam.CameraBloc>();

  void onActionSelected(ScannerActionType type) {
    // Barcode mode uses mobile_scanner which needs exclusive camera access.
    // Release CameraController to avoid conflicts. For food mode, (re)initialize.
    if (type == ScannerActionType.barcode) {
      cameraBloc.add(const cam_event.ReleaseCamera());
    } else if (type == ScannerActionType.food) {
      cameraBloc.add(const cam_event.InitializeCamera());
    }

    if (type == ScannerActionType.gallery) {
      _openGallery();
    }
  }

  Future<void> onCapturePressed() async {
    final cameraState = cameraBloc.state;
    if (cameraState is! cam_state.CameraReady) {
      SnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.foodScannerCantCapturePhoto,
      );
      return;
    }

    try {
      final photo = await cameraState.controller.takePicture();
      foodScanBloc.add(FoodScanRequested(imagePath: photo.path));
    } catch (e) {
      if (!context.mounted) return;
      SnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.foodScannerCantCapturePhoto,
      );
    }
  }

  void handleFoodScanState(BuildContext context, FoodScanState state) {
    if (state is FoodScanSuccess) {
      final l10n = AppLocalizations.of(context)!;
      SnackBarHelper.showSuccess(context, l10n.foodScannerSavePhotoSuccess);
      _popAfterShortDelay();
    } else if (state is FoodScanError) {
      SnackBarHelper.showError(context, state.message);
      _popAfterShortDelay();
    }
  }

  void handleBarcodeState(BuildContext context, BarcodeState state) async {
    if (state is BarcodeSavedSuccess) {
      SnackBarHelper.showSuccess(context, state.message);
      _popAfterShortDelay();
    } else if (state is BarcodeNoBarcodeFound) {
      final l10n = AppLocalizations.of(context)!;
      SnackBarHelper.showInfo(context, l10n.foodScannerNoBarcodeFoundSaving);
      foodScanBloc.add(FoodScanRequested(imagePath: state.imagePath));
    } else if (state is BarcodeError) {
      SnackBarHelper.showError(context, state.message);
      final path = _pendingImagePath;
      if (path != null) {
        foodScanBloc.add(FoodScanRequested(imagePath: path));
        _pendingImagePath = null;
      }
    } else if (state is BarcodeValueDetected) {
      // When a barcode value is detected from the live stream, stop the stream
      // and take a high-resolution picture to attach to the saved record.
      final controller = cameraBloc.controller;
      if (controller == null || !controller.state.isInitialized) return;

      try {
        if (controller.state.isStreamingImages) {
          // Stop stream safely before taking a picture
          try {
            await controller.stopImageStream();
          } catch (_) {}
          // Also update bloc state
          cameraBloc.add(const cam_event.StopImageStream());
          // Give the camera a brief moment to settle
          await Future.delayed(const Duration(milliseconds: 100));
        }

        final photo = await controller.takePicture();
        _pendingImagePath = photo.path;
        barcodeBloc.add(
          BarcodeDetectedAndImageCaptured(state.barcodeValue, photo.path),
        );
      } catch (e) {
        if (!context.mounted) return;
        SnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.foodScannerCantCapturePhoto,
        );
      }
    }
  }

  void handleCameraState(
    BuildContext context,
    cam_state.CameraState state,
  ) async {
    if (state is cam_state.CameraError) {
      SnackBarHelper.showError(context, state.errorMessage);
      _popAfterShortDelay(canPop: true);
    } else if (state is cam_state.CameraFrameAvailable) {
      // Barcode realtime is handled by mobile_scanner, not camera frames.
      // Keep for potential future streaming use cases (e.g., food analysis).
    }
  }

  // Invoked by MobileBarcodeScannerView when a barcode is detected
  void onMobileBarcodeDetected(String value) {
    barcodeBloc.add(BarcodeSelected(value));
  }

  Future<void> _openGallery() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    _pendingImagePath = picked.path;
    barcodeBloc.add(BarcodeScanFromImageRequested(picked.path));
  }

  void _popAfterShortDelay({bool canPop = false}) {
    final navigator = Navigator.of(context);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!context.mounted) return;
      if (navigator.canPop()) {
        navigator.pop();
      }
    });
  }
}
