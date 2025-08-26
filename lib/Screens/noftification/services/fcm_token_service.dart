import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/api_repository.dart';

class FcmTokenService {
  static ApiRepository? _apiRepository;

  /// Set the ApiRepository instance for FCM token operations
  static void setApiRepository(ApiRepository apiRepository) {
    _apiRepository = apiRepository;
  }

  /// Get the current ApiRepository instance
  static ApiRepository? get getApiRepository => _apiRepository;

  /// Generate a unique FCM token and save to backend if user doesn't have one
  static Future<bool> saveTokenIfNeeded() async {
    try {
      if (_apiRepository == null) return false;

      // Check if backend already has a token for this user
      final existing = await _apiRepository!.getFcmToken();
      if (existing != null && existing.statusCode == 200) {
        final data = existing.data;
        if (data != null &&
            data['data'] != null &&
            data['data']['hasToken'] == true) {
          // User already has a token, cache it locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('fcm_token_saved', true);
          await prefs.setString(
              'saved_fcm_token', data['data']['fcmToken'] ?? '');
          return true;
        }
      }

      // User doesn't have a token, generate and save a new one
      String? token = await _generateUniqueToken();
      if (token == null) return false;

      final resp = await _apiRepository!.saveFcmToken(token);
      if (resp != null && resp.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('fcm_token_saved', true);
        await prefs.setString('saved_fcm_token', token);
        return true;
      }
      return false;
    } catch (e) {
      print('Error in saveTokenIfNeeded: $e');
      return false;
    }
  }

  /// Generate a unique FCM token for the current device
  static Future<String?> _generateUniqueToken() async {
    try {
      // Delete the current token to force generation of a new one
      await FirebaseMessaging.instance.deleteToken();

      // Wait a bit for the deletion to process
      await Future.delayed(const Duration(milliseconds: 500));

      // Get a new token
      String? newToken = await FirebaseMessaging.instance.getToken();

      if (newToken != null) {
        print(
            'Generated new unique FCM token: ${newToken.substring(0, 20)}...');
        return newToken;
      }

      return null;
    } catch (e) {
      print('Error generating unique token: $e');
      // Fallback to regular token generation
      return await FirebaseMessaging.instance.getToken();
    }
  }

  /// Listen to token refresh and only update local cache (no backend update)
  static Future<void> setupFcmTokenListener() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_fcm_token', token);
      // Intentionally do not update backend token
    });
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

      // Delete the FCM token from Firebase
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      print('Error clearing FCM token: $e');
    }
  }

  /// Clear only local cache, do not touch backend token
  static Future<void> clearLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_fcm_token');
      await prefs.remove('fcm_token_saved');
    } catch (_) {}
  }

  /// Handle user account switch - clear old tokens and prepare for new user
  static Future<void> handleUserSwitch(String newUserId) async {
    try {
      // Clear all tokens when switching users
      await clearSavedFcmToken();

      // Mark that we need to generate a new token for the new user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('force_fcm_token_save', true);
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

  /// Force regenerate and save a new FCM token
  static Future<bool> forceRegenerateToken() async {
    try {
      if (_apiRepository == null) return false;

      // Clear existing token from backend first
      await _apiRepository!.clearFcmToken();

      // Generate new unique token
      String? newToken = await _generateUniqueToken();
      if (newToken == null) return false;

      // Save new token to backend
      final resp = await _apiRepository!.saveFcmToken(newToken);
      if (resp != null && resp.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('fcm_token_saved', true);
        await prefs.setString('saved_fcm_token', newToken);
        return true;
      }
      return false;
    } catch (e) {
      print('Error force regenerating token: $e');
      return false;
    }
  }
}
