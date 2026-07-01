import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/data/network/dio_client.dart';
import 'package:dio/dio.dart';

import '../../models/video_model.dart';

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
