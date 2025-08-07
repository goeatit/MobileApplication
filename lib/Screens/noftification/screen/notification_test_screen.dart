import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eatit/Screens/Auth/login_screen/service/token_Storage.dart';
import 'package:eatit/Screens/noftification/services/notification_debug.dart';

class NotificationTestScreen extends StatefulWidget {
  static const routeName = "/notification-test";
  
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String _status = "Ready to test";
  bool _isLoading = false;

  Future<void> _testNotification() async {
    setState(() {
      _isLoading = true;
      _status = "Sending test notification...";
    });

    try {
      final authToken = await TokenManager().getAccessToken();
      if (authToken == null) {
        setState(() {
          _status = "❌ No auth token found";
          _isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.31.5:8000/mobile/test/notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _status = data['success'] 
            ? "✅ Test notification sent successfully!" 
            : "❌ Failed to send notification";
        });
      } else {
        setState(() {
          _status = "❌ Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _status = "❌ Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _debugSetup() async {
    setState(() {
      _isLoading = true;
      _status = "Running debug setup...";
    });

    await NotificationDebug.debugNotificationSetup();
    
    setState(() {
      _status = "✅ Debug setup complete - check console logs";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _testNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Send Test Notification',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _debugSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Run Debug Setup',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Instructions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Run "Debug Setup" to check FCM configuration'),
                    Text('2. Send a "Test Notification" to verify backend'),
                    Text('3. Check console logs for detailed information'),
                    Text('4. Ensure you are logged in and have permissions'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}