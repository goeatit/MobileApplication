import 'package:dio/dio.dart';
import 'package:eatit/api/api_endpoint.dart';
import 'package:flutter/cupertino.dart';
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
}
