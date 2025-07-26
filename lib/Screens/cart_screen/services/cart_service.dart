import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:eatit/Screens/cart_screen/screen/cart_page.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class CartService {
  final ApiRepository _apiRepository;
  CancelToken? _cancelToken;

  CartService({required ApiRepository apiRepository})
      : _apiRepository = apiRepository;

  Future<Response?> addToCart(String restaurantId, BuildContext context,
      String orderType, String location) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final responses = await _apiRepository.addToCart(
          restaurantId,
          cartProvider.getItemsByOrderTypeAndRestaurant(
              restaurantId, orderType),
          orderType,
          location);
      if (responses?.statusCode != 200) {
        return null;
      }
      final data = responses?.data;

      if (data != null && data['mapCartId'] != null) {
        for (var item in data['mapCartId']) {
          final cartId = item['cartId'];
          final dishId = item['dishId'];
          cartProvider.updateCartId(cartId, dishId, orderType, restaurantId);
        }
      }
      return responses;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Response?> decrementCartItem(List<String> itemIds, String restaurantId,
      BuildContext context, String orderType) async {
    try {
      // TODO: Replace with actual cartItems and cartId
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      final responses = await _apiRepository.decrementCartItem(
          cartProvider.getItemsByOrderTypeAndRestaurant(
              restaurantId, orderType),
          itemIds,
          restaurantId,
          orderType);
      if (responses?.statusCode != 200) {
        return null;
      }
      return responses;
    } on DioException catch (e) {
      print(e.response?.data);
      return e.response;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> removeCartItem(CartItemWithDetails catItemDetails) async {
    try {
      final responses =
          await _apiRepository.deleteCartItem(catItemDetails.cartItem.cartId!);
      if (responses?.statusCode != 200) {
        return false;
      }
      return true;
    } on DioException catch (e) {
      print(e.response?.data);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Fetch cart items from API and update CartProvider
  Future<(bool, String?)> fetchAndUpdateCart(BuildContext context) async {
    try {
      final response = await _apiRepository.fetchCartItems();
      if (response == null || response.statusCode != 200) {
        return (false, 'Failed to fetch cart items');
      }
      final data = response.data['cart'];
      if (data != null) {
        context.read<CartProvider>().loadGroupedCartFromResponse(data);
        return (true, null);
      } else {
        return (false, 'No cart data found');
      }
    } on DioException catch (e) {
      return (false, e.response?.data?.toString() ?? 'Network error');
    } catch (e) {
      return (false, e.toString());
    }
  }
}
