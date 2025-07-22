import 'package:dio/dio.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreenServiceInit {
  final ApiRepository _apiRepository;
  // CancelToken? _cancelToken;

  SplashScreenServiceInit({required ApiRepository apiRepository})
      : _apiRepository = apiRepository;

  Future<bool> checkInitProfile(BuildContext context) async {
    try {
      final response = await _apiRepository.initProfile();
      if (response == null) {
        _showError(context, "Something went wrong. Please try again.");
        return false;
      }

      if (response.statusCode == 200) {
        var user = UserResponse.fromJson(response.data['user']);
        context.read<UserModelProvider>().updateUserModel(user);
        return true;
      }

      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _showError(context,
            "Something went wrong. Please try again ${e.response?.data}.");
        return false;
      }
      return false;
    } catch (_) {
      _showError(context, "Something went wrong. Please try again.");
      return false;
    }
  }

  Future<Response?> fetchCartItems(BuildContext context) async {
    try {
      return await _apiRepository.fetchCartItems();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _showError(context,
            "Something went wrong. Please try again ${e.response?.data}.");
        return null;
      }
      return null;
    } catch (_) {
      _showError(context, "Something went wrong. Please try again.");
      return null;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

}
