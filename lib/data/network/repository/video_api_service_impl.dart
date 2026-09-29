import 'package:aurovilletv/data/models/home_data_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/video_model.dart';
import '../../models/live_stream_model.dart';

class VideoApiServiceImpl implements VideoApiService {
  final DioClient dioClient;
  static const String baseUrl = "https://aiis.auroville.org/api/method/register_of_residence.media.api.atv";

  VideoApiServiceImpl({required this.dioClient});

  Dio get _dio => dioClient.dio;

  Map<String, String> _getHeaders() {
    final apiKey = dotenv.env['LIVE_API_KEY'] ?? 'ecadacc37f4fd48';
    final apiSecret = dotenv.env['LIVE_API_SECRET'] ?? '278a8eda422a329';
    return {
      "Authorization": "token $apiKey:$apiSecret",
    };
  }

  // ---------------- All Videos ----------------
  @override
  Future<List<VideoModel>> getAllVideos() async {
    try {
      final response = await _dio.get(
        "https://aiis.auroville.org/api/method/register_of_residence.media.api.atv.videos",
        options: Options(headers: _getHeaders()),
      );

      return _parseVideos(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ---------------- Category Videos ----------------
  @override
  Future<List<VideoModel>> getVideos({required String categoryId}) async {
    try {
      final response = await _dio.get(
        "https://aiis.auroville.org/api/method/register_of_residence.media.api.atv.videos",
        queryParameters: {"category_id": categoryId},
        options: Options(headers: _getHeaders()),
      );
      return _parseVideos(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ---------------- Search ----------------
  @override
  Future<List<VideoModel>> searchVideos({required String keyword}) async {
    try {
      final response = await _dio.get(
        "https://aiis.auroville.org/api/method/register_of_residence.media.api.atv.search",
        queryParameters: {"q": keyword},
        options: Options(headers: _getHeaders()),
      );
      return _parseVideos(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ---------------- Live Stream (Continuous 24/7 + API status) ----------------
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
        if (data['data'] is Map<String, dynamic>) {
          dataMap = data['data'] as Map<String, dynamic>?;
        } else if (data['message'] is Map<String, dynamic>) {
          final message = data['message'] as Map<String, dynamic>;
          if (message['data'] is Map<String, dynamic>) {
            dataMap = message['data'] as Map<String, dynamic>?;
          } else {
            dataMap = message;
          }
        }
      }

      if (dataMap != null) {
        final title = (dataMap['title'] ?? '') as String;
        final description = (dataMap['description'] ?? '') as String;
        final rawVideoUrl = (dataMap['video_url'] ?? '') as String;
        final thumbnail = (dataMap['thumbnail'] ?? '') as String;
        final category = (dataMap['category'] ?? '') as String;
        final publishDate = (dataMap['publish_date'] ?? '') as String;

        final rawViewCount = dataMap['view_count'];
        final viewerCount = rawViewCount is num
            ? rawViewCount.toInt()
            : 0;

        // Auroville TV broadcasts 24/7 on its official HLS education stream.
        // If the API specifies a custom live stream URL, use it. Otherwise, fallback to the 24/7 stream.
        const defaultStreamUrl = "https://aurovilletv.com/hls/education.m3u8";
        final streamUrl = rawVideoUrl.trim().isNotEmpty ? rawVideoUrl.trim() : defaultStreamUrl;

        return LiveStreamModel(
          status: "Live",
          title: title,
          description: description,
          streamUrl: streamUrl,
          viewerCount: viewerCount,
          thumbnail: thumbnail,
          category: category,
          publishDate: publishDate,
        );
      } else {
        throw Exception("Invalid API response format");
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ---------------- Single Video By ID ----------------
  @override
  Future<VideoModel> getVideoById(String id) async {
    try {
      final response = await _dio.get(
        "https://aiis.auroville.org/api/method/register_of_residence.media.api.atv.video",
        queryParameters: {"id": id},
        options: Options(headers: _getHeaders()),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        final message = data['message'];
        if (message is Map<String, dynamic> && message.containsKey('data')) {
          return VideoModel.fromApi(Map<String, dynamic>.from(message['data'] as Map));
        }
      }
      throw Exception("Video not found");
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ---------------- Increment View Count ----------------
  @override
  Future<void> incrementViewCount(String id) async {
    try {
      await _dio.post(
        "https://aiis.auroville.org/api/method/register_of_residence.media.api.atv.increment_view",
        queryParameters: {"id": id},
        options: Options(headers: _getHeaders()),
      );
    } catch (_) {}
  }

  // ---------------- Home Data ----------------
  @override
  Future<HomeDataModel> getHomeData() async {
    try {
      final response = await _dio.get(
        "https://aiis.auroville.org/api/method/register_of_residence.media.api.atv.home",
        options: Options(headers: _getHeaders()),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        final message = data['message'];
        if (message is Map<String, dynamic> && message.containsKey('data')) {
          return HomeDataModel.fromMap(Map<String, dynamic>.from(message['data'] as Map));
        }
      }
      throw Exception("Invalid API response format");
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ---------------- Live Videos (From API Endpoint) ----------------
  @override
  Future<List<VideoModel>> getLiveVideos() async {
    try {
      final response = await _dio.get(
        "$baseUrl.live",
        options: Options(headers: _getHeaders()),
      );

      final liveList = _parseVideos(response.data);
      if (liveList.isNotEmpty) {
        return liveList;
      }

      // Fallback if API returns an empty list
      return [
        VideoModel(
          id: "auroville_live",
          title: "Auroville Foundation Live",
          description: "Live stream from Auroville Foundation",
          videoUrl: "https://aurovilletv.com/hls/education.m3u8",
          thumbnail: "assets/images/thumb.png",
          category: "Live",
          publishDate: DateTime.now(),
          isLive: true,
          published: true,
        ),
      ];
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception("Failed to load live video: $e");
    }
  }

  // ---------------- Upcoming (local filter) ----------------
  @override
  Future<List<VideoModel>> getUpcomingVideos() async {
    final all = await getAllVideos();
    final now = DateTime.now();
    return all
        .where((v) => v.publishDate != null && v.publishDate!.isAfter(now))
        .toList();
  }

  // ---------------- Ended (local filter) ----------------
  @override
  Future<List<VideoModel>> getEndedVideos() async {
    final all = await getAllVideos();
    final now = DateTime.now();
    return all
        .where((v) => v.publishDate != null && v.publishDate!.isBefore(now))
        .toList();
  }

  // ---------------- Helpers ----------------
  List<VideoModel> _parseVideos(dynamic json) {
    if (json == null) return [];
    dynamic data;
    if (json is Map && json.containsKey("message")) {
      final message = json["message"];
      if (message is Map && message.containsKey("data")) {
        data = message["data"];
      }
    }
    dynamic items;

    if (data is Map && data.containsKey("items")) {
      items = data["items"];
    } else if (data is List) {
      items = data;
    } else if (json is Map && json["message"] is List) {
      items = json["message"];
    }

    if (items is List) {
      return items.map((e) => VideoModel.fromMap(Map<String, dynamic>.from(e as Map))).toList();
    }

    return [];
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