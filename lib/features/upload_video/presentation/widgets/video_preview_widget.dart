import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewWidget extends StatefulWidget {
  final XFile videoFile;
  final VoidCallback onClear;

  const VideoPreviewWidget({
    super.key,
    required this.videoFile,
    required this.onClear,
  });

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoFile.path != widget.videoFile.path) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(File(widget.videoFile.path));
    await _videoController!.initialize();
    if (mounted) {
      setState(() {});
      _videoController!.play();
    }
  }

  Future<void> _togglePlayPause() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = _videoController!;
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: _togglePlayPause,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: value.size.width,
                    height: value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(
                value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 34,
                color: colorScheme.onSurface,
              ),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.75),
                padding: const EdgeInsets.all(10),
              ),
              tooltip: value.isPlaying ? 'Pause' : 'Play',
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: widget.onClear,
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 30,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
