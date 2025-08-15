import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/api_repository.dart';
import 'package:crypto/crypto.dart';

class FcmTokenService {
  static ApiRepository? _apiRepository;

  /// Set the ApiRepository instance for FCM token operations
  static void setApiRepository(ApiRepository apiRepository) {
    _apiRepository = apiRepository;
  }

  /// Get the current ApiRepository instance
  static ApiRepository? get getApiRepository => _apiRepository;

  /// Generate a unique FCM token for the current user
  /// This combines the device FCM token with user-specific information
  static Future<String?> generateUniqueFcmToken([String? userId]) async {
    try {
      // Get the base FCM token from Firebase
      String? baseFcmToken = await FirebaseMessaging.instance.getToken();
      if (baseFcmToken == null) {
        return null;
      }

      // If userId is provided, create a unique token
      if (userId != null && userId.isNotEmpty) {
        // Create a unique hash combining base token and user ID
        final uniqueToken = _createUniqueToken(baseFcmToken, userId);
        return uniqueToken;
      }

      // Fallback to base token if no user ID
      return baseFcmToken;
    } catch (e) {
      print('Error generating unique FCM token: $e');
      return null;
    }
  }

  /// Create a unique token by combining base FCM token with user ID
  static String _createUniqueToken(String baseToken, String userId) {
    // Create a hash of the combination
    final combined = baseToken + userId;
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);

    // Take first 32 characters of hash and combine with base token
    final hashPart = digest.toString().substring(0, 32);
    return baseToken + '_' + hashPart;
  }

  /// Save FCM token to backend using ApiRepository
  static Future<bool> saveFcmTokenToBackend(
      [String? authToken, String? userId]) async {
    try {
      if (_apiRepository == null) {
        return false;
      }

      // Generate unique FCM token
      String? fcmToken = await generateUniqueFcmToken(userId);
      if (fcmToken == null) {
        return false;
      }

      // Check if user already has an FCM token
      final existingTokenResponse = await _apiRepository!.getFcmToken();
      if (existingTokenResponse != null &&
          existingTokenResponse.statusCode == 200) {
        final existingData = existingTokenResponse.data;
        if (existingData['data'] != null &&
            existingData['data']['hasToken'] == true) {
          final existingToken = existingData['data']['fcmToken'];
          if (existingToken == fcmToken) {
            // Save token locally to avoid repeated saves
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('saved_fcm_token', fcmToken);
            await prefs.setBool('fcm_token_saved', true);
            await prefs.setString('fcm_token_user_id', userId ?? '');
            return true;
          }
        }
      }

      // Save the new FCM token using ApiRepository
      final response = await _apiRepository!.saveFcmToken(fcmToken);

      if (response != null && response.statusCode == 200) {
        // Save token locally to avoid repeated saves
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_fcm_token', fcmToken);
        await prefs.setBool('fcm_token_saved', true);
        await prefs.setString('fcm_token_user_id', userId ?? '');
        return true;
      } else {
        print('Failed to save FCM token: ${response?.statusMessage}');
        return false;
      }
    } catch (e) {
      print('Error saving FCM token: $e');
      return false;
    }
  }

  /// Setup FCM token refresh listener
  static Future<void> setupFcmTokenListener(
      [String? authToken, String? userId]) async {
    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newBaseToken) async {
      // Generate new unique token
      String? newUniqueToken = await generateUniqueFcmToken(userId);
      if (newUniqueToken != null) {
        await saveFcmTokenToBackend(authToken, userId);
      }
    });
  }

  /// Check if FCM token needs to be saved
  static Future<bool> shouldSaveFcmToken([String? userId]) async {
    try {
      // Check if force save is required
      if (await shouldForceFcmTokenSave()) {
        return true;
      }

      final prefs = await SharedPreferences.getInstance();
      final currentToken = await generateUniqueFcmToken(userId);
      final savedToken = prefs.getString('saved_fcm_token');
      final savedUserId = prefs.getString('fcm_token_user_id');
      final isTokenSaved = prefs.getBool('fcm_token_saved') ?? false;

      if (currentToken == null) {
        return false;
      }

      // Check if user ID changed (different user logged in)
      if (userId != null && savedUserId != null && userId != savedUserId) {
        return true;
      }

      if (savedToken == null || currentToken != savedToken || !isTokenSaved) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking if FCM token should be saved: $e');
      return true; // Save on error to be safe
    }
  }

  /// Get current FCM token
  static Future<String?> getCurrentFcmToken([String? userId]) async {
    try {
      return await generateUniqueFcmToken(userId);
    } catch (e) {
      return null;
    }
  }

  /// Clear saved FCM token using ApiRepository
  static Future<void> clearSavedFcmToken() async {
    try {
      if (_apiRepository != null) {
        // Clear token from backend
        await _apiRepository!.clearFcmToken();
      }

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_fcm_token');
      await prefs.remove('fcm_token_saved');
      await prefs.remove('fcm_token_user_id');
    } catch (e) {
      print('Error clearing FCM token: $e');
    }
  }

  /// Handle user account switch - clear old tokens and prepare for new user
  static Future<void> handleUserSwitch(String newUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('fcm_token_user_id');

      if (savedUserId != null && savedUserId != newUserId) {
        // Clear old FCM token data
        await clearSavedFcmToken();

        // Force new FCM token generation for new user
        await prefs.setBool('force_fcm_token_save', true);
      }
    } catch (e) {
      print('Error handling user switch: $e');
    }
  }

  /// Check if FCM token save should be forced (e.g., after user switch)
  static Future<bool> shouldForceFcmTokenSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shouldForce = prefs.getBool('force_fcm_token_save') ?? false;

      if (shouldForce) {
        await prefs.remove('force_fcm_token_save');
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
