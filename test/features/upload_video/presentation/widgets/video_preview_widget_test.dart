import 'package:diet_tracking_project/features/upload_video/presentation/widgets/video_preview_widget.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import '../../helpers/fake_video_player_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  testWidgets('VideoPreviewWidget renders and calls onClear', (tester) async {
    var cleared = false;

    final tempDir = await Directory.systemTemp.createTemp('video_preview_widget_test');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final videoFile = File('${tempDir.path}${Platform.pathSeparator}test.mp4');
    await videoFile.writeAsBytes(const [0, 1, 2, 3]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VideoPreviewWidget(
            videoFile: XFile(videoFile.path),
            onClear: () => cleared = true,
          ),
        ),
      ),
    );

    // Video playback can schedule periodic timers; avoid pumpAndSettle.
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      if (find.byIcon(Icons.delete_forever).evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byIcon(Icons.delete_forever), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_forever));
    await tester.pump();

    expect(cleared, isTrue);

    // Explicitly unmount to trigger VideoPlayerController.dispose().
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();
  });
}
