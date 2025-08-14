import 'package:eatit/Screens/noftification/services/fcm_token_service.dart';
import 'package:eatit/Screens/noftification/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationHelper {
  /// Initialize notifications and save FCM token after user login
  static Future<void> initializeAfterLogin(
      BuildContext context, String authToken) async {
    try {
      // Initialize notification service with permissions
      await NotificationService.initialize(context);

      // Note: FCM token operations are now handled by individual services
      // that have access to ApiRepository (e.g., FcmTokenService)
      // The ApiRepository should be set in FcmTokenService before calling this

      print('Notifications initialized successfully after login');
    } catch (e) {
      print('Error initializing notifications after login: $e');
    }
  }

  /// Check if FCM token needs to be saved and save it
  static Future<void> ensureFcmTokenSaved([String? authToken]) async {
    try {
      if (await FcmTokenService.shouldSaveFcmToken()) {
        // Note: ApiRepository must be set in FcmTokenService before calling this
        await FcmTokenService.saveFcmTokenToBackend(authToken);
      }
    } catch (e) {
      print('Error ensuring FCM token is saved: $e');
    }
  }

  /// Handle notification when app is opened from notification
  static Future<void> handleNotificationTap(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      final orderId = data['orderId'];
      final status = data['status'];
      final restaurantName = data['restaurantName'];

      if (orderId != null) {
        // Navigate to order details or orders list
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/orders', // Replace with your orders screen route
          (route) => route.isFirst,
        );

        // Show status update message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status != null
                ? 'Order $orderId is now $status'
                : 'Order $orderId has been updated'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }
}
