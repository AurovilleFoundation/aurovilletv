import 'package:equatable/equatable.dart';

abstract class VideoDetailsEvent extends Equatable {
  const VideoDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideoDetails extends VideoDetailsEvent {
  final String videoId;
  final dynamic initialVideo;
  const LoadVideoDetails(this.videoId, {this.initialVideo});

  @override
  List<Object?> get props => [videoId, initialVideo];
}
