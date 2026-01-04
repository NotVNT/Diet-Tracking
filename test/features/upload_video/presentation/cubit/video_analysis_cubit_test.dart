import 'package:diet_tracking_project/features/upload_video/presentation/cubit/video_analysis_cubit.dart';
import 'package:diet_tracking_project/features/upload_video/presentation/cubit/video_analysis_state.dart';
import 'package:diet_tracking_project/features/upload_video/services/video_analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

import '../../mocks.dart';

void main() {
  group('VideoAnalysisCubit', () {
    test('initial state is VideoAnalysisInitial', () {
      final cubit = VideoAnalysisCubit(
        service: MockVideoAnalysisService(),
        userRepository: MockUserRepository(),
      );
      addTearDown(cubit.close);

      expect(cubit.state, isA<VideoAnalysisInitial>());
    });

    test('analyzeVideo emits analyzing -> success', () async {
      final service = MockVideoAnalysisService();
      final userRepo = MockUserRepository();
      when(userRepo.getCurrentUserData()).thenAnswer((_) async => null);
      when(service.analyzeVideo('test.mp4', goal: anyNamed('goal'), allergy: anyNamed('allergy')))
          .thenAnswer((_) async => const VideoAnalysisResult(recipe: 'Recipe text'));

      final cubit = VideoAnalysisCubit(service: service, userRepository: userRepo);
      addTearDown(cubit.close);

      final video = XFile('test.mp4');

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<VideoAnalysisAnalyzing>(),
          predicate<VideoAnalysisState>(
            (s) => s is VideoAnalysisSuccess && s.recipe == 'Recipe text' && s.video.path == video.path,
          ),
        ]),
      );

      await cubit.analyzeVideo(video);
      await states;

    verify(service.analyzeVideo(video.path,
      goal: anyNamed('goal'), allergy: anyNamed('allergy'))).called(1);
    });

    test('analyzeVideo emits analyzing -> failure (keeps video)', () async {
    final service = MockVideoAnalysisService();
    final userRepo = MockUserRepository();
    when(userRepo.getCurrentUserData()).thenAnswer((_) async => null);
    when(service.analyzeVideo('test.mp4', goal: anyNamed('goal'), allergy: anyNamed('allergy')))
      .thenThrow(Exception('boom'));

    final cubit = VideoAnalysisCubit(service: service, userRepository: userRepo);
      addTearDown(cubit.close);

      final video = XFile('test.mp4');

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<VideoAnalysisAnalyzing>(),
          predicate<VideoAnalysisState>(
            (s) => s is VideoAnalysisFailure && (s.video?.path == video.path) && s.message.contains('boom'),
          ),
        ]),
      );

      await cubit.analyzeVideo(video);
      await states;

    verify(service.analyzeVideo(video.path,
      goal: anyNamed('goal'), allergy: anyNamed('allergy'))).called(1);
    });

    test('reset emits VideoAnalysisInitial', () async {
      final service = MockVideoAnalysisService();
      final userRepo = MockUserRepository();
      when(userRepo.getCurrentUserData()).thenAnswer((_) async => null);
      when(service.analyzeVideo('test.mp4', goal: anyNamed('goal'), allergy: anyNamed('allergy')))
          .thenAnswer((_) async => const VideoAnalysisResult(recipe: 'Recipe text'));

      final cubit = VideoAnalysisCubit(service: service, userRepository: userRepo);
      addTearDown(cubit.close);

      await cubit.analyzeVideo(XFile('test.mp4'));

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<VideoAnalysisInitial>(),
        ]),
      );

      cubit.reset();
      await states;
    });
  });
}
