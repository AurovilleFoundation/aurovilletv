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
          },
        ),
      ) {
    dio.interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),

      // AuthenticationInterceptor(),
      // RefreshTokenInterceptor(),
      // RetryInterceptor(),
    ]);
  }
}
