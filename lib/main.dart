import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatit/Screens/splash_screen/screen/SplashScreen.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/my_booking_provider.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:eatit/provider/saved_restaurants_provider.dart';
import 'package:eatit/provider/selected_category_provider.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:eatit/routes/main_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_repository.dart';
import 'api/network_manager.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  final connectivity = Connectivity();
  final networkManager = NetworkManager(connectivity);
  final apiRepository = ApiRepository(networkManager);
  runApp(MultiProvider(
    providers: [
      Provider<Connectivity>.value(value: connectivity),
      Provider<NetworkManager>.value(value: networkManager),
      Provider<ApiRepository>.value(value: apiRepository),


      // different providers
      ChangeNotifierProvider(create: (context) => CartProvider()),
      ChangeNotifierProvider(create: (context) => OrderTypeProvider()),
      ChangeNotifierProvider(create: (context) => UserModelProvider()),
      ChangeNotifierProvider(create: (context) => OrderProvider()),
      ChangeNotifierProvider(create: (context) => SavedRestaurantsProvider()),
      ChangeNotifierProvider(create: (_) => SelectedCategoryProvider()),
      ChangeNotifierProvider(create: (context) => MyBookingProvider()),
    ],
    child: const MyApp(),
  ));
}

@immutable
class CustomTextTheme extends ThemeExtension<CustomTextTheme> {
  const CustomTextTheme({
    required this.montserratOrderId,
    required this.montserratOrderItem,
    required this.montserratButton,
    required this.nunitoSansRestaurantName,
  });

  final TextStyle montserratOrderId;
  final TextStyle montserratOrderItem;
  final TextStyle montserratButton;
  final TextStyle nunitoSansRestaurantName;

  @override
  CustomTextTheme copyWith({
    TextStyle? montserratOrderId,
    TextStyle? montserratOrderItem,
    TextStyle? montserratButton,
    TextStyle? nunitoSansRestaurantName,
  }) {
    return CustomTextTheme(
      montserratOrderId: montserratOrderId ?? this.montserratOrderId,
      montserratOrderItem: montserratOrderItem ?? this.montserratOrderItem,
      montserratButton: montserratButton ?? this.montserratButton,
      nunitoSansRestaurantName:
          nunitoSansRestaurantName ?? this.nunitoSansRestaurantName,
    );
  }

  @override
  ThemeExtension<CustomTextTheme> lerp(
      ThemeExtension<CustomTextTheme>? other, double t) {
    if (other is! CustomTextTheme) {
      return this;
    }
    return CustomTextTheme(
      montserratOrderId:
          TextStyle.lerp(montserratOrderId, other.montserratOrderId, t)!,
      montserratOrderItem:
          TextStyle.lerp(montserratOrderItem, other.montserratOrderItem, t)!,
      montserratButton:
          TextStyle.lerp(montserratButton, other.montserratButton, t)!,
      nunitoSansRestaurantName: TextStyle.lerp(
          nunitoSansRestaurantName, other.nunitoSansRestaurantName, t)!,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eatit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 159, 92, 92),
        ),
        useMaterial3: true,
        fontFamily: "Nunito Sans",
        textTheme: TextTheme(
          // Nunito Sans styles
          displayLarge: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: darkBlack,
          ),
          displayMedium: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: darkBlack,
          ),
          displaySmall: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: darkBlack,
          ),
          titleLarge: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: darkBlack,
          ),
          titleMedium: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: darkBlack,
          ),
          titleSmall: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: darkBlack,
          ),
          labelLarge: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: darkBlack,
          ),
          labelMedium: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: darkBlack,
          ),
          labelSmall: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            letterSpacing: 0,
            color: darkBlack,
          ),
          bodyLarge: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            color: darkBlack,
          ),
          bodyMedium: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w300,
            fontSize: 16,
            color: darkBlack,
          ),
          bodySmall: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w200,
            fontSize: 14,
            color: darkBlack,
          ),
          // Montserrat styles
          headlineLarge: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 13.64,
            height: 1.44,
            letterSpacing: -0.02,
            color: const Color(0xFF23272E),
          ),
          headlineMedium: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            height: 1,
            letterSpacing: 0,
            color: const Color(0xFF2D2D2D),
          ),
          headlineSmall: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        extensions: <ThemeExtension<dynamic>>[
          CustomTextTheme(
            montserratOrderId: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 13.64,
              height: 1.44,
              letterSpacing: -0.02,
              color: const Color(0xFF23272E),
            ),
            montserratOrderItem: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1,
              letterSpacing: 0,
              color: const Color(0xFF2D2D2D),
            ),
            montserratButton: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1,
              letterSpacing: 0,
            ),
            nunitoSansRestaurantName: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              height: 1,
              letterSpacing: 0,
              color: const Color(0xFF2D2D2D),
            ),
          ),
        ],
        primarySwatch: primarySwatch,
        scaffoldBackgroundColor: white,
        primaryColor: primaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: white,
          surfaceTintColor: white,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: white,
          surfaceTintColor: white,
        ),
        cardTheme: const CardTheme(
          color: white,
          surfaceTintColor: white,
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: primaryColor),
      ),
      home: const SplashScreen(),
      onGenerateRoute: generateRoute,
    );
  }
}

Future<void> checkStoredCartData() async {
  final prefs = await SharedPreferences.getInstance();
  final cartJson = prefs.getString('cart_items');

  if (cartJson != null) {
    print("Raw JSON String: $cartJson");
    final decodedCart = json.decode(cartJson) as Map<String, dynamic>;
    print("Decoded Cart Data: $decodedCart");
  } else {
    print("No cart data found in SharedPreferences.");
  }
}
