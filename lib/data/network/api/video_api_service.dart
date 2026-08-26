import '../../models/video_model.dart';
import '../../models/live_stream_model.dart';
import '../../models/home_data_model.dart';

abstract class VideoApiService {
  /// Returns all videos
  Future<List<VideoModel>> getAllVideos();

  /// Returns videos filtered by category
  Future<List<VideoModel>> getVideos({required String categoryId});

  /// Search videos
  Future<List<VideoModel>> searchVideos({required String keyword});

  /// Get live stream details from AIIS API
  Future<LiveStreamModel> getLiveStream({required String apiKey, required String apiSecret});

  /// Get home page data
  Future<HomeDataModel> getHomeData();
}
