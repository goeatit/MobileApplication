import 'package:eatit/Screens/Auth/login_screen/screen/login_screen.dart';
import 'package:eatit/Screens/Auth/verify_otp/screen/verify_otp.dart';
import 'package:eatit/Screens/CompleteYourProfile/Screen/Complete_your_profile_screen.dart';
import 'package:eatit/Screens/My_Booking/screen/my_bookings_screen.dart';
import 'package:eatit/Screens/Takeaway_DineIn//screen/singe_restaurant_screen.dart';
import 'package:eatit/Screens/first_time_screen/screen/first_time_screen.dart';
import 'package:eatit/Screens/homes/screen/home_screen.dart';
import 'package:eatit/Screens/location/screen/location_screen.dart';
import 'package:eatit/Screens/noftification/screen/notification_screen.dart';
import 'package:eatit/Screens/order_summary/screen/no_of_people.dart';
import 'package:eatit/Screens/order_summary/screen/bill_summary.dart';
import 'package:eatit/Screens/order_summary/screen/order_confirmation_screen.dart';
import 'package:eatit/Screens/order_summary/screen/order_summary.dart';
import 'package:eatit/Screens/order_summary/screen/reserve_time.dart';
import 'package:eatit/Screens/profile/screen/collections_screen.dart';
import 'package:eatit/Screens/profile/screen/edit_profile.dart';
import 'package:eatit/Screens/profile/screen/profile_screen.dart';
import 'package:eatit/Screens/search/screen/search_screen.dart';
import 'package:eatit/Screens/location/screen/restaurant_address_screen.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  dynamic page;
  switch (routeSettings.name) {
    case HomePage.routeName:
      page = const HomePage();
      break;

    case FirstTimeScreen.routeName:
      page = const FirstTimeScreen();
      break;

    case LoginScreeen.routeName:
      page = const LoginScreeen();
      break;

    case VerifyOtp.routeName:
      final args = routeSettings.arguments as Map<String, String>;
      page = VerifyOtp(
        countryCode: args['countryCode']!,
        phoneNumber: args['phoneNumber']!,
      );
      break;

    case LocationScreen.routeName:
      page = const LocationScreen();
      break;

    case SingleRestaurantScreen.routeName:
      final args = routeSettings.arguments as Map<String, dynamic>;
      page = SingleRestaurantScreen(
        name: args['name']!,
        location: args['location']!,
        id: args['id']!,
        imageUrl: args['imageUrl']!,
        cuisineType: args['cuisineType']!,
        priceRange: args['priceRange']!,
        rating: args['rating'] is String
            ? double.parse(args['rating'])
            : args['rating'],
      );
      break;

    case SearchScreen.routeName:
      page = const SearchScreen();
      break;

    case BillSummaryScreen.routeName:
      final args = routeSettings.arguments as Map<String, String>;
      page = BillSummaryScreen(
        name: args['name']!,
        orderType: args['orderType']!,
        id: args['id']!,
        imageUrl: args['imageUrl']!,
        cuisineType: args['cuisineType']!,
        locationOfRestaurant: args['locationOfRestaurant']!,
        priceRange: args['priceRange']!,
        rating: double.parse(args['rating']!),
      );
      break;

    case SelectPeopleScreen.routeName:
      page = const SelectPeopleScreen();
      break;

    case ProfileScreen.routeName:
      page = const ProfileScreen();
      break;

    case EditProfileScreen.routeName:
      page = const EditProfileScreen();
      break;

    case NotificationScreen.routeName:
      page = const NotificationScreen();

    case ReserveTime.routeName:
      page = const ReserveTime();
      break;

    case OrderSummaryScreen.routeName:
      page = const OrderSummaryScreen();
      break;

    case CreateAccountScreen.routeName:
      page = const CreateAccountScreen();
      break;
    case RestaurantAddressScreen.routeName:
      page = const RestaurantAddressScreen();
      break;
    case CollectionsScreen.routeName:
      page = const CollectionsScreen();

    case MyBookingsScreen.routeName:
      page = const MyBookingsScreen();
      break;
    // In your route generator file (main_router.dart)

    case OrderConfirmationScreen.routeName:
      final args = routeSettings.arguments as Map<String, dynamic>;
      page = OrderConfirmationScreen(
        restaurantId: args['restaurantId'] ?? '',
        restaurantName: args['restaurantName'] ?? '',
        location: args['location'] ?? '',
        latitude: args['latitude'] ?? 0.0,
        longitude: args['longitude'] ?? 0.0,
      );
      break;
  }
  return MaterialPageRoute(builder: (context) => page);
}
