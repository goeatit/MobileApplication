import 'package:dio/dio.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/models/my_booking_modal.dart';

class MyBookingService {
  final ApiRepository _apiRepository;
  CancelToken? _cancelToken;

  MyBookingService({required ApiRepository apiRepository})
      : _apiRepository = apiRepository;

  Future<OrderDetailsResponse?> fetchOrderDetails() async {
    _cancelToken = CancelToken();
    try {
      final response =
      await _apiRepository.fetchOrderDetailsWithCancelToken(_cancelToken!);
      if (response != null && response.statusCode == 200) {
        return OrderDetailsResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error in fetchOrderDetails: $e');
      return null;
    }
  }

  Future<Response?> cancelOrder(String orderId) async {
    try {
      return _apiRepository.cancelOrder(orderId);
    } catch (e) {
      print('Error in cancelOrder: $e');
      return null;
    }
  }

  Future<bool> updatePickupTime(String orderId, String newPickupTime) async {
    try {
      final response =
      await _apiRepository.updateOrderPickupTime(orderId, newPickupTime);
      return response != null && response.statusCode == 200;
    } catch (e) {
      print('Error in updatePickupTime: $e');
      return false;
    }
  }

  void cancelRequest() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('Request cancelled');
      _cancelToken = null;
    }
  }

  void dispose() {
    cancelRequest();
  }
}
