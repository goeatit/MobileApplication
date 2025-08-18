import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatit/Screens/Auth/login_screen/service/token_Storage.dart';
import 'package:eatit/Screens/CompleteYourProfile/Screen/Complete_your_profile_screen.dart';
import 'package:eatit/Screens/location/screen/location_screen.dart';
import 'package:eatit/Screens/noftification/services/fcm_token_service.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eatit/Screens/splash_screen/service/SplashScreenService.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FacebookSignInService {
  final ApiRepository _apiRepository;

  // CancelToken? _cancelToken;

  FacebookSignInService({required ApiRepository apiRepository})
      : _apiRepository = apiRepository;
  late SplashScreenServiceInit? _splashScreenServiceInit;

  Future<void> _saveFcmToken() async {
    try {
      // Get user ID from the user data
      final userData =
          await FacebookAuth.instance.getUserData(fields: "email,name");
      String? userId = userData['email']; // Use email as user ID

      // Set ApiRepository in FcmTokenService
      FcmTokenService.setApiRepository(_apiRepository);

      // Save FCM token to backend using the service
      await FcmTokenService.saveFcmTokenToBackend(null, userId);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      // Initiate Facebook sign-in
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Get user data
        final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,picture.width(200)",
        );

        if (userData['email'] == null || userData['name'] == null) {
          throw Exception(
              "Failed to get required user information from Facebook");
        }

        // Post user data to your backend API
        TokenManager _tokenManager = TokenManager();

        final responseFromBackend = await _apiRepository.facebookLogin(
          userData['email'],
          userData['name'],
          userData['picture']?['data']?['url'] ?? '',
          result.accessToken!.token,
        );

        if (responseFromBackend != null) {
          if (responseFromBackend.statusCode == 200) {
            var user = UserModel.fromJson(responseFromBackend.data);
            await _tokenManager.storeTokens(
                user.accessToken, user.refreshToken);
            context.read<UserModelProvider>().updateUserModel(user.user);

            // Fetch cart items after successful login
            final apiRepository =
                Provider.of<ApiRepository>(context, listen: false);
            _splashScreenServiceInit =
                SplashScreenServiceInit(apiRepository: apiRepository);
            final cartRes =
                await _splashScreenServiceInit!.fetchCartItems(context);
            if (cartRes != null && cartRes.statusCode == 200) {
              final cartData = cartRes.data['cart'];
              context
                  .read<CartProvider>()
                  .loadGroupedCartFromResponse(cartData);
              _splashScreenServiceInit = null;
            }

            // Save FCM token after successful authentication
            await _saveFcmToken();

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Login Success: Enjoy your meal with EatIt!"),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate based on user profile completion
            if (user.user.name == null || user.user.phoneNumber == null) {
              Navigator.pushReplacementNamed(
                context,
                CreateAccountScreen.routeName,
              );
            } else {
              Navigator.pushReplacementNamed(
                context,
                LocationScreen.routeName,
              );
            }
          } else {
            throw Exception("Failed to authenticate with backend");
          }
        } else {
          throw Exception("No response from server");
        }
      } else if (result.status == LoginStatus.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Facebook login was cancelled"),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception("Facebook login failed");
      }
    } catch (e) {
      // Handle any errors that occur during the login process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error during Facebook login: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
      // Sign out from Facebook in case of error
      await FacebookAuth.instance.logOut();
    }
  }

  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
  }
}
