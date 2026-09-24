import 'package:dio/dio.dart';
import 'api_constants.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            responseType: ResponseType.json,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              // ✅ Add Authorization if your API requires it
              // 'Authorization': 'token ecadacc37f4fd48:278a8eda422a329',
            },
          ),
        ) {
    dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
      // ✅ Add custom interceptors here if needed
      // AuthenticationInterceptor(),
      // RefreshTokenInterceptor(),
      // RetryInterceptor(),
    ]);
  }
}
