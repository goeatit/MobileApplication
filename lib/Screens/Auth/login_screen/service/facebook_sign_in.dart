import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';

class FacebookSignInService {
  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Get user data
        final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,picture.width(200)",
        );

        // Here you can handle the successful login
        // For example, send the data to your backend or navigate to home screen
        print('Facebook login successful');
        print('Name: ${userData['name']}');
        print('Email: ${userData['email']}');
        print('Profile picture: ${userData['picture']['data']['url']}');

        // Navigate to your desired screen
        // Navigator.pushReplacementNamed(context, '/home');
      } else if (result.status == LoginStatus.cancelled) {
        // Handle when user cancels the login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facebook login cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Handle when login fails
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facebook login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle any errors that occur during the login process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during Facebook login: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
  }
}
