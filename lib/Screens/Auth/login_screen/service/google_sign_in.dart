// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatit/Screens/Auth/login_screen/service/token_Storage.dart';
import 'package:eatit/Screens/CompleteYourProfile/Screen/Complete_your_profile_screen.dart';
import 'package:eatit/Screens/location/screen/location_screen.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/main.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eatit/Screens/splash_screen/service/SplashScreenService.dart';
import 'package:eatit/provider/cart_dish_provider.dart';

class GoogleLoginService {
  final ApiRepository _apiRepository;
  // CancelToken? _cancelToken;
  GoogleLoginService({ApiRepository? apiRepository})
      : _apiRepository =
            apiRepository ?? ApiRepository(NetworkManager(Connectivity()));
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      // Initiate Google sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("User cancelled Google login.");
        return;
      }

      // Fetch Google OAuth access token
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? accessToken = googleAuth.accessToken;
      if (accessToken == null) {
        print("Failed to retrieve access token.");
        return;
      }

      // Fetch user info from Google API
      final userInfoResponse = await http.get(
        Uri.parse(
            "https://www.googleapis.com/oauth2/v1/userinfo?access_token=$accessToken"),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Accept": "application/json",
        },
      );

      if (userInfoResponse.statusCode != 200) {
        throw Exception("Failed to fetch Google user info.");
      }

      final userInfo = json.decode(userInfoResponse.body);

      // Post user data to your backend API
      TokenManager _tokenManager = TokenManager();

      final responseFromBackend = await _apiRepository.googleLogin(
          userInfo["email"], userInfo["name"], userInfo["picture"]);
      // print(responseFromBackend);
      if (responseFromBackend != null) {
        if (responseFromBackend.statusCode == 200) {
          var user = UserModel.fromJson(responseFromBackend.data);
          await _tokenManager.storeTokens(user.accessToken, user.refreshToken);
          context.read<UserModelProvider>().updateUserModel(user.user);

          // Fetch cart items after successful login
          final splashService = SplashScreenServiceInit();
          final cartRes = await splashService.fetchCartItems(context);
          if (cartRes != null && cartRes.statusCode == 200) {
            final cartData = cartRes.data['cart'];
            context.read<CartProvider>().loadGroupedCartFromResponse(cartData);
          }

          if (user.user.name == null || user.user.phoneNumber == null) {
            Navigator.pushReplacementNamed(
                context, CreateAccountScreen.routeName);
          } else {
            Navigator.pushReplacementNamed(context, LocationScreen.routeName);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Failed. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Success: Enjoy your meal with EatIt!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate or close modal
      // Navigator.pop(context);
    } catch (error) {
      if (kDebugMode) {
        print("Login failed: $error");
      }
      await _googleSignIn.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
