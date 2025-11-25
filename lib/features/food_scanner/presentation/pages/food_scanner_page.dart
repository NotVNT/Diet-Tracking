import 'package:diet_tracking_project/features/food_scanner/di/food_scanner_injector.dart';
import '../controller/scanner_controller.dart';
import 'package:diet_tracking_project/features/food_scanner/di/scanner_dependency_resolver.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/widgets/food_scanner_page_widget/scanner_view.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_state.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_bloc.dart' as cam;
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_state.dart' as cam_state;
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodScannerPage extends StatefulWidget {
  final FoodScannerInjector? injector;
  const FoodScannerPage({super.key, this.injector});

  @override
  State<FoodScannerPage> createState() => _FoodScannerPageState();
}

class _FoodScannerPageState extends State<FoodScannerPage> {
  late final ScannerDependencies _dependencies;
  late final ScannerController _controller;

  @override
  void initState() {
    super.initState();
    _dependencies = ScannerDependencyResolver(injector: widget.injector).resolve();
  }

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _dependencies.foodScanBloc),
        BlocProvider.value(value: _dependencies.barcodeBloc),
        BlocProvider.value(value: _dependencies.cameraBloc),
      ],
      child: Builder(builder: (context) {
        _controller = ScannerController(context);
        return MultiBlocListener(
          listeners: [
            BlocListener<FoodScanBloc, FoodScanState>(
              listener: _controller.handleFoodScanState,
            ),
            BlocListener<BarcodeBloc, BarcodeState>(
              listener: _controller.handleBarcodeState,
            ),
            BlocListener<cam.CameraBloc, cam_state.CameraState>(
              listener: _controller.handleCameraState,
            ),
          ],
          child: ScannerView(controller: _controller),
        );
      }),
    );
  }
}

