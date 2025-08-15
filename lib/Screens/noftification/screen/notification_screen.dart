import 'package:eatit/Screens/homes/screen/home_screen.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/Screens/noftification/services/notification_service.dart';
import 'package:eatit/Screens/noftification/services/fcm_token_service.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = "/notification-screen";

  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<RemoteMessage> _notifications = [];
  bool _isCheckingPermissions = true;
  bool _notificationsAlreadyEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    try {
      // Check if notifications are already enabled
      final areEnabled = await NotificationService.areNotificationsEnabled();
      
      if (areEnabled) {
        _notificationsAlreadyEnabled = true;
        // Navigate to home screen if notifications are already enabled
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, HomePage.routeName);
          }
        });
        return;
      }
      
      _initializeNotifications();
      _setupFcmListeners();
    } catch (e) {
      print('Error checking notification status: $e');
    } finally {
      setState(() {
        _isCheckingPermissions = false;
      });
    }
  }

  Future<void> _setupFcmListeners() async {
    // Set ApiRepository in FcmTokenService if available
    try {
      final apiRepository = Provider.of<ApiRepository>(context, listen: false);
      FcmTokenService.setApiRepository(apiRepository);
    } catch (e) {
      print('⚠️ ApiRepository not available in context: $e');
    }

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _notifications.insert(0, message);
      });
      NotificationService.flutterLocalNotificationsPlugin;
      NotificationService.showNotification(message);
    });
    
    // Notification tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationService.fetchOrderDetails(
        message.data['orderId'] ?? '',
        context,
      );
    });
    
    // Initial message (app opened from terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        NotificationService.fetchOrderDetails(
          message.data['orderId'] ?? '',
          context,
        );
      }
    });
  }

  Future<bool> _requestIOSNotificationPermission() async {
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

  Future<void> _checkPermissionAndNavigate(BuildContext context) async {
    bool granted = false;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      granted = true;
    } else {
      final status = await Permission.notification.status;
      granted = status.isGranted;
    }

    if (granted) {
      Navigator.pushReplacementNamed(context, HomePage.routeName);
    }
  }

  Future<void> _requestNotificationPermission(BuildContext context) async {
    await NotificationService.initialize(context);
    bool granted = false;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      granted = await _requestIOSNotificationPermission();
    } else {
      final status = await Permission.notification.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        await openAppSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please enable notifications in settings.")),
        );
        return;
      }
      granted = status.isGranted;
    }

    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notifications enabled!")),
      );
      await _checkPermissionAndNavigate(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied!")),
      );
    }
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initialize(context);
  }

  Future<void> _resendNotification(BuildContext context) async {
    bool granted = false;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      granted = true;
    } else {
      final status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        openAppSettings();
        return;
      }
      granted = status.isGranted;
    }

    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Resending local notification...")),
      );
      // Show a test notification
      await NotificationService.flutterLocalNotificationsPlugin.show(
        0,
        "Order Update",
        "Your order is being prepared!",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'order_status_channel',
            'Order Status',
            channelDescription: 'Order status updates',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('notification'),
            playSound: true,
          ),
        ),
      );
      await _checkPermissionAndNavigate(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification permission not granted.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking permissions
    if (_isCheckingPermissions) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If notifications are already enabled, show loading (will navigate automatically)
    if (_notificationsAlreadyEnabled) {
      return const Scaffold(
        body: Center(
          child: Text('Notifications already enabled, redirecting...'),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 400,
                height: 250,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/push_notifications.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Always know the status of your order',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: Color(0xFF1D1929),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Push notifications are used to provide updates on your order. You can change this.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: Color(0xFF1D1929),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _requestNotificationPermission(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Enable Push Notifications',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _resendNotification(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E5E5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Send it again',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1929),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Notification list
              if (_notifications.isNotEmpty)
                const Text(
                  'Recent Notifications:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (_notifications.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final msg = _notifications[index];
                      return ListTile(
                        title: Text(msg.notification?.title ?? 'Order Update'),
                        subtitle: Text(msg.notification?.body ?? ''),
                        onTap: () {
                          if (msg.data['orderId'] != null) {
                            NotificationService.fetchOrderDetails(
                              msg.data['orderId'],
                              context,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
