import 'package:dio/dio.dart';
import 'package:eatit/api/api_endpoint.dart';
import 'package:eatit/models/cart_items.dart';
import 'network_manager.dart';

class ApiRepository {
  final NetworkManager networkManager;

  ApiRepository(this.networkManager);

  Future<Response?> fetchRestaurantByArea(String city, String country) async {
    // Construct the endpoint using the dynamic values for city and country
    final endpoint = ApiEndpoints.fetchRestaurantByArea(city, country);

    // Make the request using NetworkManager
    return await networkManager.makeRequest(() {
      // Perform the GET request with the constructed endpoint
      return networkManager.dioManger.get(endpoint);
    });
  }

  Future<Response?> fetchRestaurantByAreaWithCancelToken(
      String city, String country, CancelToken cancelToken) async {
    // Construct the endpoint using the dynamic values for city and country
    final endpoint = ApiEndpoints.fetchRestaurantByArea(city, country);

    // Make the request using NetworkManager
    return await networkManager.makeRequest(() {
      // Perform the GET request with the constructed endpoint
      return networkManager.dioManger.get(
        endpoint,
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response?> fetchRestaurantByCategoryNameWithCancelToken(String city,
      String country, CancelToken cancelToken, String categoryName) async {
    // Construct the endpoint using the dynamic values for city and country
    final endpoint =
        ApiEndpoints.fetchRestaurantByCategoryName(categoryName, city, country);

    // Make the request using NetworkManager
    return await networkManager.makeRequest(() {
      // Perform the GET request with the constructed endpoint
      return networkManager.dioManger.get(
        endpoint,
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response?> fetchDishesData(String name, String city) async {
    final endpoint = ApiEndpoints.fetchDishesByRestaurant(name, city);
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.get(endpoint);
    });
  }

  Future<Response?> fetchDishesDataWithCancelToken(
      String name, String city, CancelToken cancelToken) async {
    final endpoint = ApiEndpoints.fetchDishesByRestaurant(name, city);
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.get(
        endpoint,
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response?> fetchSearch(String query,
      {CancelToken? cancelToken}) async {
    final endpoint = ApiEndpoints.fetchRestaurantSearchAndFood(query);
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.get(
        endpoint, cancelToken: cancelToken, // ✅ Pass the cancel token here
      );
    });
  }

  Future<Response?> genOtp(String countryCode, String phoneNumber) async {
    final endpoint = ApiEndpoints.genOtp;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint,
          data: {"countryCode": countryCode, "phoneNumber": phoneNumber});
    });
  }

  Future<Response?> verifyOtp(
      String countryCode, String phoneNumber, String code) async {
    final endpoint = ApiEndpoints.verifyOtp;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: {
        "phoneNumber": phoneNumber,
        "countryCode": countryCode,
        "code": code
      });
    });
  }

