import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:world_cup_watch/core/constants/api_constants.dart';

/// A Dio client for making HTTP requests.
/// This class is a singleton, ensuring that only one instance of Dio is created and shared across the application.
@singleton
class DioClient {
  late final Dio _dio;
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _dio.interceptors.add(LogInterceptor(responseBody: true));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = ApiConstants.token;
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }
  Dio get dio => _dio;
}
