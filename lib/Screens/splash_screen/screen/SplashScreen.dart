import 'package:eatit/Screens/CompleteYourProfile/Screen/Complete_your_profile_screen.dart';
import 'package:eatit/Screens/My_Booking/service/My_Booking_service.dart';
import 'package:eatit/Screens/splash_screen/service/SplashScreenService.dart';
import 'package:eatit/provider/my_booking_provider.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:eatit/Screens/Auth/login_screen/service/token_Storage.dart';
import 'package:eatit/Screens/first_time_screen/screen/first_time_screen.dart';
import 'package:eatit/Screens/location/screen/location_screen.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:eatit/Screens/noftification/services/notification_service.dart';
import 'package:eatit/Screens/noftification/services/fcm_token_service.dart';
import 'package:eatit/Screens/noftification/services/background_message_handler.dart';
import 'package:eatit/Screens/homes/screen/home_screen.dart';
import 'package:eatit/Screens/noftification/screen/notification_screen.dart';

import '../../../api/api_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TokenManager _tokenManager = TokenManager();
  bool _servicesInitialized = false;
  bool _firebaseInitialized = false;

  late SplashScreenServiceInit _screenServiceInit;
  late MyBookingService _myBookingService;
  late FcmTokenService _fcmTokenService;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeApp();
    });
  }

  Future<void> _initializeFirebase() async {
    print(">>> Initializing Firebase...");
    try {
      if (!_firebaseInitialized) {
        final init = await Firebase.initializeApp();
        print(">>> Firebase initialized: $init");
        await NotificationService.initializeWithoutPermission();
        _firebaseInitialized = true;
      } else {
        print(">>> Firebase already initialized");
      }
    } catch (e, s) {
      print('!!! Error initializing Firebase: $e');
      print(s);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_servicesInitialized) {
      // Initialize services only once
      _screenServiceInit =
          SplashScreenServiceInit(apiRepository: context.read<ApiRepository>());
      _myBookingService =
          MyBookingService(apiRepository: context.read<ApiRepository>());
      _fcmTokenService =
          FcmTokenService(apiRepository: context.read<ApiRepository>());
      _servicesInitialized = true;
    }
  }

  Future<void> _initializeApp() async {
    // Wait for Firebase to be initialized
    print(">>> Starting app initialization...");
    await _initializeFirebase();
    print(">>> Firebase done, now loading cart...");
    if (!mounted) return;

    // Load cart data
    await context.read<CartProvider>().loadCartFromStorage();

    // Check if user is authenticated
    await _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final accessToken = await _tokenManager.getAccessToken();
    final refreshToken = await _tokenManager.getRefreshToken();

    if (!mounted) return;

    if (accessToken != null && refreshToken != null) {
      final response = await _screenServiceInit.checkInitProfile(context);
      if (!mounted) return;

      if (response) {
        final res = await _screenServiceInit.fetchCartItems(context);
        if (!mounted) return;

        if (res != null && res.statusCode == 200) {
          // Successfully fetched cart items, update the cart provider
          final data = res.data['cart'];
          context.read<CartProvider>().loadGroupedCartFromResponse(data);
          print("cart Loaded ");
        } else {
          // Failed to fetch cart items, handle accordingly
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to load cart items."),
              backgroundColor: Colors.red,
            ),
          );
        }

        var fetched = await _myBookingService.fetchOrderDetails();
        if (!mounted) return;

        if (fetched != null) {
          context.read<MyBookingProvider>().setMyBookings(fetched.user);
        }
        await _fcmTokenService.syncTokenOnLogin();

        var user = context
            .read<UserModelProvider>()
            .userModel;
        if (user != null) {
          if (user.phoneNumber == null) {
            if (!mounted) return;
            Navigator.pushReplacementNamed(
                context, CreateAccountScreen.routeName);
          } else {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, LocationScreen.routeName);

            // On login: clear local FCM token cache and initialize/save once if backend needs it
          }
        }
      }
    } else {
      // Returning user but not logged in
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(FirstTimeScreen.routeName);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _myBookingService.dispose();
    _servicesInitialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset("assets/svg/first_Default.svg"),
      ),
    );
  }
}