  Future<Response?> googleLogin(
      String email, String name, String avatarurl) async {
    final endpoint = ApiEndpoints.googleLogin;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint,
          data: {"email": email, "name": name, "avatarurl": avatarurl});
    });
  }

  Future<Response?> facebookLogin(
      String email, String name, String avatarurl, String accessToken) async {
    final endpoint = ApiEndpoints.facebookLogin;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: {
        "email": email,
        "name": name,
        "avatarurl": avatarurl,
        "accessTokenFacebook": accessToken
      });
    });
  }

  Future<Response?> sendOtpEmail(String email) async {
    final endpoint = ApiEndpoints.sendOtpEmail;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: {"email": email});
    });
  }

  Future<Response?> verifyOtpEmail(String email, String otp) async {
    final endpoint = ApiEndpoints.verifyOtpEmail;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger
          .post(endpoint, data: {"email": email, "code": otp});
    });
  }

  Future<Response?> verifyOtpPhoneNumber(
      String phoneNumber, String countryCode, String otp) async {
    final endpoint = ApiEndpoints.verifyPhoneNumberOtp;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: {
        "phoneNumber": phoneNumber,
        "countryCode": countryCode,
        "code": otp
      });
    });
  }

  Future<Response?> completeYourProfile(String name, String email, String? dob,
      String? gender, String countryCode, String phoneNumber) async {
    final endPoint = ApiEndpoints.completeYourProfile;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endPoint, data: {
        "name": name,
        "phoneNumber": phoneNumber,
        "countryCode": countryCode,
        "gender": gender,
        "dateOfBirth": dob,
        "email": email
      });
    });
  }

  Future<Response?> fetchCurrentData(
      String id, String name, List<CartItem> cartItems) async {
    final endpoint = ApiEndpoints.fetchCurrentData(id, name);
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: {
        'dishIdToBeOrderd': cartItems.map((e) => e.dish.id).toList(),
      });
    });
  }

  Future<Response?> fetchCurrentDataWithCancelToken(String id, String name,
      List<CartItem> cartItems, CancelToken cancelToken) async {
    final endpoint = ApiEndpoints.fetchCurrentData(id, name);
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(
        endpoint,
        data: {
          'dishIdToBeOrderd': cartItems.map((e) => e.dish.id).toList(),
        },
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response?> createOrder(
      String id,
      String orderType,
      String name,
      String pickupTime,
      String noOfPeople,
      String totalAmount,
      List<CartItem> cartItems) async {
    final endpoint = ApiEndpoints.createOrder(orderType);
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: {
        'restaurantId': id,
        'restaurantName': name,
        'pickupTime': pickupTime,
        if (noOfPeople != "") "Dinein": noOfPeople,
        'subTotal': double.parse(totalAmount),
        'items': cartItems.map((e) {
          return {
            '_id': e.id,
            'quantity': e.quantity,
            'name': e.dish.dishId.dishName,
            'price': e.dish.resturantDishPrice,
            'restaurantName': e.restaurantName,
          };
        }).toList(),
      });
    });
  }

  Future<Response?> verifyPayment(String paymentId, String orderId,
      String signature, String orderCreationId) async {
    final endpoint = ApiEndpoints.verifyPayment;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: {
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
        'orderCreationId': orderCreationId
      });
    });
  }

  Future<Response?> cancelOrder(String orderId) async {
    final endpoint = ApiEndpoints.cancelOrder(orderId);
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.delete(endpoint);
    });
  }

  Future<Response?> updateProfile(Map<String, String?> changes) async {
    final endpoint = ApiEndpoints.updateProfile;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: changes);
    });
  }

  Future<Response?> initProfile() async {
    final endpoint = ApiEndpoints.initProfile;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint);
    });
  }

  Future<Response?> fetchOrderDetailsWithCancelToken(
      CancelToken cancelToken) async {
    final endpoint = ApiEndpoints.fetchOrderDetails;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.get(endpoint, cancelToken: cancelToken);
    });
  }

  Future<Response?> updateOrderPickupTime(
      String orderId, String newPickupTime) async {
    final endpoint = ApiEndpoints.updatePickupTime;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.put(
        endpoint,
        data: {
          'orderId': orderId,
          'pickupTime': newPickupTime,
        },
      );
    });
  }

  Future<Response?> addToCart(String restaurantId, List<CartItem> cartItems,
      String orderType, String location) {
    final endpoint = ApiEndpoints.addToCart;
    return networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: {
        'restaurantId': restaurantId,
        'orderType': orderType,
        'items': cartItems.map((e) {
          return {
            '_id': e.id,
            'quantity': e.quantity,
            'name': e.dish.dishId.dishName,
            'price': e.dish.resturantDishPrice,
            'restaurantName': e.restaurantName,
          };
        }).toList(),
        'location': location
      });
    });
  }

  Future<Response?> incrementCartItem(String cartId, List<CartItem> cartItems) {
    final endpoint = ApiEndpoints.incrementCartItem;
    return networkManager.makeRequest(() {
      return networkManager.dioManger.put(endpoint, data: {
        'cartId': cartId,
        'items': cartItems.map((e) {
          return {
            '_id': e.id,
            'quantity': e.quantity,
            'name': e.dish.dishId.dishName,
            'price': e.dish.resturantDishPrice,
            'restaurantName': e.restaurantName,
          };
        }).toList(),
      });
    });
  }

  Future<Response?> decrementCartItem(
    List<CartItem> cartItems,
    List<String> itemIds,
    String restaurantId,
    String orderType,
  ) {
    final endpoint = ApiEndpoints.decrementCartItem;
    return networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: {
        // 'cartId': cartId,
        'data': cartItems.map((e) {
          return {
            '_id': e.id,
            'quantity': e.quantity,
            'name': e.dish.dishId.dishName,
            'price': e.dish.resturantDishPrice,
            'restaurantName': e.restaurantName,
            'cartId': e.cartId,
          };
        }).toList(),
        'restaurantId': restaurantId,
        'orderType': orderType,
      });
    });
  }

  Future<Response?> deleteCartItem(String cartId) {
    final endpoint = ApiEndpoints.deleteCartItem(cartId);
    return networkManager.makeRequest(() {
      return networkManager.dioManger.delete(endpoint);
    });
  }

  Future<Response?> fetchCartItems() {
    final endpoint = ApiEndpoints.fetchCartItems;
    return networkManager.makeRequest(() {
      return networkManager.dioManger.get(endpoint);
    });
  }
}
