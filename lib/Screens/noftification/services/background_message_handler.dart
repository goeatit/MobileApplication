import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';


// This needs to be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    // Show local notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_status_channel',
      'Order Status',
      channelDescription: 'Order status updates',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification'),
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Create payload with order data
    final payload = json.encode({
      'orderId': message.data['orderId'],
      'status': message.data['status'],
      'restaurantName': message.data['restaurantName'],
      'type': message.data['type'] ?? 'order_status_update',
    });

    try {
      await FlutterLocalNotificationsPlugin().show(
        message.hashCode,
        message.notification?.title ?? 'Order Update',
        message.notification?.body ?? 'Your order status has been updated',
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

}
