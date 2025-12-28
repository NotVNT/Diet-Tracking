import 'package:camera/camera.dart';

class CameraControllerState {
  final bool isInitialized;
  final bool isStreamingImages;
  final double aspectRatio;

  const CameraControllerState({
    required this.isInitialized,
    required this.isStreamingImages,
    required this.aspectRatio,
  });
}

abstract class CameraControllerFacade {
  CameraControllerState get state;

  /// Exposes the real controller for UI widgets like CameraPreview.
  /// In tests, this can be null.
  CameraController? get rawController;

  Future<void> initialize();

  Future<void> dispose();

  Future<void> startImageStream(void Function(CameraImage image) onAvailable);

  Future<void> stopImageStream();

  Future<XFile> takePicture();
}

class RealCameraControllerFacade implements CameraControllerFacade {
  final CameraController _controller;

  RealCameraControllerFacade(this._controller);

  @override
  CameraController? get rawController => _controller;

  @override
  CameraControllerState get state {
    final v = _controller.value;
    return CameraControllerState(
      isInitialized: v.isInitialized,
      isStreamingImages: v.isStreamingImages,
      aspectRatio: v.aspectRatio,
    );
  }

  @override
  Future<void> initialize() => _controller.initialize();

  @override
  Future<void> dispose() => _controller.dispose();

  @override
  Future<void> startImageStream(void Function(CameraImage image) onAvailable) {
    return _controller.startImageStream(onAvailable);
  }

  @override
  Future<void> stopImageStream() => _controller.stopImageStream();

  @override
  Future<XFile> takePicture() => _controller.takePicture();
}
