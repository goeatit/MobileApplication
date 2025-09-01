import 'package:eatit/Screens/noftification/services/fcm_token_service.dart';
import 'package:eatit/Screens/noftification/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:eatit/Screens/My_Booking/screen/my_bookings_screen.dart';

class NotificationHelper {

  /// Handle notification when app is opened from notification
  static Future<void> handleNotificationTap(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      final orderId = data['orderId'];
      final status = data['status'];

      if (orderId != null) {
        // Navigate to order details or orders list
        Navigator.pushNamed(
          context,
          MyBookingsScreen.routeName,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to handle notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
