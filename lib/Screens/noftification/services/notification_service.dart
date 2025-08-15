import 'package:eatit/Screens/My_Booking/screen/my_bookings_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'background_message_handler.dart';
import 'fcm_token_service.dart';
import '../../Auth/login_screen/service/token_Storage.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeWithoutPermission() async {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Check if notification permissions are already granted
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

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
        final payload = details.payload;
        if (payload != null) {
          try {
            final data = json.decode(payload);
            final orderId = data['orderId'];
            if (orderId != null) {
              fetchOrderDetails(orderId, context);
            }
          } catch (e) {
            // Fallback for simple string payload
            fetchOrderDetails(payload, context);
          }
        }
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_status_channel',
      'Order Status',
      description: 'Order status updates',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null || message.data.isNotEmpty) {
        showNotification(message);
      }
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final orderId = message.data['orderId'];
      if (orderId != null) {
        fetchOrderDetails(orderId, context);
      }
    });

    // Handle when app is terminated and opened from notification
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final orderId = initialMessage.data['orderId'];
      if (orderId != null) {
        fetchOrderDetails(orderId, context);
      }
    }

    // Get FCM token and save to backend
    String? token = await FirebaseMessaging.instance.getToken();

    // Save FCM token after initialization if user is authenticated
    final authToken = await TokenManager().getAccessToken();
    if (authToken != null) {
      // Get user ID from token or user model
      final userModel = await _getUserModelFromToken(authToken);
      final userId = userModel?._id?.toString();

      // Note: FcmTokenService needs ApiRepository to be set before calling this
      // This should be set in SplashScreen or main app initialization
      if (FcmTokenService.getApiRepository != null) {
        await FcmTokenService.saveFcmTokenToBackend(authToken, userId);
      }
    }

    // Setup token refresh listener
    final userModel = await _getUserModelFromToken(authToken);
    final userId = userModel?._id?.toString();
    if (FcmTokenService.getApiRepository != null) {
      await FcmTokenService.setupFcmTokenListener(authToken, userId);
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    // Get system theme brightness
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
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
      ticker: 'Order Update',
      largeIcon: DrawableResourceAndroidBitmap(
          isDarkMode ? 'logo_white' : 'first_default'),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Create payload with order data
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
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  static Future<void> fetchOrderDetails(
      String orderId, BuildContext context) async {
    try {
      // Navigate to orders screen to show updated status
      Navigator.pushNamedAndRemoveUntil(
        context,
        MyBookingsScreen.routeName,
        (route) => route.isFirst,
      );
      // Optional: Show a snackbar with order update
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

  /// Extract user model from auth token (JWT parsing)
  static Future<dynamic> _getUserModelFromToken(String? authToken) async {
    if (authToken == null) return null;

    try {
      // JWT tokens have 3 parts separated by dots: header.payload.signature
      final parts = authToken.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed for base64 decoding
      final normalizedPayload = base64.normalize(payload);
      final decodedBytes = base64.decode(normalizedPayload);
      final decodedPayload = utf8.decode(decodedBytes);

      // Parse JSON payload
      final Map<String, dynamic> tokenData = json.decode(decodedPayload);

      // Return an object with _id property that can be accessed
      return {
        '_id': tokenData['userId'] ?? tokenData['id'] ?? tokenData['sub'],
        'email': tokenData['email'],
        'name': tokenData['name'],
      };
    } catch (e) {
      print('Error parsing JWT token: $e');
      return null;
    }
  }
}
