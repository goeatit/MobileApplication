import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/bottom_cart.dart';
import 'package:eatit/api/api_client.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/main.dart';
import 'package:eatit/models/restaurant_model.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget/resturant_widget.dart';

class TakeAwayScreen extends StatefulWidget {
  const TakeAwayScreen({super.key});

  @override
  State<StatefulWidget> createState() => _TakeAwayScreen();
}

class _TakeAwayScreen extends State<TakeAwayScreen> {
  List<RestaurantsData> restaurants = []; // List to store fetched restaurants
  bool isLoading = true; // Loading indicator flag
  String errorMessage = ''; // Store error message
  String? city;
  String? country;

  // Fetch the restaurant data
  fetchData() async {
    final Connectivity connectivity = Connectivity();
    final NetworkManager networkManager = NetworkManager(connectivity);
    final ApiRepository apiRepository = ApiRepository(networkManager);

    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      city = sharedPreferences.getString("city");
      country = sharedPreferences.getString("country");
      // city = "Bengaluru";
      // city = "Bhubaneswar";

      final response =
          await apiRepository.fetchRestaurantByArea(city!, country!);

      if (response != null &&
          response.data is List &&
          response.data.isNotEmpty) {
        setState(() {
          final restaurantModel = RestaurantModel.fromJson(response.data[0]);
          restaurants = restaurantModel.restaurants;
          isLoading = false;
        });
      } else {
        setState(() {
          restaurants = []; // Ensure restaurants list is empty
          errorMessage = "We are expanding soon in your city.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load cart data once dependencies are resolved
    context
        .read<CartProvider>()
        .loadCartFromStorage(); // Load cart after widget initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading spinner
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                        errorMessage)) // Show error message if fetching failed
                : Stack(
                    children: [
                      SingleChildScrollView(
                        child: restaurants.isNotEmpty
                            ? Column(
                                // Wrap the entire content in a Column
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                          8.0), // Adjust padding as needed
                                      child: Image.asset(
                                        "assets/images/banner.png",
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                  // Promo restaurants

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    width: double.infinity,
                                    child: const Text(
                                      "Promoted Restaurant",
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: darkBlack,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  RestaurantWidget(
                                    imageUrl: 'assets/images/restaurant.png',
                                    restaurantName:
                                        restaurants[0].restaurantName,
                                    cuisineType:
                                        "Indian • Biryani", // Update this if you have a field for cuisine
                                    priceRange:
                                        "₹1200-₹1500 for two", // Update this if you have price range info
                                    rating: restaurants[0].ratings.toDouble(),
                                    promotionText:
                                        "Flat 10% off in booking", // Update if you have promo data
                                    promoCode:
                                        "Happy10", // Update this if you have promo codes
                                    location: city!,
                                    lat: restaurants[0].lat,
                                    long: restaurants[0].long,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    width: double.infinity,
                                    child: const Text(
                                      "What do you want to Eat Today",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: darkBlack,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis
                                        .horizontal, // Set horizontal scroll direction
                                    child: Row(
                                      children: [
                                        categoryItem("Healthy Food",
                                            "assets/images/healthy.png"), // Display the category item
                                        categoryItem("Home Style",
                                            "assets/images/home_style.png"), // Display the category item
                                        categoryItem("Pizza",
                                            "assets/images/pizza.png"), // Display the category item
                                        categoryItem("Burger",
                                            "assets/images/burgers.png"), // Display the category item
                                        categoryItem("Chicken",
                                            "assets/images/chicken.png"), // Display the category item
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap:
                                        true, // Ensures the ListView takes only the space it needs
                                    physics:
                                        const NeverScrollableScrollPhysics(), // Prevent scroll conflict with SingleChildScrollView
                                    itemCount: restaurants.length > 1
                                        ? restaurants.length - 1
                                        : 0,
                                    itemBuilder: (context, index) {
                                      final restaurant = restaurants[index + 1];
                                      return RestaurantWidget(
                                        imageUrl:
                                            'assets/images/restaurant.png',
                                        restaurantName:
                                            restaurant.restaurantName,
                                        location: city!,
                                        cuisineType:
                                            "Indian • Biryani", // Update this if you have a field for cuisine
                                        priceRange:
                                            "₹1200-₹1500 for two", // Update this if you have price range info
                                        rating: restaurant.ratings.toDouble(),
                                        lat: restaurant.lat,
                                        long: restaurant.long,
                                        // promotionText:
                                        //     "Promoted", // Update if you have promo data
                                        // promoCode:
                                        //     "Promo Placeholder", // Update this if you have promo codes
                                      );
                                    },
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text("We are expanding soon"),
                              ),
                      ),
                      const Positioned(bottom: 0, child: FoodCartSection())
                    ],
                  ));
  }

  Widget categoryItem(String label, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              imagePath,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
