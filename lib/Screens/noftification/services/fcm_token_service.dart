import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/api_repository.dart';

class FcmTokenService {
  final ApiRepository _apiRepository;
  static const _tokenKey = 'fcm_device_token';


  /// Set the ApiRepository instance for FCM token operations
  FcmTokenService({required ApiRepository apiRepository})
      : _apiRepository = apiRepository;

  /// **1. Setup the listener when the app starts.**
  /// This should be called once, e.g., in your SplashScreen.
  /// It ensures that if FCM refreshes the token in the background, your server is updated.
  Future<void> setupFcmTokenListener() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('FCM token refreshed. Updating server...');
      _sendTokenToServer(newToken);
    });
  }


  Future<void> _sendTokenToServer(String token) async {
    try {
      // Avoids sending the same token repeatedly in the same session.
      final prefs = await SharedPreferences.getInstance();
      // final savedToken = prefs.getString(_tokenKey);
      // // if (savedToken == token) {
      // //   print('Token is already up-to-date on the server.');
      // //   return;
      // // }

      final response = await _apiRepository.saveFcmToken(token);
      if (response != null && response.statusCode == 200) {
        // Cache the token locally upon successful save.
        await prefs.setString(_tokenKey, token);
        print('FCM token successfully saved to server.');
      }
    } catch (e) {
      print('Error sending FCM token to server: $e');
    }
  }
  /// **2. On user login, sync the token with the backend.**
  /// This ensures the current device token is associated with the logged-in user.
  Future<void> syncTokenOnLogin() async {
    // Get the current token from FCM. This is safe to call anytime.
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('Syncing FCM token on login: $token');
      await _sendTokenToServer(token);
    }else{
      print('FCM token is null, cannot sync with server.');
    }
  }

  /// **3. On user logout, remove the token association from the backend.**
  Future<void> removeTokenOnLogout() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Tell the backend to disassociate this token from the logged-out user.
        await _apiRepository.clearFcmToken(token);
      }
    } catch (e) {
      print('Error removing FCM token on logout: $e');
    }
  }

}
