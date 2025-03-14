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

  Future<Response?> fetchDishesData(String name, String city) async {
    final endpoint = ApiEndpoints.fetchDishesByRestaurant(name, city);
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.get(endpoint);
    });
  }

  Future<Response?> fetchSearch(String query) async {
    final endpoint = ApiEndpoints.fetchRestaurantSearchAndFood(query);
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.get(endpoint);
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

  Future<Response?> updateProfile(Map<String, String?> changes) async {
    final endpoint = ApiEndpoints.updateProfile;
    return await networkManager.makeRequest(() {
      return networkManager.dioManger.post(endpoint, data: changes);
    });
  }
}
