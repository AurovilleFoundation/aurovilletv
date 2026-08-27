import 'package:equatable/equatable.dart';

abstract class VideoDetailsEvent extends Equatable {
  const VideoDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideoDetails extends VideoDetailsEvent {
  final String videoId;
  const LoadVideoDetails(this.videoId);

  @override
  List<Object?> get props => [videoId];
}
