import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/main.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreenServiceInit {
  Future<bool> checkInitProfile(BuildContext context) async {
    try {
      final Connectivity connectivity = Connectivity();
      final NetworkManager networkManager = NetworkManager(connectivity);
      final ApiRepository apiRepository = ApiRepository(networkManager);
      final response = await apiRepository.initProfile();
      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (response.statusCode == 200) {
        var user=UserResponse.fromJson(response.data['user']);
        context.read<UserModelProvider>().updateUserModel(user);

        return true;
      }
      return false;
    } on DioException catch (e) {
      print(e.response?.data);
      if (e.response?.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Something went wrong. Please try again ${e.response?.data}."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      return false;
    } catch (e) {
      print("catch $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }
}
