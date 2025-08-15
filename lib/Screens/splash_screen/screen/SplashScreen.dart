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
  bool _isFirstTime = true;
  bool _servicesInitialized = false;
  bool _firebaseInitialized = false;

  late SplashScreenServiceInit _screenServiceInit;
  late MyBookingService _myBookingService;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Initialize Firebase and FCM
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      if (!_firebaseInitialized) {
        await Firebase.initializeApp();

        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler);

        // Initialize notification service without requesting permissions
        await NotificationService.initializeWithoutPermission();

        // Setup FCM token refresh listener
        await FcmTokenService.setupFcmTokenListener();

        _firebaseInitialized = true;
        print(' Firebase and FCM initialization complete');
      }
    } catch (e) {
      print(' Error initializing Firebase: $e');
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeApp();
      });

      _servicesInitialized = true;
    }
  }

  Future<void> _initializeApp() async {
    // Wait for Firebase to be initialized
    while (!_firebaseInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Set ApiRepository in FcmTokenService
    final apiRepository = context.read<ApiRepository>();
    FcmTokenService.setApiRepository(apiRepository);

    // Load cart data
    await context.read<CartProvider>().loadCartFromStorage();

    // Check if user is authenticated
    await _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Add a delay to show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check if access token and refresh token exist
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

        var user = context.read<UserModelProvider>().userModel;
        if (user != null) {
          if (user.phoneNumber == null) {
            if (!mounted) return;
            Navigator.pushReplacementNamed(
                context, CreateAccountScreen.routeName);
          } else {
            if (!mounted) return;

            // Save FCM token for authenticated user
            try {
              String? userId = user.phoneNumber ?? user.useremail;
              if (userId != null) {
                print(
                    '🔑 [SPLASH] Saving FCM token for authenticated user: $userId');
                await FcmTokenService.saveFcmTokenToBackend(null, userId);

                // Setup FCM token refresh listener for this user
                await FcmTokenService.setupFcmTokenListener(null, userId);
              }
            } catch (e) {
              print('❌ [SPLASH] Error saving FCM token: $e');
            }

            // Check notification permissions before navigating
            await NotificationService.checkNotificationPermissionsAndNavigate(
              context,
              enabledRouteName: LocationScreen.routeName,
              disabledRouteName: NotificationScreen.routeName,
            );
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
