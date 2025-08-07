import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../Auth/login_screen/service/token_Storage.dart';
import '../../../api/api_client.dart';
import '../../../api/api_endpoint.dart';

class FcmTokenService {
  static final ApiClient _apiClient = ApiClient();

  static Future<void> saveFcmTokenToBackend([String? authToken]) async {
    try {
      // Get auth token from TokenManager if not provided
      if (authToken == null) {
        authToken = await TokenManager().getAccessToken();
      }

      if (authToken == null) {
        print('❌ No auth token available, cannot save FCM token');
        return;
      }

      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        print('🔑 Saving FCM token: ${fcmToken.substring(0, 20)}...');

        // Use the API client instead of direct HTTP
        final response = await _apiClient.dio.post(
          ApiEndpoints.saveFcmToken,
          data: {'fcmToken': fcmToken},
          options: Options(
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          print('✅ FCM token saved successfully');
          // Save token locally to avoid repeated saves
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_fcm_token', fcmToken);
          await prefs.setBool('fcm_token_saved', true);
        } else {
          print('❌ Failed to save FCM token: ${response.statusCode}');
          print('Response: ${response.data}');
        }
      } else {
        print('❌ FCM token is null');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
      // Try alternative method with direct HTTP if API client fails
      try {
        await _saveFcmTokenDirectHttp(authToken);
      } catch (directError) {
        print('❌ Direct HTTP method also failed: $directError');
      }
    }
  }

  static Future<void> _saveFcmTokenDirectHttp(String? authToken) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        print('❌ FCM token is null in direct HTTP method');
        return;
      }

      print('🔄 Trying direct HTTP method for FCM token save...');

      final response = await http.post(
        Uri.parse(
            '${_apiClient.dio.options.baseUrl}${ApiEndpoints.saveFcmToken}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'fcmToken': fcmToken}),
      );

      if (response.statusCode == 200) {
        print('✅ FCM token saved successfully via direct HTTP');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_fcm_token', fcmToken);
        await prefs.setBool('fcm_token_saved', true);
      } else {
        print('❌ Direct HTTP failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Direct HTTP error: $e');
    }
  }

  static Future<void> setupFcmTokenListener([String? authToken]) async {
    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
      saveFcmTokenToBackend(authToken);
    });
  }

  static Future<bool> shouldSaveFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentToken = await FirebaseMessaging.instance.getToken();
      final savedToken = prefs.getString('saved_fcm_token');
      final isTokenSaved = prefs.getBool('fcm_token_saved') ?? false;

      if (currentToken == null) {
        print('❌ Current FCM token is null');
        return false;
      }

      if (savedToken == null || currentToken != savedToken || !isTokenSaved) {
        print(
            '✅ Should save FCM token: current=${currentToken.substring(0, 20)}..., saved=${savedToken?.substring(0, 20) ?? 'null'}');
        return true;
      }

      print('ℹ️ FCM token already saved and up to date');
      return false;
    } catch (e) {
      print('❌ Error checking FCM token: $e');
      return true; // Save on error to be safe
    }
  }

  static Future<String?> getCurrentFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }
}
