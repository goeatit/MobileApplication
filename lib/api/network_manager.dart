import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatit/Screens/Auth/login_screen/service/token_Storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api_client.dart';

class NetworkManager {
  final Dio dioManger;
  final Connectivity _connectivity;
  final TokenManager _tokenManager;

  // Cache internet result for 5 seconds
  DateTime? _lastCheckTime;
  bool _lastConnectionStatus = false;

  NetworkManager(this._connectivity)
      : dioManger = ApiClient().dio,
        _tokenManager = TokenManager() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    bool isRefreshing = false;
    Completer<void>? refreshCompleter;

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
          if (isRefreshing) {
            await refreshCompleter?.future;
          } else {
            isRefreshing = true;
            refreshCompleter = Completer<void>();

            try {
              await _tokenManager.refreshAccessToken((refreshToken) async {
                final response = await dioManger.post(
                  '/mobile/auth/refresh-token',
                  data: {'refreshToken': refreshToken},
                );
                return {
                  'accessToken': response.data['accessToken'],
                  'refreshToken': response.data['refreshToken'],
                };
              });
            } catch (_) {
              Fluttertoast.showToast(
                msg: "Session expired. Please log in again.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
              return handler.next(e);
            } finally {
              isRefreshing = false;
              refreshCompleter?.complete();
            }
          }

          final newAccessToken = await _tokenManager.getAccessToken();
          if (newAccessToken != null) {
            e.requestOptions.headers['Authorization'] =
            'Bearer $newAccessToken';
            return handler.resolve(await dioManger.fetch(e.requestOptions));
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<bool> isConnected() async {
    // Return cached result if within 5 seconds
    final now = DateTime.now();
    if (_lastCheckTime != null &&
        now.difference(_lastCheckTime!) < Duration(seconds: 5)) {
      return _lastConnectionStatus;
    }

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _lastCheckTime = now;
      _lastConnectionStatus = false;
      return false;
    }

    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(Duration(seconds: 3));
      _lastCheckTime = now;
      _lastConnectionStatus =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      return _lastConnectionStatus;
    } catch (_) {
      _lastCheckTime = now;
      _lastConnectionStatus = false;
      return false;
    }
  }

  Future<Response?> makeRequest(
      Future<Response> Function() request, {
        bool retryOnFailure = false,
      }) async {
    try {
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

      return await request();
    } on DioException catch (e) {
      if (retryOnFailure && e.type == DioExceptionType.connectionError) {
        return await request();
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
