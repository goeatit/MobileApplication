import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api_client.dart';

class NetworkManager {
  final Dio dioManger; // Dio instance
  final Connectivity _connectivity;

  NetworkManager(this._connectivity)
      : dioManger = ApiClient().dio; // Get Dio from ApiClient

  Future<bool> isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
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
