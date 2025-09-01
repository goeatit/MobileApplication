import 'package:eatit/Screens/homes/screen/home_screen.dart';
import 'package:eatit/Screens/location/screen/location_screen.dart';
import 'package:eatit/Screens/noftification/services/fcm_token_service.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../services/notification_utils.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = "/notification-screen";

  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    NotificationUtils.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fcmTokenService =
          FcmTokenService(apiRepository: Provider.of(context, listen: false));
      fcmTokenService.setupFcmTokenListener();
      await NotificationUtils.checkPermissionAndNavigate(
          context, HomePage.routeName);
    });
  }

  void _requestNotificationPermission(BuildContext context) async {
    final granted =
        await NotificationUtils.requestNotificationPermission(context);
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notifications enabled!")),
      );
      await NotificationUtils.checkPermissionAndNavigate(
          context, HomePage.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => NotificationUtils.resendNotification(
                      context, HomePage.routeName),
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
              // if (_notifications.isNotEmpty)
              //   const Text(
              //     'Recent Notifications:',
              //     style: TextStyle(
              //       fontSize: 18,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // if (_notifications.isNotEmpty)
              //   SizedBox(
              //     height: 200,
              //     child: ListView.builder(
              //       itemCount: _notifications.length,
              //       itemBuilder: (context, index) {
              //         final msg = _notifications[index];
              //         return ListTile(
              //           title: Text(msg.notification?.title ?? 'Order Update'),
              //           subtitle: Text(msg.notification?.body ?? ''),
              //           onTap: () {
              //             if (msg.data['orderId'] != null) {
              //               NotificationService.fetchOrderDetails(
              //                 msg.data['orderId'],
              //                 context,
              //               );
              //             }
              //           },
              //         );
              //       },
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
