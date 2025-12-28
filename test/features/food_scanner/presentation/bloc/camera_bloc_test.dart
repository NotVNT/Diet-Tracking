import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:camera/camera.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/request_camera_permission.dart';
import 'package:diet_tracking_project/features/food_scanner/services/camera_permission_service.dart';
import 'package:diet_tracking_project/features/food_scanner/services/camera_adapter.dart';
import 'package:diet_tracking_project/features/food_scanner/services/camera_controller_facade.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_event.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_state.dart';

class FakeCameraPermissionService implements CameraPermissionService {
  ph.PermissionStatus status;
  ph.PermissionStatus requested;

  FakeCameraPermissionService({
    required this.status,
    required this.requested,
  });

  @override
  Future<ph.PermissionStatus> getCameraPermissionStatus() async => status;

  @override
  Future<ph.PermissionStatus> requestCameraPermissionStatus() async => requested;

  @override
  Future<bool> requestCameraPermission() async {
    final s = await requestCameraPermissionStatus();
    return s == ph.PermissionStatus.granted || s == ph.PermissionStatus.limited;
  }

  @override
  Future<bool> isCameraPermissionGranted() async {
    final s = await getCameraPermissionStatus();
    return s == ph.PermissionStatus.granted || s == ph.PermissionStatus.limited;
  }

  @override
  Future<bool> openAppSettings() async => false;

  @override
  void resetSessionState() {}

  @override
  Map<String, bool> getSessionState() => const {
        'cameraPermissionGrantedInSession': false,
        'cameraPermissionDeniedInSession': false,
      };
}

class FakeCameraAdapter extends CameraAdapter {
  final List<CameraDescription> cameras;
  final Object? error;
  final CameraControllerFacade? controller;

  const FakeCameraAdapter({
    this.cameras = const [],
    this.error,
    this.controller,
  });

  @override
  Future<List<CameraDescription>> availableCameras() async {
    final e = error;
    if (e != null) throw e;
    return cameras;
  }

  @override
  CameraControllerFacade createController(
    CameraDescription description,
    ResolutionPreset resolutionPreset, {
    required bool enableAudio,
  }) {
    final c = controller;
    if (c == null) {
      throw UnimplementedError('No fake controller provided');
    }
    return c;
  }
}

class FakeCameraControllerFacade implements CameraControllerFacade {
  bool initialized;
  bool streaming;
  int startStreamCalls;
  int stopStreamCalls;

  FakeCameraControllerFacade({
    this.initialized = true,
    this.streaming = false,
    this.startStreamCalls = 0,
    this.stopStreamCalls = 0,
  });

  @override
  CameraController? get rawController => null;

  @override
  CameraControllerState get state => CameraControllerState(
        isInitialized: initialized,
        isStreamingImages: streaming,
        aspectRatio: 1.0,
      );

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> startImageStream(void Function(CameraImage image) onAvailable) async {
    startStreamCalls += 1;
    streaming = true;
  }

  @override
  Future<void> stopImageStream() async {
    stopStreamCalls += 1;
    streaming = false;
  }

  @override
  Future<XFile> takePicture() async {
    throw UnimplementedError('Not needed for these unit tests');
  }
}

