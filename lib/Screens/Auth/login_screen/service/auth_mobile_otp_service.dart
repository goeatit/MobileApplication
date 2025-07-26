import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatit/Screens/Auth/login_screen/service/token_Storage.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class OtpService {
  final ApiRepository _apiRepository;
  OtpService({required ApiRepository apiRepository})
      : _apiRepository = apiRepository;

  Future<bool> sendOtp(String countryCode, String phoneNumber) async {
      try {
      final response = await _apiRepository.genOtp(countryCode, phoneNumber);
      if (response != null) {
        if (response.statusCode == 200) {
          // Fluttertoast.showToast(
          //   msg: "OTP sent successfully to $phoneNumber",
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.BOTTOM,
          //   backgroundColor: Colors.green,
          // );
          return true;
        } else {
          // Fluttertoast.showToast(
          //   msg: "Failed to send OTP: ${response.data}",
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.BOTTOM,
          //   backgroundColor: Colors.red,
          // );
          return false;
        }
      } else {
        // Fluttertoast.showToast(
        //   msg: "No response from server",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.red,
        // );
        return false;
      }
    } catch (error) {
      // Fluttertoast.showToast(
      //   msg: "Error sending OTP: $error",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   backgroundColor: Colors.red,
      // );
      return false;
    }
  }

  Future<bool> verifyOtp(String countryCode, String phoneNumber, String code,
      BuildContext context) async {
        try {
      final response =
          await _apiRepository.verifyOtp(countryCode, phoneNumber, code);
      if (response != null) {
        if (response.statusCode == 200) {
          // Fluttertoast.showToast(
          //   msg: "OTP Verified successfully to $phoneNumber",
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.BOTTOM,
          //   backgroundColor: Colors.green,
          // );
          var user = UserModel.fromJson(response.data);
          TokenManager tokenManager = TokenManager();
          tokenManager.storeTokens(user.accessToken, user.refreshToken);
          context.read<UserModelProvider>().updateUserModel(user.user);
          return true;
        } else {
          // Fluttertoast.showToast(
          //   msg: "Failed to Verify OTP: ${response.data}",
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.BOTTOM,
          //   backgroundColor: Colors.red,
          // );
          return false;
        }
      } else {
        // Fluttertoast.showToast(
        //   msg: "No response from server",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.red,
        // );
        return false;
      }
    } catch (error) {
      // Fluttertoast.showToast(
      //   msg: "Error Verifying OTP: $error",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   backgroundColor: Colors.red,
      // );
      return false;
    }
  }
}
