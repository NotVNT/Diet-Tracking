import 'package:diet_tracking_project/features/upload_video/presentation/cubit/video_analysis_cubit.dart';
import 'package:diet_tracking_project/features/upload_video/presentation/pages/video_processing_page.dart';
import 'package:diet_tracking_project/features/upload_video/services/video_analysis_service.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:provider/provider.dart';

import 'package:diet_tracking_project/features/home_page/presentation/providers/home_provider.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';

import '../../helpers/fake_video_player_platform.dart';
import '../../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Ensure video_player is faked for any VideoPreviewWidget builds.
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  Widget wrap(Widget child) {
    final mockHomeProvider = MockHomeProvider();
    final mockNotificationProvider = MockNotificationProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeProvider>.value(value: mockHomeProvider),
        ChangeNotifierProvider<NotificationProvider>.value(value: mockNotificationProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('VideoProcessingView shows recipe text on success', (tester) async {
    final service = MockVideoAnalysisService();
    final userRepo = MockUserRepository();
    when(userRepo.getCurrentUserData()).thenAnswer((_) async => null);
    when(service.analyzeVideo('test.mp4', goal: anyNamed('goal'), allergy: anyNamed('allergy')))
        .thenAnswer((_) async => const VideoAnalysisResult(recipe: 'My recipe'));

    await tester.pumpWidget(
      wrap(
        BlocProvider<VideoAnalysisCubit>(
          create: (_) => VideoAnalysisCubit(service: service, userRepository: userRepo),
          child: const VideoProcessingView(),
        ),
      ),
    );
  await tester.pumpAndSettle();

  final element = tester.element(find.byType(VideoProcessingView));
  final cubit = BlocProvider.of<VideoAnalysisCubit>(element);

  await cubit.analyzeVideo(XFile('test.mp4'));
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text('My recipe'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('VideoProcessingView shows error message on failure', (tester) async {
    final service = MockVideoAnalysisService();
    final userRepo = MockUserRepository();
    when(userRepo.getCurrentUserData()).thenAnswer((_) async => null);
    when(service.analyzeVideo('test.mp4', goal: anyNamed('goal'), allergy: anyNamed('allergy')))
        .thenThrow(Exception('boom'));

    await tester.pumpWidget(
      wrap(
        BlocProvider<VideoAnalysisCubit>(
          create: (_) => VideoAnalysisCubit(service: service, userRepository: userRepo),
          child: const VideoProcessingView(),
        ),
      ),
    );
  await tester.pumpAndSettle();

  final element = tester.element(find.byType(VideoProcessingView));
  final cubit = BlocProvider.of<VideoAnalysisCubit>(element);

  await cubit.analyzeVideo(XFile('test.mp4'));
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.textContaining('boom'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
