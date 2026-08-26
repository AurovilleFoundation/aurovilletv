import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_details_event.dart';
import 'video_details_state.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';

class VideoDetailsBloc extends Bloc<VideoDetailsEvent, VideoDetailsState> {
  final VideoApiService apiService;

  VideoDetailsBloc(this.apiService) : super(VideoDetailsInitial()) {
    on<LoadVideoDetails>(_onLoadVideoDetails);
  }

  Future<void> _onLoadVideoDetails(
    LoadVideoDetails event,
    Emitter<VideoDetailsState> emit,
  ) async {
    emit(VideoDetailsLoading());
    try {
      // Fetch all videos from API
      final videos = await apiService.getAllVideos();

      // Find the video by ID safely
      final video = videos.firstWhere(
        (v) => v.id == event.videoId,
        orElse: () => VideoModel(
          id: event.videoId,
          title: "Unknown Video",
          description: "No details available",
          thumbnail: "",
          category: "",
          durationMinutes: 0,
          publishDate: DateTime.now(),
        ),
      );

      emit(VideoDetailsLoaded(video));
    } catch (e) {
      emit(VideoDetailsError("Failed to load video details: $e"));
    }
  }
}
