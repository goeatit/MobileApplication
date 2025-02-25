// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class GoogleLoginService {
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
      final backendResponse = await http.post(
        Uri.parse("https://api.eatitgo.in/api/auth/google/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": userInfo["email"],
          "name": userInfo["name"],
          "avatarurl": userInfo["picture"],
        }),
      );

      if (backendResponse.statusCode != 200) {
        throw Exception("Backend login failed.");
      }

      final backendData = json.decode(backendResponse.body);

      // Store the token securely
      // await _secureStorage.write(key: "token", value: backendData["token"]);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Success: Enjoy your meal with EatIt!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate or close modal
      Navigator.pop(context);
    } catch (error) {
      print("Login failed: $error");
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
