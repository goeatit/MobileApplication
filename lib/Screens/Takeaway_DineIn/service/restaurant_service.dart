import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eatit/api/api_repository.dart';

class RestaurantService {
  final ApiRepository _apiRepository;
  CancelToken? _cancelToken;

  RestaurantService({required ApiRepository apiRepository})
      : _apiRepository = apiRepository;

  /// Cancel any ongoing request if needed
  void cancelOngoingRequest([String? reason]) {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel(reason ?? "Cancelled by user");
    }
  }

  /// Fetch restaurants by area
  Future<Response?> fetchRestaurantsByArea() async {
    cancelOngoingRequest("New area request started");
    _cancelToken = CancelToken();

    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString("city");
    final country = prefs.getString("country");

    if (city == null || country == null) return null;

    return await _apiRepository.fetchRestaurantByAreaWithCancelToken(
      city,
      country,
      _cancelToken!,
    );
  }

  /// Fetch restaurants by category
  Future<Response?> fetchRestaurantsByCategory(String category) async {
    cancelOngoingRequest("New category request started");
    _cancelToken = CancelToken();

    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString("city");
    final country = prefs.getString("country");

    if (city == null || country == null || category.isEmpty) return null;

    return await _apiRepository.fetchRestaurantByCategoryNameWithCancelToken(
      city,
      country,
      _cancelToken!,
      category,
    );
  }

  Future<Response?> fetchDishesData(String name, String location) async {
    try {
      _cancelToken = CancelToken();
      final response = await _apiRepository.fetchDishesDataWithCancelToken(
        name,
        location,
        _cancelToken!,
      );

      return response;
    } catch (e) {
      // Log or handle as needed
      return null;
    }
  }

  /// Dispose cancel token manually if needed
  void dispose() {
    cancelOngoingRequest("Disposing RestaurantService");
  }
}
