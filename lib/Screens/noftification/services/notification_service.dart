import 'package:eatit/Screens/My_Booking/screen/my_bookings_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'background_message_handler.dart';
import 'fcm_token_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeWithoutPermission() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<bool> areNotificationsEnabled() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print('Error checking notification permissions: $e');
      return false;
    }
  }

  static Future<void> initialize(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions first
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // Initialize local notifications BEFORE setting up listeners
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        final payload = details.payload;
        if (payload != null) {
          try {
            final data = json.decode(payload);
            final orderId = data['orderId'];
            if (orderId != null) {
              fetchOrderDetails(orderId, context);
            }
          } catch (e) {
            fetchOrderDetails(payload, context);
          }
        }
      },
    );

    // Create notification channel BEFORE setting up listeners
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_status_channel',
      'Order Status',
      description: 'Order status updates',
      importance: Importance.max,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // NOW set up the message listeners
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      if (message.notification != null || message.data.isNotEmpty) {
        showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final orderId = message.data['orderId'];
      if (orderId != null) {
        fetchOrderDetails(orderId, context);
      }
    });

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final orderId = initialMessage.data['orderId'];
      if (orderId != null) {
        fetchOrderDetails(orderId, context);
      }
    }

    await FcmTokenService.saveTokenIfNeeded();
    await FcmTokenService.setupFcmTokenListener();
  }

  static Future<void> checkNotificationPermissionsAndNavigate(
      BuildContext context,
      {required String enabledRouteName,
      required String disabledRouteName}) async {
    try {
      final areEnabled = await areNotificationsEnabled();

      if (areEnabled) {
        if (!(context.mounted)) return;
        Navigator.pushReplacementNamed(context, enabledRouteName);
      } else {
        if (!(context.mounted)) return;
        Navigator.pushReplacementNamed(context, disabledRouteName);
      }
    } catch (e) {
      print('Error in checkNotificationPermissionsAndNavigate: $e');
      if (!(context.mounted)) return;
      Navigator.pushReplacementNamed(context, disabledRouteName);
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_status_channel',
      'Order Status',
      channelDescription: 'Order status updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      ticker: 'Order Update',
      largeIcon: DrawableResourceAndroidBitmap('first_default'),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final payload = json.encode({
      'orderId': message.data['orderId'],
      'status': message.data['status'],
      'restaurantName': message.data['restaurantName'],
      'type': message.data['type'] ?? 'order_status_update',
    });

    try {
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title ?? 'Order Update',
        message.notification?.body ?? 'Your order status has been updated',
        platformChannelSpecifics,
        payload: payload,
      );
      print('✅ Notification displayed successfully');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  static Future<void> fetchOrderDetails(
      String orderId, BuildContext context) async {
    try {
      Navigator.pushNamedAndRemoveUntil(
        context,
        MyBookingsScreen.routeName,
        (route) => route.isFirst,
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
