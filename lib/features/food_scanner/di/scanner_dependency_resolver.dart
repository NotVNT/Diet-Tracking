import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_bloc.dart' as cam;
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/services/barcode_scanner_service.dart' as barcode_service;
import 'food_scanner_injector.dart';
import 'food_scanner_locator.dart';

class ScannerDependencies {
  final FoodScanBloc foodScanBloc;
  final BarcodeBloc barcodeBloc;
  final cam.CameraBloc cameraBloc;
  final barcode_service.IBarcodeScannerService barcodeScannerService;
  final bool ownsDependencies;

  ScannerDependencies({
    required this.foodScanBloc,
    required this.barcodeBloc,
    required this.cameraBloc,
    required this.barcodeScannerService,
    required this.ownsDependencies,
  });

  void dispose() {
    if (ownsDependencies) {
      cameraBloc.close();
      foodScanBloc.close();
      barcodeBloc.close();
      barcodeScannerService.dispose();
    }
  }
}

class ScannerDependencyResolver {
  final FoodScannerInjector? injector;

  ScannerDependencyResolver({this.injector});

  ScannerDependencies resolve() {
    if (FoodScannerLocator.isInitialized) {
      return ScannerDependencies(
        foodScanBloc: FoodScannerLocator.I<FoodScanBloc>(),
        barcodeBloc: FoodScannerLocator.I<BarcodeBloc>(),
        cameraBloc: FoodScannerLocator.I<cam.CameraBloc>(),
        barcodeScannerService: FoodScannerLocator.I<barcode_service.BarcodeScannerService>(),
        ownsDependencies: false,
      );
    }

    final effectiveInjector = injector ?? FoodScannerInjector();
    final deps = effectiveInjector.create();
    return ScannerDependencies(
      foodScanBloc: deps.foodScanBloc,
      barcodeBloc: deps.barcodeBloc,
      cameraBloc: deps.cameraBloc,
      barcodeScannerService: deps.barcodeScannerService,
      ownsDependencies: true,
    );
  }
}


