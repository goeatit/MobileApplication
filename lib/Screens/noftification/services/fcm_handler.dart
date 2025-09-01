import 'dart:async';

import 'package:eatit/Screens/noftification/services/notification_helper.dart';
import 'package:eatit/Screens/noftification/services/notification_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FCMHandler {
  /// Initializes all FCM listeners and handlers.
  /// Call this from the initState of a persistent widget like HomePage.
  void initializeListeners(BuildContext context) {
    _setupFcmOnMessageListener(context);
    _setupInteractedMessage(context);
  }

  /// Sets up the listener for messages that arrive when the app is in the foreground.
  void _setupFcmOnMessageListener(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('✅ GOT A MESSAGE WHILST IN THE FOREGROUND!');
      if (message.notification != null) {
        // Show a SnackBar to alert the user
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text(message.notification?.title ?? "New Message"),
        //   action: SnackBarAction(
        //     label: "View",
        //     onPressed: () => _handleMessage(context, message),
        //   ),
        // ));
        // _showTopNotification(context, message);
        NotificationUtils.showNotification(message);
      }
    });
  }

  /// Sets up handlers for messages that are tapped by the user,
  /// opening the app from a background or terminated state.
  Future<void> _setupInteractedMessage(BuildContext context) async {
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null && context.mounted) {
      _handleMessage(context, initialMessage);
    }

    // Also handle any messages that are tapped when the app is in the background.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(context, message);
    });
  }

  /// Central handler that calls your NotificationHelper.
  void _handleMessage(BuildContext context, RemoteMessage message) {
    NotificationHelper.handleNotificationTap(context, message.data);
  }

  void _showTopNotification(BuildContext context, RemoteMessage message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10)
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: Color(0xFFF8951D)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message.notification?.title ?? "New Message",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (message.notification?.body != null)
                        Text(message.notification!.body!,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    overlayEntry.remove();
                    _handleMessage(context, message);
                  },
                  child:
                      Text("View", style: TextStyle(color: Color(0xFFF8951D))),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Timer(Duration(seconds: 4), () => overlayEntry.remove());
  }
}
