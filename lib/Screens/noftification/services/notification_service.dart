import 'package:eatit/Screens/My_Booking/screen/my_bookings_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'background_message_handler.dart';
import 'fcm_token_service.dart';

class NotificationService {
  static Future<void> initializeWithoutPermission() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  static Future<void> fetchOrderDetails(
      String orderId, BuildContext context) async {
    try {
      Navigator.pushNamed(
        context,
        MyBookingsScreen.routeName,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order $orderId status updated'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error fetching order details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch order details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
