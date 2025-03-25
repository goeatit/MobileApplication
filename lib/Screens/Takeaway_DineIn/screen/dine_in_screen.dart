import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:eatit/Screens/Takeaway_DineIn/screen/singe_restaurant_screen.dart';
import 'package:eatit/api/api_client.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/main.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/models/restaurant_model.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/bottom_cart.dart';

import 'dart:async';

import '../widget/resturant_widget.dart';

class DineInScreen extends StatefulWidget {
  const DineInScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DineInScreen();
}

class _DineInScreen extends State<DineInScreen> {
  List<RestaurantsData> restaurants = [];
  bool isLoading = true;
  String errorMessage = '';
  String? city;
  String? country;

  int _currentBannerIndex = 0;
  final List<String> bannerImages = [
    "assets/images/banner.png",
    "assets/images/banner2.png",
    "assets/images/banner3.png",
  ];

  Timer? _timer;

  fetchData() async {
    final Connectivity connectivity = Connectivity();
    final NetworkManager networkManager = NetworkManager(connectivity);
    final ApiRepository apiRepository = ApiRepository(networkManager);

    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      city = sharedPreferences.getString("city");
      country = sharedPreferences.getString("country");
      city = "Bhubaneswar";

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
          restaurants = [];
          errorMessage = "We are expanding soon in your city.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "We are expanding soon in your city.";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    startBannerTimer();
  }

  void startBannerTimer() {
    _timer?.cancel();

    // First set initial state
    setState(() {
      _currentBannerIndex = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        // Check if widget is still mounted
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % bannerImages.length;
        });
      }
    });
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
  void dispose() {
    _timer?.cancel();
    restaurants.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : SingleChildScrollView(
                      child: restaurants.isNotEmpty
                          ? Column(
                              children: [
                                // Banner with dots
                                Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: Image.asset(
                                            bannerImages[_currentBannerIndex],
                                            key: ValueKey<int>(
                                                _currentBannerIndex),
                                            width: double.infinity,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        bannerImages.length,
                                        (index) => Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _currentBannerIndex == index
                                                ? const Color(0xFFF8951D)
                                                : const Color(0xFFFBCA8E),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),

                                // Promoted Restaurant Section
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  width: double.infinity,
                                  child: const Text(
                                    "Promoted Restaurants",
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Color(0xFF1D1929),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                RestaurantWidget(
                                  imageUrl: 'assets/images/restaurant.png',
                                  restaurantName: restaurants[0].restaurantName,
                                  cuisineType: "Indian • Biryani",
                                  priceRange: "₹1200-₹1500 for two",
                                  rating: restaurants[0].ratings.toDouble(),
                                  promotionText: "Flat 10% off in booking !",
                                  promoCode: "Happy10",
                                  location: city!,
                                  lat: restaurants[0].lat,
                                  long: restaurants[0].long,
                                  id: restaurants[0].id,
                                ),

                                // Categories Section
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  width: double.infinity,
                                  child: const Text(
                                    "What do you want to Eat Today",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF1D1929),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      categoryItem("Healthy Food",
                                          "assets/images/healthy.png"),
                                      categoryItem("Home Style",
                                          "assets/images/home_style.png"),
                                      categoryItem(
                                          "Pizza", "assets/images/pizza.png"),
                                      categoryItem("Burger",
                                          "assets/images/burgers.png"),
                                      categoryItem("Chicken",
                                          "assets/images/chicken.png"),
                                    ],
                                  ),
                                ),

                                // Restaurant List
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: restaurants.length > 1
                                      ? restaurants.length - 1
                                      : 0,
                                  itemBuilder: (context, index) {
                                    final restaurant = restaurants[index + 1];
                                    final imageIndex = (index % 9) + 1;
                                    return RestaurantWidget(
                                      imageUrl:
                                          'assets/images/restaurant$imageIndex.png',
                                      restaurantName: restaurant.restaurantName,
                                      location: city!,
                                      cuisineType: "Indian • Biryani",
                                      priceRange: "₹1200-₹1500 for two",
                                      rating: restaurant.ratings.toDouble(),
                                      long: restaurant.long,
                                      lat: restaurant.lat,
                                      id: restaurant.id,
                                    );
                                  },
                                ),
                                // Add bottom padding for cart
                                const SizedBox(height: 80),
                              ],
                            )
                          : const Center(
                              child: Text("We are expanding soon"),
                            ),
                    ),
          // Bottom Cart
          Consumer<CartProvider>(builder: (ctx, cartProvider, child) {
            if (cartProvider.restaurantCarts.isEmpty) {
              return const SizedBox.shrink();
            }

            List<CartItem> dineInItems = [];
            int totalItems = 0;
            String id = "";

            // Iterate through restaurants to find the first "Take-Away" cart items
            for (var restaurantId in cartProvider.restaurantCarts.keys) {
              var items =
                  cartProvider.restaurantCarts[restaurantId]?['Dine-in'];
              if (items != null && items.isNotEmpty) {
                dineInItems = items;
                totalItems = items.fold(0, (sum, item) => sum + item.quantity);
                id = restaurantId;
                break;
              }
            }

            // If no "Take-Away" items found in any restaurant
            if (dineInItems.isEmpty) {
              return const SizedBox.shrink();
            }

            return Positioned(
                bottom: 0,
                child: FoodCartSection(
                  name: dineInItems.first.restaurantName,
                  items: totalItems.toString(),
                  pressMenu: () {
                    Navigator.pushNamed(
                        context, SingleRestaurantScreen.routeName,
                        arguments: {
                          'name': dineInItems.first.restaurantName,
                          'location': dineInItems.first.location,
                          'id': id
                        });
                  },
                  pressCart: () {
                    context.read<OrderTypeProvider>().changeHomeState(2);
                  },
                  pressRemove: () {
                    ctx.read<CartProvider>().clearCart(id, 'Dine-in');
                  },
                ));
          })
        ],
      ),
    );
  }

  Widget categoryItem(String label, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              imagePath,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: darkBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
