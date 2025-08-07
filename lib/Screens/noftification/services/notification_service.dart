import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'background_message_handler.dart';
import 'fcm_token_service.dart';
import '../../Auth/login_screen/service/token_Storage.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeWithoutPermission() async {
    print('🔔 Initializing notification service without permission...');
    
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    print('✅ Background message handler set');
  }

  static Future<void> initialize(BuildContext context) async {
    print('🔔 Initializing notification service...');
    
    // Request permission for iOS
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

    print('📱 User granted permission: ${settings.authorizationStatus}');
    
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('❌ User denied notification permissions');
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
        print('🔔 Notification tapped: ${details.payload}');
        // Handle notification tap
        final payload = details.payload;
        if (payload != null) {
          try {
            final data = json.decode(payload);
            final orderId = data['orderId'];
            if (orderId != null) {
              print('📋 Navigating to order details for: $orderId');
              fetchOrderDetails(orderId, context);
            }
          } catch (e) {
            print('❌ Error parsing notification payload: $e');
            // Fallback for simple string payload
            fetchOrderDetails(payload, context);
          }
        }
      },
    );
    print('✅ Local notifications initialized');

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
    print('✅ Notification channel created');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Received FCM message in foreground!');
      print('📱 Message data: ${message.data}');
      print('📬 Notification: ${message.notification?.title} - ${message.notification?.body}');
      
      if (message.notification != null || message.data.isNotEmpty) {
        showNotification(message);
      } else {
        print('❌ No notification payload in message.');
      }
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification clicked!');
      print('📱 Message data: ${message.data}');
      final orderId = message.data['orderId'];
      if (orderId != null) {
        print('📋 Navigating to order details for: $orderId');
        fetchOrderDetails(orderId, context);
      } else {
        print('❌ No orderId found in notification data.');
      }
    });

    // Handle when app is terminated and opened from notification
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('🔔 App opened from terminated state');
      final orderId = initialMessage.data['orderId'];
      if (orderId != null) {
        print('📋 Navigating to order details for: $orderId');
        fetchOrderDetails(orderId, context);
      }
    }

    // Get FCM token and save to backend
    String? token = await FirebaseMessaging.instance.getToken();
    print('🔑 FCM Token: ${token?.substring(0, 20)}...');

    // Save FCM token after initialization if user is authenticated
    final authToken = await TokenManager().getAccessToken();
    if (authToken != null) {
      print('💾 Saving FCM token to backend...');
      await FcmTokenService.saveFcmTokenToBackend(authToken);
    } else {
      print('❌ No auth token available for FCM token save');
    }

    // Setup token refresh listener
    await FcmTokenService.setupFcmTokenListener(authToken);
    print('✅ Notification service initialization complete');
  }

  static Future<void> showNotification(RemoteMessage message) async {
    print('🔔 Showing local notification for: ${message.notification?.title}');
    
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
      ticker: 'Order Update',
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
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title ?? 'Order Update',
        message.notification?.body ?? 'Your order status has been updated',
        platformChannelSpecifics,
        payload: payload,
      );
      print('✅ Local notification shown successfully');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  static Future<void> fetchOrderDetails(
      String orderId, BuildContext context) async {
    try {
      print('📋 Fetching order details for: $orderId');

      // Navigate to orders screen to show updated status
      // You can customize this navigation based on your app structure
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/orders', // Replace with your orders screen route
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
      print('❌ Error handling order notification: $e');
    }
  }

  // FCM token saving is now handled by FcmTokenService
  // This method is kept for backward compatibility
  static Future<void> saveFcmTokenToBackend(String fcmToken) async {
    // This functionality has been moved to FcmTokenService
    print('ℹ️ Use FcmTokenService.saveFcmTokenToBackend() instead');
  }

  // Debug method to check FCM token status
  static Future<void> debugFcmTokenStatus() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final authToken = await TokenManager().getAccessToken();
      
      print('🔍 FCM Debug Info:');
      print('  - FCM Token: ${token?.substring(0, 20) ?? 'null'}...');
      print('  - Auth Token: ${authToken?.substring(0, 20) ?? 'null'}...');
      print('  - Should Save: ${await FcmTokenService.shouldSaveFcmToken()}');
    } catch (e) {
      print('❌ Error in FCM debug: $e');
    }
  }
}
