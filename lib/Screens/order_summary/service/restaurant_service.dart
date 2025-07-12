import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/models/dish_retaurant.dart';

class RestaurantService {
  final ApiRepository _apiRepository;
  CancelToken? _cancelToken;

  RestaurantService({ApiRepository? apiRepository})
      : _apiRepository =
            apiRepository ?? ApiRepository(NetworkManager(Connectivity()));

  Future<Response?> getCurrentData(
      String id, String name, List<CartItem> cartItems) async {
    return await _apiRepository.fetchCurrentData(id, name, cartItems);
  }

  Future<Response?> getCurrentDataWithCancelToken(String id, String name,
      List<CartItem> cartItems, CancelToken cancelToken) async {
    return await _apiRepository.fetchCurrentDataWithCancelToken(
        id, name, cartItems, cancelToken);
  }

  Map<String, dynamic> checkPriceChangesAndAvailability(
      CurrentData currentData, List<CartItem> cartItems) {
    bool isRestaurantClosed = currentData.forceClose;
    List<Map<String, dynamic>> changedPrices = [];

    // Check each cart item against the current data from server
    for (var cartItem in cartItems) {
      // Find matching dish in current data

      final serverDish = currentData.orderDish.firstWhere(
        (dish) => dish.dishId == cartItem.id,
        orElse: () => OrderdDish(
            dishId: '', dishName: '', dishPrice: 0, available: false),
      );

      // If dish exists and price has changed or dish is unavailable
      if (serverDish.dishId.isNotEmpty) {
        if (serverDish.dishPrice != cartItem.dish.resturantDishPrice) {
          changedPrices.add({
            'dishId': serverDish.dishId,
            'dishName': serverDish.dishName,
            'oldPrice': cartItem.dish.resturantDishPrice,
            'newPrice': serverDish.dishPrice,
          });
        }

        if (!serverDish.available) {
          changedPrices.add({
            'dishId': serverDish.dishId,
            'dishName': serverDish.dishName,
            'available': false,
          });
        }
      }
    }

    return {
      'isRestaurantClosed': isRestaurantClosed,
      'changedPrices': changedPrices,
      'hasChanges': changedPrices.isNotEmpty || isRestaurantClosed,
    };
  }

  Future<Response?> createOrder(
      String id,
      String orderType,
      String name,
      String pickupTime,
      String noOfPeople,
      String totalAmount,
      List<CartItem> cartItems) async {
    final Connectivity connectivity = Connectivity();
    final NetworkManager networkManager = NetworkManager(connectivity);
    final ApiRepository apiRepository = ApiRepository(networkManager);

    return await apiRepository.createOrder(
        id, orderType, name, pickupTime, noOfPeople, totalAmount, cartItems);
  }

  Future<Response?> verifyPayment(String paymentId, String orderId,
      String signature, String orderCreationId) async {
    return await _apiRepository.verifyPayment(
        paymentId, orderId, signature, orderCreationId);
  }
}
