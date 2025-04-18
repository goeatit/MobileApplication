import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:eatit/Screens/Filter/filter_widget.dart';
import 'package:eatit/Screens/Takeaway_DineIn/screen/singe_restaurant_screen.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/bottom_cart.dart';
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
import 'package:flutter_svg/svg.dart';
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
  String selectedCategory = '';
  String? city;
  String? country;

  int _currentBannerIndex = 0;
  final List<String> bannerImages = [
    "assets/images/banner.png",
    "assets/images/banner2.png",
    "assets/images/banner3.png",
  ];

  Timer? _timer;
  // Add CancelToken for API requests
  final CancelToken _cancelToken = CancelToken();

  // Fetch the restaurant data
  fetchData() async {
    if (_cancelToken.isCancelled) return;

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

      final response = await apiRepository.fetchRestaurantByAreaWithCancelToken(
          city!, country!, _cancelToken);

      if (response != null &&
          response.data is List &&
          response.data.isNotEmpty &&
          !_cancelToken.isCancelled &&
          mounted) {
        setState(() {
          final restaurantModel = RestaurantModel.fromJson(response.data[0]);
          restaurants = restaurantModel.restaurants;
          isLoading = false;
        });
      } else if (mounted && !_cancelToken.isCancelled) {
        setState(() {
          restaurants = []; // Ensure restaurants list is empty
          errorMessage = "assets/images/expand-your-city.png";
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !_cancelToken.isCancelled) {
        setState(() {
          //errorMessage = "Error: $e";
          errorMessage = "assets/images/expand-your-city.png";
          isLoading = false;
        });
      }
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
    // Cancel the banner rotation timer
    _timer?.cancel();
    _timer = null;

    // Cancel any ongoing API requests
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel("Widget disposed");
    }

    // Clear data structures to free memory
    restaurants.clear();
    city = null;
    country = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading spinner
            : errorMessage.isNotEmpty
                ? Center(
                    child: Image.asset(
                      errorMessage, // Using errorMessage as image path
                      fit: BoxFit.contain,
                      height: 350,
                    ),
                  ) // Show error message if fetching failed
                : Stack(
                    children: [
                      SingleChildScrollView(
                        child: restaurants.isNotEmpty
                            ? Column(
                                // Wrap the entire content in a Column
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
                                            duration: const Duration(
                                                milliseconds: 500),
                                            child: Image.asset(
                                              bannerImages[_currentBannerIndex],
                                              key: ValueKey<int>(
                                                  _currentBannerIndex), // Add this key
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
                                              color:
                                                  _currentBannerIndex == index
                                                      ? const Color(0xFFF8951D)
                                                      : const Color(0xFFFBCA8E),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
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
                                    id: restaurants[0].id,
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
                                        categoryItem("Briyani",
                                            "assets/images/briyani.png"),
                                        categoryItem("Chicken",
                                            "assets/images/home_style.png"),
                                        categoryItem(
                                            "Pizza", "assets/images/pizza.png"),
                                        categoryItem("Burger",
                                            "assets/images/burgers.png"),
                                        categoryItem("Non Veg Meal",
                                            "assets/images/nonvegmeal.png"),
                                        categoryItem(
                                            "Thali", "assets/images/thali.png"),
                                        categoryItem("Veg Meal",
                                            "assets/images/vegmeal.png"),
                                        categoryItem(
                                            "Momos", "assets/images/momos.png"),
                                        categoryItem("Dessert",
                                            "assets/images/Dessert.png"),
                                        categoryItem("Appetizers",
                                            "assets/images/appetizers.png"),
                                        categoryItem("Pasta & Noodles",
                                            "assets/images/Pasta&noodles.png"),
                                        categoryItem("Main Courses",
                                            "assets/images/maincourses.png"),
                                        categoryItem("South Indian",
                                            "assets/images/southindian.png"),
                                        categoryItem("Coffee",
                                            "assets/images/coffee.png"),
                                        categoryItem("Fried Rice",
                                            "assets/images/friedrice.png"),
                                        categoryItem("Paneer",
                                            "assets/images/panner.png"),
                                        categoryItem("Chinese",
                                            "assets/images/chinese.png"),
                                        categoryItem(
                                            "Roll", "assets/images/roll.png"),
                                        categoryItem(
                                            "Salad", "assets/images/salad.png"),
                                        categoryItem("Mushroom",
                                            "assets/images/mushroom.png"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 17),
                                  const FilterWidget(),
                                  const SizedBox(height: 18),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: restaurants.length > 1
                                        ? restaurants.length - 1
                                        : 0,
                                    itemBuilder: (context, index) {
                                      final restaurant = restaurants[index + 1];
                                      // Calculate image index (1-4) using modulo to cycle through images
                                      final imageIndex = (index % 9) + 1;
                                      return RestaurantWidget(
                                        imageUrl:
                                            'assets/images/restaurant$imageIndex.png',
                                        restaurantName:
                                            restaurant.restaurantName,
                                        location: city!,
                                        cuisineType: "Indian • Biryani",
                                        priceRange: "₹1200-₹1500 for two",
                                        rating: restaurant.ratings.toDouble(),
                                        long: restaurant.long,
                                        id: restaurant.id,
                                        // promotionText:
                                        //     "Promoted", // Update if you have promo data
                                        // promoCode:
                                        //     "Promo Placeholder", // Update this if you have promo codes
                                      );
                                    },
                                  ),
                                  // Add bottom padding for cart
                                  const SizedBox(height: 80),
                                  // Add the SVG image after RestaurantWidget
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: SvgPicture.asset(
                                      'assets/svg/first_Default.svg',
                                    ),
                                  ),
                                  const SizedBox(height: 100),
                                ],
                              )
                            : Center(
                                child: Image.asset(
                                  'assets/images/expand-your-city.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                      Consumer<CartProvider>(
                          builder: (ctx, cartProvider, child) {
                        if (cartProvider.restaurantCarts.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        List<CartItem> dineInItems = [];
                        int totalItems = 0;
                        String id = "";

                        // Iterate through restaurants to find the first "Take-Away" cart items
                        for (var restaurantId
                            in cartProvider.restaurantCarts.keys) {
                          var items = cartProvider.restaurantCarts[restaurantId]
                              ?['Take-away'];
                          if (items != null && items.isNotEmpty) {
                            dineInItems = items;
                            totalItems = items.fold(
                                0, (sum, item) => sum + item.quantity);
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
                                context
                                    .read<OrderTypeProvider>()
                                    .changeHomeState(2);
                              },
                              pressRemove: () {
                                ctx
                                    .read<CartProvider>()
                                    .clearCart(id, 'Take-away');
                              },
                            ));
                      })
                    ],
                  ));
  }

  Widget categoryItem(String label, String imagePath) {
    bool isSelected = selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = isSelected ? '' : label;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5), // Padding for the border
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF8951D)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 3,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8951D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? const Color(0xFFF8951D) : darkBlack,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