void main() {
  group('CameraBloc (no real camera)', () {
    test('InitializeCamera emits initializing -> error -> initializing(false) when permission denied', () async {
      final service = FakeCameraPermissionService(
        status: ph.PermissionStatus.denied,
        requested: ph.PermissionStatus.denied,
      );
      final requestPermission = RequestCameraPermission(service);
      final bloc = CameraBloc(requestPermission: requestPermission);
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<CameraState>((s) => s is CameraInitializing && s.isInitializing == true),
          predicate<CameraState>((s) => s is CameraError && s.errorMessage.isNotEmpty),
          predicate<CameraState>((s) => s is CameraInitializing && s.isInitializing == false),
        ]),
      );

      bloc.add(const InitializeCamera());
      await states;
    });

    test('InitializeCamera emits no-camera error when permission granted but device has no cameras', () async {
      final service = FakeCameraPermissionService(
        status: ph.PermissionStatus.granted,
        requested: ph.PermissionStatus.granted,
      );
      final requestPermission = RequestCameraPermission(service);
      const adapter = FakeCameraAdapter(cameras: []);

      final bloc = CameraBloc(
        requestPermission: requestPermission,
        cameraAdapter: adapter,
      );
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<CameraState>((s) => s is CameraInitializing && s.isInitializing == true),
          predicate<CameraState>((s) => s is CameraError && s.errorMessage.contains('No camera found')),
          predicate<CameraState>((s) => s is CameraInitializing && s.isInitializing == false),
        ]),
      );

      bloc.add(const InitializeCamera());
      await states;
    });

    test('InitializeCamera success + Start/StopImageStream emits streaming then ready (with fake controller)', () async {
      final service = FakeCameraPermissionService(
        status: ph.PermissionStatus.granted,
        requested: ph.PermissionStatus.granted,
      );
      final requestPermission = RequestCameraPermission(service);
      final fakeController = FakeCameraControllerFacade();

      const desc = CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      );

      final adapter = FakeCameraAdapter(
        cameras: const [desc],
        controller: fakeController,
      );

      final bloc = CameraBloc(
        requestPermission: requestPermission,
        cameraAdapter: adapter,
      );
      addTearDown(bloc.close);

      // First: initialize camera and wait until ready.
      bloc.add(const InitializeCamera());
      await bloc.stream.firstWhere((s) => s is CameraReady);

      // Then: start and stop stream.
      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<CameraState>((s) => s is CameraStreamingState && s.isStreaming == true),
          isA<CameraReady>(),
        ]),
      );

      bloc.add(const StartImageStream());
      bloc.add(const StopImageStream());

      await states;
      expect(fakeController.startStreamCalls, 1);
      expect(fakeController.stopStreamCalls, 1);
    });

    test('InitializeCamera emits error when adapter throws', () async {
      final service = FakeCameraPermissionService(
        status: ph.PermissionStatus.granted,
        requested: ph.PermissionStatus.granted,
      );
      final requestPermission = RequestCameraPermission(service);
      final adapter = FakeCameraAdapter(error: StateError('boom'));

      final bloc = CameraBloc(
        requestPermission: requestPermission,
        cameraAdapter: adapter,
      );
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<CameraState>((s) => s is CameraInitializing && s.isInitializing == true),
          predicate<CameraState>((s) => s is CameraError && s.errorMessage.contains('boom')),
          predicate<CameraState>((s) => s is CameraInitializing && s.isInitializing == false),
        ]),
      );

      bloc.add(const InitializeCamera());
      await states;
    });

    test('InitializeCamera success emits CameraReady with same controller facade instance', () async {
      final service = FakeCameraPermissionService(
        status: ph.PermissionStatus.granted,
        requested: ph.PermissionStatus.granted,
      );
      final requestPermission = RequestCameraPermission(service);

      final fakeController = FakeCameraControllerFacade();
      const desc = CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      );

      final adapter = FakeCameraAdapter(
        cameras: const [desc],
        controller: fakeController,
      );

      final bloc = CameraBloc(
        requestPermission: requestPermission,
        cameraAdapter: adapter,
      );
      addTearDown(bloc.close);

      bloc.add(const InitializeCamera());
      final ready = await bloc.stream.firstWhere((s) => s is CameraReady) as CameraReady;

      expect(identical(ready.controller, fakeController), isTrue);
    });

    test('ReleaseCamera emits CameraInitial even when controller is null', () async {
      final service = FakeCameraPermissionService(
        status: ph.PermissionStatus.denied,
        requested: ph.PermissionStatus.denied,
      );
      final requestPermission = RequestCameraPermission(service);
      final bloc = CameraBloc(requestPermission: requestPermission);
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emits(isA<CameraInitial>()),
      );

      bloc.add(const ReleaseCamera());
      await states;
    });
  });
}
