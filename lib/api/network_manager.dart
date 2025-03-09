import 'dart:io';

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatit/Screens/Auth/login_screen/service/token_Storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api_client.dart';

class NetworkManager {
  final Dio dioManger; // Dio instance
  final Connectivity _connectivity;
  final TokenManager _tokenManager;

  NetworkManager(this._connectivity)
      : dioManger = ApiClient().dio,
        _tokenManager = TokenManager() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dioManger.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await _tokenManager.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, try refreshing it
          try {
            await _tokenManager.refreshAccessToken((refreshToken) async {
              final response = await dioManger.post(
                'mobile/auth/refresh-token',
                data: {'refreshToken': refreshToken},
              );
              return {
                'accessToken': response.data['accessToken'],
                'refreshToken': response.data['refreshToken'],
              };
            });

            // Retry the failed request with the new token
            final newAccessToken = await _tokenManager.getAccessToken();
            if (newAccessToken != null) {
              e.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              return handler.resolve(await dioManger.fetch(e.requestOptions));
            }
          } catch (_) {
            // Refresh token failed, logout the user
            Fluttertoast.showToast(
              msg: "Session expired. Please log in again.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        }
        return handler.next(e); // Forward other errors
      },
    ));
  }

  Future<bool> isConnected() async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();

    if (connectivityResult.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile)) {
      // Check if internet is actually reachable
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        return false; // No actual internet despite being connected
      }
    }
    return false; // No network connection
  }

  Future<Response?> makeRequest(
    Future<Response> Function() request, {
    bool retryOnFailure = false,
  }) async {
    try {
      // Check for internet connection
      if (!await isConnected()) {
        Fluttertoast.showToast(
          msg: "No internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        throw Exception("No internet connection");
      }

      // Execute the request
      return await request();
    } on DioException catch (e) {
      if (retryOnFailure && e.type == DioExceptionType.values) {
        // Retry logic for network errors
        return await request();
      }
      rethrow; // Re-throw error if not retried
    } catch (e) {
      rethrow; // Re-throw general exceptions
    }
  }
}
