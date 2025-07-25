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

  // SplashScreenServiceInit screenServiceInit = SplashScreenServiceInit();
  // MyBookingService myBookingService = MyBookingService();
  late SplashScreenServiceInit _screenServiceInit;
  late MyBookingService _myBookingService;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Initialize app data and check authentication status
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
      // Call this here once dependencies are ready

      _servicesInitialized = true;
    }
  }

  Future<void> _initializeApp() async {
    // Load cart data
    await context.read<CartProvider>().loadCartFromStorage();

    // Check if it's the first time opening the app
    // await _checkFirstTimeUser();

    // Check if user is authenticated
    await _checkAuthentication();
  }

  // Future<void> _checkFirstTimeUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   _isFirstTime = prefs.getBool('first_time') ?? true;
  //
  //   if (_isFirstTime) {
  //     // Set first_time to false for future app launches
  //     await prefs.setBool('first_time', false);
  //   }
  // }

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
          if (!mounted) return; // <-- Add here

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to load cart items."),
              backgroundColor: Colors.red,
            ),
          );
        }

        // context.read<CartProvider>().loadCartFromStorage();
        // User is authenticated, navigate to location screen
        var fetched = await _myBookingService.fetchOrderDetails();
        if (!mounted) return;

        if (fetched != null) {
          context.read<MyBookingProvider>().setMyBookings(fetched.user);
        }

        var user = context.read<UserModelProvider>().userModel;
        if (user != null) {
          if (user.phoneNumber == null) {
            if (!mounted) return; // <-- Add here!
            Navigator.pushReplacementNamed(
                context, CreateAccountScreen.routeName);
          } else {
            if (!mounted) return; // <-- Add here!
            Navigator.pushReplacementNamed(context, LocationScreen.routeName);
          }
        }
      }
    } else {
      // Returning user but not logged in
      if (!mounted) return; // <-- Add here!
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
