abstract class VideoDetailsEvent {}

class LoadVideoDetails extends VideoDetailsEvent {
  final String videoId;
  LoadVideoDetails(this.videoId);
}
