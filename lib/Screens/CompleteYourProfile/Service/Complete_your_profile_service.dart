import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/src/response.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CompleteYourProfileService {
  final ApiRepository _apiRepository;
  CancelToken? _cancelToken;

  CompleteYourProfileService({required ApiRepository apiRepository})
      : _apiRepository = apiRepository;

  Future<bool> sendEmailOtp(String email, BuildContext context) async {
    try {
      final res = await _apiRepository.sendOtpEmail(email);
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

  Future<bool> sendMobilePhoneOtp(
      String countryCode, String phoneNumber, BuildContext context) async {
    try {
      final res = await _apiRepository.genOtp(countryCode, phoneNumber);
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
      final res = await _apiRepository.verifyOtpEmail(email, otp);
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

  Future<bool> verifyPhoneNumberOtp(String phoneNumber, String countryCode,
      BuildContext context, String otp) async {
    try {
      final res = await _apiRepository.verifyOtpPhoneNumber(
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

  Future<Response?> completeYourProfile(String name, String email, String? dob,
      String? gender, String countryCode, String phoneNumber) async {
    return await _apiRepository.completeYourProfile(
        name, email, dob, gender, countryCode, phoneNumber);
  }
}
