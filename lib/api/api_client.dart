import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://api.eatitgo.in",
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Dio get dio => _dio;
}
