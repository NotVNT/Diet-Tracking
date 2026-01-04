import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final Map<int, StreamController<VideoEvent>> _eventControllers = {};
  final Set<int> _sentInitialized = {};
  int _nextTextureId = 1;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    final id = _nextTextureId++;
    final controller = StreamController<VideoEvent>.broadcast();
    _eventControllers[id] = controller;

    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    final controller = _eventControllers[textureId]!;

    // Ensure initialize() completes by sending the initialized event after a
    // listener has had a chance to attach.
    if (!_sentInitialized.contains(textureId)) {
      _sentInitialized.add(textureId);
      scheduleMicrotask(() {
        if (!controller.isClosed) {
          controller.add(
            VideoEvent(
              eventType: VideoEventType.initialized,
              duration: const Duration(seconds: 1),
              size: const Size(640, 360),
            ),
          );
        }
      });
    }

    return controller.stream;
  }

  @override
  Widget buildView(int textureId) {
    return const SizedBox.shrink();
  }

  @override
  Future<void> play(int textureId) async {
    _eventControllers[textureId]?.add(
      VideoEvent(
        eventType: VideoEventType.isPlayingStateUpdate,
        isPlaying: true,
      ),
    );
  }

  @override
  Future<void> pause(int textureId) async {
    _eventControllers[textureId]?.add(
      VideoEvent(
        eventType: VideoEventType.isPlayingStateUpdate,
        isPlaying: false,
      ),
    );
  }

  @override
  Future<void> dispose(int textureId) async {
    final controller = _eventControllers.remove(textureId);
    await controller?.close();
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {}

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {}

  @override
  Future<void> seekTo(int textureId, Duration position) async {}

  @override
  Future<Duration> getPosition(int textureId) async => Duration.zero;

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}
}
