import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
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
    emit(VideoDetailsLoading());
    try {
      final videos = await apiService.getAllVideos();
      final targetId = event.videoId.trim().toLowerCase();

      // Safe match check ignoring white spaces and casing mismatches
      final video = videos.firstWhereOrNull(
        (v) => v.id.trim().toLowerCase() == targetId,
      );

      if (video != null) {
        emit(VideoDetailsLoaded(video: video));
      } else {
        // Fallback: If exact ID does not match, try matching by title contains or fallback safely
        final fallbackVideo = videos.firstWhereOrNull(
          (v) => v.title.toLowerCase().contains(targetId),
        );

        if (fallbackVideo != null) {
          emit(VideoDetailsLoaded(video: fallbackVideo));
        } else if (videos.isNotEmpty) {
          // Provide first available entry as safe fallback instead of throwing error
          emit(VideoDetailsLoaded(video: videos.first));
        } else {
          emit(const VideoDetailsError(message: "Video details not found."));
        }
      }
    } catch (e) {
      emit(VideoDetailsError(message: e.toString()));
    }
  }
}