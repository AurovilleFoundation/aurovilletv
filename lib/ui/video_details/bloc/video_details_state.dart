import 'package:equatable/equatable.dart';
import 'package:aurovilletv/data/models/video_model.dart';

abstract class VideoDetailsState extends Equatable {
  const VideoDetailsState();

  @override
  List<Object?> get props => [];
}

class VideoDetailsInitial extends VideoDetailsState {}

class VideoDetailsLoading extends VideoDetailsState {}

class VideoDetailsLoaded extends VideoDetailsState {
  final VideoModel video;
  const VideoDetailsLoaded({required this.video});

  @override
  List<Object?> get props => [video];
}

class VideoDetailsError extends VideoDetailsState {
  final String message;
  const VideoDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
