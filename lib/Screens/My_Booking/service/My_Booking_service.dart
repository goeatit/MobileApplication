import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/models/my_booking_modal.dart';

class MyBookingService {
  final ApiRepository _apiRepository;
  CancelToken? _cancelToken;

  MyBookingService({ApiRepository? apiRepository})
      : _apiRepository =
            apiRepository ?? ApiRepository(NetworkManager(Connectivity()));

  Future<OrderDetailsResponse?> fetchOrderDetails() async {
    try {
      _cancelToken = CancelToken();
      final response =
          await _apiRepository.fetchOrderDetailsWithCancelToken(_cancelToken!);

      if (response != null && response.statusCode == 200) {
        return OrderDetailsResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Response?> cancelOrder(String orderId) async {
    try {
      return _apiRepository.cancelOrder(orderId);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> updatePickupTime(String orderId, String newPickupTime) async {
    try {
      final response =
          await _apiRepository.updateOrderPickupTime(orderId, newPickupTime);
      return response != null && response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void cancelRequest() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('Request cancelled');
      _cancelToken = null; // Reset the token after cancellation
    }
  }
}
