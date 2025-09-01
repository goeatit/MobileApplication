import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationUtils {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize notification settings
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iOSInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

  }

  /// Request iOS permission via flutter_local_notifications
  static Future<bool> requestIOSNotificationPermission() async {
    final iosPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final result = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    return false;
  }

  /// Unified request (permission_handler + FirebaseMessaging)
  static Future<bool> requestNotificationPermission(
      BuildContext context) async {
    bool granted = false;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Ask iOS local permission
      granted = await requestIOSNotificationPermission();

      // Ask FCM permission
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = granted ||
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } else {
      // Android: ask OS-level permission
      final status = await Permission.notification.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please enable notifications in settings.")),
        );
        await openAppSettings();
        return false;
      }
      granted = status.isGranted;

      // Confirm via Firebase
      final settings = await FirebaseMessaging.instance.requestPermission();
      granted = granted ||
          settings.authorizationStatus == AuthorizationStatus.authorized;
    }

    return granted;
  }

  /// Check permission and navigate if allowed
  static Future<void> checkPermissionAndNavigate(
      BuildContext context, String routeName) async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  /// Resend test notification
  static Future<void> resendNotification(
      BuildContext context, String routeName) async {
    bool granted = await requestNotificationPermission(context);

    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Resending local notification...")),
      );
      await showLocalNotification();
      await checkPermissionAndNavigate(context, routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification permission not granted.")),
      );
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
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

  /// Show local notification
  static Future<void> showLocalNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'order_updates_channel',
      'Order Updates',
      channelDescription: 'Notifications about your order status',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Order Update',
      'Your order is being prepared!',
      platformDetails,
      payload: 'orderId=12345',
    );
  }
}
