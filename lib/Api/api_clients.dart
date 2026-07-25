import 'package:college/Api/api_constants.dart';
import 'package:dio/dio.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  static void setToken(String token) {
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  static void clearToken() {
    dio.options.headers.remove("Authorization");
  }
}