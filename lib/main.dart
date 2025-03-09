import 'dart:convert';

import 'package:eatit/Screens/Auth/login_screen/screen/login_screen.dart';
import 'package:eatit/Screens/Auth/verify_otp/screen/verify_otp.dart';
import 'package:eatit/Screens/CompleteYourProfile/Screen/Complete_your_profile_screen.dart';
import 'package:eatit/Screens/Takeaway_DineIn//screen/singe_restaurant_screen.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/bottom_cart.dart';
import 'package:eatit/Screens/first_time_screen/screen/first_time_screen.dart';
import 'package:eatit/Screens/homes/screen/home_screen.dart';
import 'package:eatit/Screens/location/screen/location_screen.dart';
import 'package:eatit/Screens/order_summary/screen/no_of_people.dart';
import 'package:eatit/Screens/order_summary/screen/bill_summary.dart';
import 'package:eatit/Screens/order_summary/screen/order_summary.dart';
import 'package:eatit/Screens/order_summary/screen/reserve_time.dart';
import 'package:eatit/Screens/profile/screen/edit_profile.dart';
import 'package:eatit/Screens/profile/screen/profile_screen.dart';
import 'package:eatit/Screens/search/screen/search_screen.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:eatit/routes/main_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Adjust for dark or light icons
  ));
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => CartProvider()),
      ChangeNotifierProvider(create: (context) => OrderTypeProvider()),
      ChangeNotifierProvider(create: (context) => UserModelProvider())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const displayTextStyle = TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 22,
      color: darkBlack,
    );
    const titleTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: darkBlack,
    );
    const labelTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: darkBlack,
    );
    const bodyTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: darkBlack,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eatit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 159, 92, 92)),
        useMaterial3: true,
        textTheme: TextTheme(
          displayLarge: displayTextStyle,
          displayMedium: displayTextStyle.copyWith(
            fontSize: 20,
          ),
          displaySmall: displayTextStyle.copyWith(
            fontSize: 18,
          ),
          titleLarge: titleTextStyle,
          titleMedium: titleTextStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          titleSmall: titleTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          labelLarge: labelTextStyle,
          labelMedium: labelTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          labelSmall: labelTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            fontSize: 14,
          ),
          bodyLarge: bodyTextStyle,
          bodyMedium: bodyTextStyle.copyWith(
            fontWeight: FontWeight.w300,
            fontSize: 16,
          ),
          bodySmall: bodyTextStyle.copyWith(
            fontWeight: FontWeight.w200,
            fontSize: 14,
          ),
        ),
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
      home: const FirstTimeScreen(),
      onGenerateRoute: generateRoute,
    );
  }
}

Future<void> checkStoredCartData() async {
  final prefs = await SharedPreferences.getInstance();

  // Retrieve the JSON string
  final cartJson = prefs.getString('cart_items');

  if (cartJson != null) {
    // Print the raw JSON string
    print("Raw JSON String: $cartJson");

    // Decode the JSON string
    final decodedCart = json.decode(cartJson) as Map<String, dynamic>;

    // Print the decoded structure
    print("Decoded Cart Data: $decodedCart");
  } else {
    print("No cart data found in SharedPreferences.");
  }
}
