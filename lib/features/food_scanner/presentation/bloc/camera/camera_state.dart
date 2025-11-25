import 'package:camera/camera.dart';

abstract class CameraState {
  const CameraState();
}

class CameraInitial extends CameraState {
  const CameraInitial();
}

class CameraInitializing extends CameraState {
  final bool isInitializing;
  const CameraInitializing({required this.isInitializing});
}

class CameraReady extends CameraState {
  final CameraController controller;
  const CameraReady({required this.controller});
}

class CameraError extends CameraState {
  final String errorMessage;
  const CameraError({required this.errorMessage});
}

class CameraStreamingState extends CameraState {
  final bool isStreaming;
  const CameraStreamingState({required this.isStreaming});
}

// Emitted for each frame while streaming
class CameraFrameAvailable extends CameraState {
  final CameraImage image;
  const CameraFrameAvailable(this.image);
}
