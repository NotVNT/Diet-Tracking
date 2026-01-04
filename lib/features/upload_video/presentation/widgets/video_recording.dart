import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:video_player/video_player.dart';
import '../../../../widget/camera/camera_controller_facade.dart';
import '../../../../widget/camera/camera_preview_wrapper.dart';
import '../../../../common/snackbar_helper.dart';
import '../../../../services/permission_service.dart';

class VideoRecording extends StatefulWidget {
  const VideoRecording({super.key});

  @override
  State<VideoRecording> createState() => _VideoRecordingPageState();
}

class _VideoRecordingPageState extends State<VideoRecording> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  Timer? _timer;
  int _recordingDuration = 0;
  final int _minDuration = 3;
  final int _maxDuration = 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    // Request permissions first (unified PermissionService)
    final permissionService = PermissionService();
    final cameraStatus = await permissionService.requestCameraPermissionStatus();
    final microphoneStatus =
        await permissionService.requestMicrophonePermissionStatus();

    if (cameraStatus.isDenied || microphoneStatus.isDenied) {
      if (mounted) {
        Navigator.of(context).pop();
        SnackBarHelper.showWarning(
          context,
          'Cần quyền truy cập Camera và Microphone để quay video.',
        );
      }
      return;
    }

    if (cameraStatus == ph.PermissionStatus.permanentlyDenied ||
        microphoneStatus == ph.PermissionStatus.permanentlyDenied) {
      await permissionService.openAppSettings();
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Không tìm thấy camera nào.');
        Navigator.of(context).pop();
      }
      return;
    }

    _cameras = cameras;
    // Use the first camera (usually back camera) or the previously selected one
    _initializeCameraController(cameras[_selectedCameraIndex]);
  }

  Future<void> _initializeCameraController(CameraDescription cameraDescription) async {
    final controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _controller = controller;
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Lỗi khởi tạo camera: $e');
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initializeCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _startRecording() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized || _isRecording) {
      return;
    }

    try {
      await cameraController.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
        if (_recordingDuration >= _maxDuration) {
          _stopRecording();
        }
      });
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Lỗi khi bắt đầu quay: $e');
    }
  }

  Future<void> _stopRecording() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !_isRecording) {
      return;
    }

    _timer?.cancel();
    setState(() {
      _isRecording = false;
    });

    try {
      final XFile videoFile = await cameraController.stopVideoRecording();
      
      if (_recordingDuration < _minDuration) {
        if (mounted) {
          SnackBarHelper.showWarning(context, 'Video quá ngắn. Vui lòng quay ít nhất $_minDuration giây.');
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).pop(videoFile);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Lỗi khi dừng quay: $e');
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: _maxDuration),
    );

    if (video != null) {
      // Validate duration using VideoPlayerController
      final controller = VideoPlayerController.file(File(video.path));
      try {
        await controller.initialize();
        final duration = controller.value.duration;
        await controller.dispose();

        if (duration.inSeconds < _minDuration || duration.inSeconds > _maxDuration) {
          if (mounted) {
            SnackBarHelper.showWarning(
              context,
              'Vui lòng chọn video có độ dài từ $_minDuration đến $_maxDuration giây.',
            );
          }
          return;
        }

        if (mounted) {
          Navigator.of(context).pop(video);
        }
      } catch (e) {
        await controller.dispose();
        if (mounted) {
          SnackBarHelper.showError(context, 'Lỗi khi kiểm tra video: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          CameraPreviewWrapper(
            controller: RealCameraControllerFacade(_controller!),
            isInitializing: !_isCameraInitialized,
            errorMessage: null,
          ),

          // Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Switch Camera Button
          if (_cameras.length > 1 && !_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 30),
                    onPressed: _switchCamera,
                  ),
                  const Text(
                    'Chuyển đổi',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Timer
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(_recordingDuration),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Album Button
                if (!_isRecording)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage('assets/icon/gallery_placeholder.png'), // Placeholder or use an icon
                              fit: BoxFit.cover,
                            ),
                            color: Colors.grey[800],
                          ),
                          child: const Icon(Icons.photo_library, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Album',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  )
                else
                  const SizedBox(width: 50), // Spacer to keep layout balanced

                // Record Button
                GestureDetector(
                  onTap: () {
                    if (_isRecording) {
                      _stopRecording();
                    } else {
                      _startRecording();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                      Container(
                        width: _isRecording ? 40 : 70,
                        height: _isRecording ? 40 : 70,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(_isRecording ? 8 : 35),
                        ),
                      ),
                    ],
                  ),
                ),

                // Spacer for symmetry (or effects button if needed later)
                const SizedBox(width: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
