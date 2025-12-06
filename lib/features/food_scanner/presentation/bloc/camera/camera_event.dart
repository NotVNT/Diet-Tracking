import 'package:camera/camera.dart';

abstract class CameraEvent {
  const CameraEvent();
}

class InitializeCamera extends CameraEvent {
  const InitializeCamera();
}

class StartImageStream extends CameraEvent {
  const StartImageStream();
}

class StopImageStream extends CameraEvent {
  const StopImageStream();
}

/// Release/Dispose the camera controller to free camera resource
class ReleaseCamera extends CameraEvent {
  const ReleaseCamera();
}

// Event used by CameraBloc to forward frames from the controller callback
class CameraImageCaptured extends CameraEvent {
  final CameraImage image;
  const CameraImageCaptured(this.image);
}
