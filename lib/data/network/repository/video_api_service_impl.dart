import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../../models/video_model.dart';

class VideoApiServiceImpl implements VideoApiService {
  final DioClient dioClient;

  static const String baseUrl =
      "https://aiis.auroville.org/api/method/register_of_residence.media.api.atv";

  VideoApiServiceImpl({required this.dioClient});

  Dio get _dio => dioClient.dio;

  // ---------------- All Videos ----------------
@override
Future<List<VideoModel>> getAllVideos() async {
  try {
    final response = await _dio.get(
      "https://aiis.auroville.org/api/method/register_of_residence.media.api.atv.videos?page=1&limit=10",
      options: Options(headers: {
        "Authorization": "token ecadacc37f4fd48:278a8eda422a329" 
      }),
    );
    return _parseVideos(response.data);
  } on DioException catch (e) {
    throw Exception(_getErrorMessage(e));
  }
}


  // ---------------- Category Videos ----------------
  @override
  Future<List<VideoModel>> getVideos({required int categoryId}) async {
    try {
      final response = await _dio.get(
        "$baseUrl.videos?page=1&limit=10&category_id=$categoryId&sort=latest",
        options: Options(headers: {
          "Authorization": "token ecadacc37f4fd48:278a8eda422a329"
        }),
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
        "$baseUrl.search?q=$keyword&page=1&limit=10",
        options: Options(headers: {
          "Authorization": "token ecadacc37f4fd48:278a8eda422a329"
        }),
      );
      return _parseVideos(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

 // ---------------- Live ----------------
@override
Future<List<VideoModel>> getLiveVideos() async {
  try {
    // Instead of API, return static live stream as VideoModel
    final liveVideo = VideoModel(
      id: "auroville_live",
      title: "Auroville Foundation Live",
      description: "Live stream from Auroville Foundation",
      videoUrl: "https://aurovilletv.com/hls/education.m3u8",
      thumbnail: "assets/images/thumb.png", // fallback thumbnail
      category: "Live",
      publishDate: DateTime.now(),
      isLive: true,
      published: true,
    );

    return [liveVideo];
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
    final items = json["message"]?["data"]?["items"];
    if (items is List) {
      return items.map((e) => VideoModel.fromMap(e)).toList();
    }
    print("⚠️ No items found: $json");
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
