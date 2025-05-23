import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileSerevice {
  Future<bool> sendEmailOtp(String email, BuildContext context) async {
    try {
      final Connectivity connectivity = Connectivity();
      final NetworkManager networkManager = NetworkManager(connectivity);
      final ApiRepository apiRepository = ApiRepository(networkManager);

      final res = await apiRepository.sendOtpEmail(email);
      if (res != null) {
        if (res.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyEmailOtp(
      String email, BuildContext context, String otp) async {
    try {
      final Connectivity connectivity = Connectivity();
      final NetworkManager networkManager = NetworkManager(connectivity);
      final ApiRepository apiRepository = ApiRepository(networkManager);

      final res = await apiRepository.verifyOtpEmail(email, otp);
      if (res != null) {
        if (res.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 400) {
        // Handle 400 response (Invalid OTP case)
        final responseData =
            e.response?.data; // No need to use jsonDecode, Dio handles it
        String errorMessage = responseData['message'];
        Fluttertoast.showToast(
          msg: "Failed to Verify OTP: $errorMessage",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );

        // print("Error: $errorMessage"); // You can also show this in UI
      } else {
        // print("Unexpected DioException: $e");
      }
      return false;
    } catch (e) {
      print("General error: $e");
      return false;
    }
  }

  Future<bool> verifyMobileOtp(String phoneNumber, BuildContext context,
      String otp, String countryCode) async {
    try {
      final Connectivity connectivity = Connectivity();
      final NetworkManager networkManager = NetworkManager(connectivity);
      final ApiRepository apiRepository = ApiRepository(networkManager);

      final res = await apiRepository.verifyOtpPhoneNumber(
          phoneNumber, countryCode, otp);
      if (res != null) {
        if (res.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 400) {
        // Handle 400 response (Invalid OTP case)
        final responseData =
            e.response?.data; // No need to use jsonDecode, Dio handles it
        String errorMessage = responseData['message'];
        Fluttertoast.showToast(
          msg: "Failed to Verify OTP: $errorMessage",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );

        // print("Error: $errorMessage"); // You can also show this in UI
      } else {
        // print("Unexpected DioException: $e");
      }
      return false;
    } catch (e) {
      print("General error: $e");
      return false;
    }
  }

  Future<bool> saveProfileChanges(
      Map<String, String?> changes, BuildContext context) async {
    try {
      final Connectivity connectivity = Connectivity();
      final NetworkManager networkManager = NetworkManager(connectivity);
      final ApiRepository apiRepository = ApiRepository(networkManager);

      print(changes);
      final res = await apiRepository.updateProfile(changes);
      if (res != null) {
        if (res.statusCode == 200) {
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 400) {
        // Handle 400 response (Invalid OTP case)
        final responseData =
            e.response?.data; // No need to use jsonDecode, Dio handles it
        String errorMessage = responseData['message'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      print(e.response?.data);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> sendMobileOtp(
      String phoneNumber, String countryCode, BuildContext context) async {
    try {
      final Connectivity connectivity = Connectivity();
      final NetworkManager networkManager = NetworkManager(connectivity);
      final ApiRepository apiRepository = ApiRepository(networkManager);

      final res = await apiRepository.genOtp(countryCode, phoneNumber);
      if (res != null) {
        if (res.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
