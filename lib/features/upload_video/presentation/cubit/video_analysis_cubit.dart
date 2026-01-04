import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/video_analysis_service.dart';
import 'video_analysis_state.dart';

class VideoAnalysisCubit extends Cubit<VideoAnalysisState> {
  final VideoAnalysisService _service;

  VideoAnalysisCubit({VideoAnalysisService? service})
      : _service = service ?? VideoAnalysisService(),
        super(VideoAnalysisInitial());

  Future<void> analyzeVideo(XFile video) async {
    emit(VideoAnalysisAnalyzing(video));

    try {
      final result = await _service.analyzeVideo(video.path);
      emit(VideoAnalysisSuccess(video, result.recipe));
    } catch (e) {
      emit(VideoAnalysisFailure(e.toString(), video: video));
    }
  }

  void reset() {
    emit(VideoAnalysisInitial());
  }
}
