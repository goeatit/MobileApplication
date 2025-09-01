// token_manager.dart

import 'package:eatit/Screens/noftification/services/fcm_token_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  // Singleton instance
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;

  // Secure storage instance
  final FlutterSecureStorage _secureStorage;

  // Private constructor
  TokenManager._internal()
      : _secureStorage = const FlutterSecureStorage(
            aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ));

  // Keys for access and refresh tokens
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  /// Store tokens securely
  Future<void> storeTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);

    // Note: FCM token operations are now handled by individual services
    // that have access to ApiRepository (e.g., FcmTokenService)
  }

  /// Retrieve the access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Retrieve the refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Clear tokens from secure storage
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Logout method that clears all tokens
  /// Logout method that clears all tokens including FCM
  Future<void> logout() async {
    try {
      // Clear FCM token first
      await FcmTokenService.clearSavedFcmToken();

      // Clear all stored tokens
      await clearTokens();

      print('✅ [TOKEN] Logout completed - all tokens cleared');
    } catch (e) {
      print('❌ [TOKEN] Error during logout: $e');
    }
  }

  /// Handle user switch - clear tokens and prepare for new user
  Future<void> switchUser(String newUserId) async {
    try {
      // Handle FCM token switch
      await FcmTokenService.handleUserSwitch(newUserId);

      // Clear auth tokens
      await clearTokens();

      print('✅ [TOKEN] User switch completed');
    } catch (e) {
      print('❌ [TOKEN] Error during user switch: $e');
    }
  }

  /// Refresh the access token using the refresh token
  Future<void> refreshAccessToken(
      Future<Map<String, String>> Function(String refreshToken)
          apiRefreshToken) async {
    final refreshToken = await getRefreshToken();

    if (refreshToken == null) {
      throw Exception("Refresh token is not available.");
    }

    // Make API call to refresh the token
    final newTokens = await apiRefreshToken(refreshToken);

    // Update stored tokens
    await storeTokens(newTokens['accessToken']!, newTokens['refreshToken']!);
  }
}
