import 'package:aurovilletv/data/models/video_model.dart';

abstract class VideoDetailsState {}

class VideoDetailsInitial extends VideoDetailsState {}

class VideoDetailsLoading extends VideoDetailsState {}

class VideoDetailsLoaded extends VideoDetailsState {
  final VideoModel video;
  VideoDetailsLoaded(this.video);
}

class VideoDetailsError extends VideoDetailsState {
  final String message;
  VideoDetailsError(this.message);
}
