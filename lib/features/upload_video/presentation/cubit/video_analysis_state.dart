import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class VideoAnalysisState extends Equatable {
  const VideoAnalysisState();

  @override
  List<Object?> get props => [];
}

class VideoAnalysisInitial extends VideoAnalysisState {}

class VideoAnalysisAnalyzing extends VideoAnalysisState {
  final XFile video;

  const VideoAnalysisAnalyzing(this.video);

  @override
  List<Object?> get props => [video];
}

class VideoAnalysisSuccess extends VideoAnalysisState {
  final XFile video;
  final String recipe;

  const VideoAnalysisSuccess(this.video, this.recipe);

  @override
  List<Object?> get props => [video, recipe];
}

class VideoAnalysisFailure extends VideoAnalysisState {
  final XFile? video;
  final String message;

  const VideoAnalysisFailure(this.message, {this.video});

  @override
  List<Object?> get props => [video, message];
}
