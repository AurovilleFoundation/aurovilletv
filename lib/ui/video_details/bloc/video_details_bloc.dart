import 'package:aurovilletv/data/models/video_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_details_event.dart';
import 'video_details_state.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';

class VideoDetailsBloc extends Bloc<VideoDetailsEvent, VideoDetailsState> {
  final VideoApiService apiService;

  VideoDetailsBloc({required this.apiService})
      : super(VideoDetailsInitial()) {
    on<LoadVideoDetails>(_onLoadVideoDetails);
  }

  Future<void> _onLoadVideoDetails(
      LoadVideoDetails event, Emitter<VideoDetailsState> emit) async {
    if (event.initialVideo is VideoModel) {
      emit(VideoDetailsLoaded(video: event.initialVideo as VideoModel));
    } else {
      emit(VideoDetailsLoading());
    }

    try {
      // Increment view count in background
      apiService.incrementViewCount(event.videoId);

      try {
        final video = await apiService.getVideoById(event.videoId);
        emit(VideoDetailsLoaded(video: video));
        return;
      } catch (_) {}

      final videos = await apiService.getAllVideos();
      final targetId = event.videoId.trim().toLowerCase();

      VideoModel? video;
      for (final v in videos) {
        if (v.id.trim().toLowerCase() == targetId) {
          video = v;
          break;
        }
      }

      if (video != null) {
        emit(VideoDetailsLoaded(video: video));
      } else {
        VideoModel? fallbackVideo;
        for (final v in videos) {
          if (v.title.toLowerCase().contains(targetId)) {
            fallbackVideo = v;
            break;
          }
        }
        if (fallbackVideo != null) {
          emit(VideoDetailsLoaded(video: fallbackVideo));
        } else if (videos.isNotEmpty) {
          emit(VideoDetailsLoaded(video: videos.first));
        } else {
          emit(const VideoDetailsError(message: "Video details not found."));
        }
      }
    } catch (e) {
      if (state is! VideoDetailsLoaded) {
        emit(VideoDetailsError(message: e.toString()));
      }
    }
  }
}
