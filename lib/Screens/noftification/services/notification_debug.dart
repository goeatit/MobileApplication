import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:eatit/Screens/noftification/services/fcm_token_service.dart';
import 'package:eatit/Screens/Auth/login_screen/service/token_Storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationDebug {
  static Future<void> debugNotificationSetup() async {
    print('🔍 [DEBUG] Starting comprehensive notification debug...');
    
    // Check FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('🔍 [DEBUG] Current FCM Token: ${fcmToken?.substring(0, 50)}...');
    
    // Check auth token
    String? authToken = await TokenManager().getAccessToken();
    print('🔍 [DEBUG] Auth Token available: ${authToken != null}');
    if (authToken != null) {
      print('🔍 [DEBUG] Auth Token: ${authToken.substring(0, 50)}...');
    }
    
    // Check notification permissions
    NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
    print('🔍 [DEBUG] Notification permission: ${settings.authorizationStatus}');
    
    // Check saved FCM token status
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('saved_fcm_token');
    final isTokenSaved = prefs.getBool('fcm_token_saved') ?? false;
    print('🔍 [DEBUG] Saved FCM Token: ${savedToken?.substring(0, 50) ?? 'null'}...');
    print('🔍 [DEBUG] Token Saved Flag: $isTokenSaved');
    
    // Check if tokens match
    if (fcmToken != null && savedToken != null) {
      print('🔍 [DEBUG] Tokens match: ${fcmToken == savedToken}');
    }
    
    // Test FCM token save
    if (authToken != null) {
      print('🔍 [DEBUG] Testing FCM token save...');
      await FcmTokenService.saveFcmTokenToBackend(authToken);
    }
    
    // Test should save logic
    final shouldSave = await FcmTokenService.shouldSaveFcmToken();
    print('🔍 [DEBUG] Should save FCM token: $shouldSave');
    
    print('🔍 [DEBUG] Debug complete');
  }
  
  static void setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔍 [DEBUG] Foreground message received:');
      print('🔍 [DEBUG] - Message ID: ${message.messageId}');
      print('🔍 [DEBUG] - Title: ${message.notification?.title}');
      print('🔍 [DEBUG] - Body: ${message.notification?.body}');
      print('🔍 [DEBUG] - Data: ${message.data}');
      print('🔍 [DEBUG] - Sent Time: ${message.sentTime}');
      print('🔍 [DEBUG] - From: ${message.from}');
    });
  }
  
  static void setupBackgroundListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔍 [DEBUG] Background message opened:');
      print('🔍 [DEBUG] - Message ID: ${message.messageId}');
      print('🔍 [DEBUG] - Title: ${message.notification?.title}');
      print('🔍 [DEBUG] - Body: ${message.notification?.body}');
      print('🔍 [DEBUG] - Data: ${message.data}');
    });
  }

  static Future<void> testFcmTokenSave() async {
    print('🧪 [TEST] Testing FCM token save...');
    
    final authToken = await TokenManager().getAccessToken();
    if (authToken == null) {
      print('❌ [TEST] No auth token available');
      return;
    }
    
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      print('❌ [TEST] No FCM token available');
      return;
    }
    
    print('🧪 [TEST] Auth Token: ${authToken.substring(0, 30)}...');
    print('🧪 [TEST] FCM Token: ${fcmToken.substring(0, 30)}...');
    
    try {
      await FcmTokenService.saveFcmTokenToBackend(authToken);
      print('✅ [TEST] FCM token save test completed');
    } catch (e) {
      print('❌ [TEST] FCM token save test failed: $e');
    }
  }

  static Future<void> checkNotificationPermissions() async {
    print('🔍 [PERMISSIONS] Checking notification permissions...');
    
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    print('🔍 [PERMISSIONS] Authorization Status: ${settings.authorizationStatus}');
    print('🔍 [PERMISSIONS] Alert: ${settings.alert}');
    print('🔍 [PERMISSIONS] Badge: ${settings.badge}');
    print('🔍 [PERMISSIONS] Sound: ${settings.sound}');
    
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('⚠️ [PERMISSIONS] Notifications are denied!');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ [PERMISSIONS] Notifications are authorized!');
    } else {
      print('❓ [PERMISSIONS] Notification status is unclear');
    }
  }

  static Future<void> logAllDebugInfo() async {
    print('📊 [DEBUG] === COMPREHENSIVE DEBUG INFO ===');
    
    await debugNotificationSetup();
    await checkNotificationPermissions();
    await testFcmTokenSave();
    
    print('📊 [DEBUG] === END DEBUG INFO ===');
  }
}