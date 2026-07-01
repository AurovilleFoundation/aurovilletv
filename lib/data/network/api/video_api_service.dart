import '../../models/video_model.dart';

abstract class VideoApiService {
  /// Returns all videos
  Future<List<VideoModel>> getAllVideos();

  /// Returns videos filtered by category
  Future<List<VideoModel>> getVideos({required int categoryId});

  /// Search videos
  Future<List<VideoModel>> searchVideos({required String keyword});
}
