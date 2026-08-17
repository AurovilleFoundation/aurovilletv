import '../../models/video_model.dart';
import '../../models/live_stream_model.dart';

abstract class VideoApiService {
  /// Returns all videos
  Future<List<VideoModel>> getAllVideos();

  /// Returns videos filtered by category
  Future<List<VideoModel>> getVideos({required int categoryId});

  /// Search videos
  Future<List<VideoModel>> searchVideos({required String keyword});

  /// Get live stream details from AIIS API
  Future<LiveStreamModel> getLiveStream({required String apiKey, required String apiSecret});
}
