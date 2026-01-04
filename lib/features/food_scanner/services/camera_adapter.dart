import 'package:camera/camera.dart' as cam;

import '../../../widget/camera/camera_controller_facade.dart';

abstract class CameraAdapter {
  const CameraAdapter();

  Future<List<cam.CameraDescription>> availableCameras();

  CameraControllerFacade createController(
    cam.CameraDescription description,
    cam.ResolutionPreset resolutionPreset, {
    required bool enableAudio,
  });
}

class DefaultCameraAdapter extends CameraAdapter {
  const DefaultCameraAdapter();

  @override
  Future<List<cam.CameraDescription>> availableCameras() => cam.availableCameras();

  @override
  CameraControllerFacade createController(
    cam.CameraDescription description,
    cam.ResolutionPreset resolutionPreset, {
    required bool enableAudio,
  }) {
    return RealCameraControllerFacade(
      cam.CameraController(
      description,
      resolutionPreset,
      enableAudio: enableAudio,
      ),
    );
  }
}
