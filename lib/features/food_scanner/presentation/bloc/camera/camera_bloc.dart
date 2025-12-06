import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../../../domain/usecases/request_camera_permission.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final RequestCameraPermission requestPermission;
  CameraController? _controller;

  CameraBloc({required this.requestPermission}) : super(const CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<StartImageStream>(_onStartImageStream);
    on<StopImageStream>(_onStopImageStream);
    on<ReleaseCamera>(_onReleaseCamera);
    on<CameraImageCaptured>(_onCameraImageCaptured);
  }

  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    emit(const CameraInitializing(isInitializing: true));

    try {
      final permission = await requestPermission();
      if (!permission.hasPermission) {
        emit(
          CameraError(
            errorMessage: permission.errorMessage ?? 'Camera permission denied',
          ),
        );
        emit(const CameraInitializing(isInitializing: false));
        return;
      }

      // Dispose previous controller if any
      final previous = _controller;
      if (previous != null) {
        await previous.dispose();
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(const CameraError(errorMessage: 'No camera found on device.'));
        emit(const CameraInitializing(isInitializing: false));
        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      await controller.initialize();

      _controller = controller;
      emit(CameraReady(controller: controller));
    } on CameraException catch (e) {
      emit(CameraError(errorMessage: e.description ?? e.code));
      emit(const CameraInitializing(isInitializing: false));
    } catch (e) {
      emit(CameraError(errorMessage: e.toString()));
      emit(const CameraInitializing(isInitializing: false));
    }
  }

  Future<void> _onStartImageStream(
    StartImageStream event,
    Emitter<CameraState> emit,
  ) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isStreamingImages) return;

    emit(const CameraStreamingState(isStreaming: true));
    await controller.startImageStream((CameraImage image) {
      add(CameraImageCaptured(image));
    });
  }

  Future<void> _onStopImageStream(
    StopImageStream event,
    Emitter<CameraState> emit,
  ) async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    // After stopping the stream, expose a ready state so the UI can take photos again
    emit(CameraReady(controller: controller));
  }

  Future<void> _onReleaseCamera(
    ReleaseCamera event,
    Emitter<CameraState> emit,
  ) async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      try {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
      } catch (_) {}
      try {
        await controller.dispose();
      } catch (_) {}
    }
    emit(const CameraInitial());
  }

  Future<void> _onCameraImageCaptured(
    CameraImageCaptured event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraFrameAvailable(event.image));
  }

  CameraController? get controller => _controller;

  @override
  Future<void> close() async {
    try {
      final c = _controller;
      _controller = null;
      if (c != null) {
        if (c.value.isStreamingImages) {
          await c.stopImageStream();
        }
        await c.dispose();
      }
    } finally {
      await super.close();
    }
  }
}
