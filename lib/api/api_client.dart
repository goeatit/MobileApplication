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
        // baseUrl: "https://api.eatitgo.in",
        // baseUrl: "http://10.0.2.2:8000",
        baseUrl: "http://192.168.0.125:8000",
        // baseUrl: "http://10.215.207.102:8000",
        // baseUrl: "http://192.168.0.100:8000",
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Dio get dio => _dio;
}
