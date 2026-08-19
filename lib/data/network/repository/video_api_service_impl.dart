import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/data/network/dio_client.dart';
import 'package:dio/dio.dart';

import '../../models/video_model.dart';
import '../../models/live_stream_model.dart';

class VideoApiServiceImpl implements VideoApiService {
  final DioClient dioClient;

  static const String baseUrl = "https://your-domain.com/api";
  VideoApiServiceImpl({required this.dioClient});

  Dio get _dio => dioClient.dio;

  @override
  Future<List<VideoModel>> getAllVideos() async {
    try {
      final response = await _dio.get("/videos");

      return _parseVideos(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<List<VideoModel>> getVideos({required int categoryId}) async {
    try {
      final response = await _dio.get(
        "/videos",
        queryParameters: {"category_id": categoryId},
      );

      return _parseVideos(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<List<VideoModel>> searchVideos({required String keyword}) async {
    try {
      final response = await _dio.get(
        "/videos/search",
        queryParameters: {"keyword": keyword},
      );

      return _parseVideos(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<LiveStreamModel> getLiveStream({required String apiKey, required String apiSecret}) async {
    try {
      final response = await _dio.get(
        "https://aiis.auroville.org/api/method/register_of_residence.media.api.atv.live",
        options: Options(
          headers: {
            "Authorization": "token $apiKey:$apiSecret",
          },
        ),
      );

      final data = response.data;
      Map<String, dynamic>? dataMap;
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          final message = data['message'];
          if (message is Map<String, dynamic> && message.containsKey('data')) {
            dataMap = message['data'] as Map<String, dynamic>?;
          }
        }
      }

      if (dataMap != null) {
        final title = (dataMap['title'] ?? '') as String;
        final description = (dataMap['description'] ?? '') as String;
        final isLive = (dataMap['is_live'] ?? 0) as int;
        final videoUrl = (dataMap['video_url'] ?? '') as String;
        final thumbnail = (dataMap['thumbnail'] ?? '') as String;

        return LiveStreamModel(
          status: "Live", // Always active for the 24/7 TV channel
          title: title.isNotEmpty ? title : "Auroville TV",
          description: description.isNotEmpty ? description : "A Universal Township",
          streamUrl: videoUrl.isNotEmpty ? videoUrl : "https://aurovilletv.com/hls/education.m3u8",
          viewerCount: isLive == 1 ? 42 : 12,
          thumbnail: thumbnail,
        );
      } else {
        throw Exception("Invalid API response format");
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  List<VideoModel> _parseVideos(dynamic json) {
    final List list = json["data"];

    return list.map((e) => VideoModel.fromMap(e)).toList();
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout";

      case DioExceptionType.sendTimeout:
        return "Request timeout";

      case DioExceptionType.receiveTimeout:
        return "Server timeout";

      case DioExceptionType.connectionError:
        return "No internet connection";

      case DioExceptionType.badResponse:
        return e.response?.data["message"] ?? "Server error";

      default:
        return e.message ?? "Something went wrong";
    }
  }
}
