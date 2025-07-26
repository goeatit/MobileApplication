import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:eatit/Screens/Filter/filter_widget.dart';
import 'package:eatit/Screens/My_Booking/service/My_Booking_service.dart';
import 'package:eatit/Screens/Takeaway_DineIn/screen/banner_section.dart';
import 'package:eatit/Screens/Takeaway_DineIn/screen/expansion_floating_button.dart';
import 'package:eatit/Screens/Takeaway_DineIn/screen/shimmer_loading_effect.dart';
import 'package:eatit/Screens/Takeaway_DineIn/screen/singe_restaurant_screen.dart';
import 'package:eatit/Screens/Takeaway_DineIn/service/restaurant_service.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/bottom_cart.dart';
import 'package:eatit/api/api_client.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/main.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/models/my_booking_modal.dart';
import 'package:eatit/models/restaurant_model.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/my_booking_provider.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:eatit/provider/selected_category_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../widget/resturant_widget.dart';

class TakeAwayScreen extends StatefulWidget {
  final bool isCartLoading;

  const TakeAwayScreen({super.key, this.isCartLoading = false});

  @override
  State<StatefulWidget> createState() => _TakeAwayScreen();
}

class _TakeAwayScreen extends State<TakeAwayScreen> {
  // final List<UserElement> _orders = []; // Initialize with an empty list
  RestaurantService? restaurantService;
  MyBookingService? _bookingService;
  bool _isLoadingOrders = false;
  bool _servicesInitialized = false;

  late CancelToken _cancelToken;
  List<RestaurantsData> restaurants = []; // List to store fetched restaurants
  List<RestaurantsData> filteredRestaurants = []; // Store filtered restaurants
  bool isLoading = true; // Loading indicator flag
  String errorMessage = ''; // Store error message
  // All Categories
  final List<Map<String, String>> _allCategories = [
    {"name": "Briyani", "image": "assets/images/briyani.png"},
    {"name": "Chicken", "image": "assets/images/home_style.png"},
    {"name": "Pizza", "image": "assets/images/pizza.png"},
    {"name": "Burger", "image": "assets/images/burgers.png"},
    {"name": "Non Veg Meal", "image": "assets/images/nonvegmeal.png"},
    {"name": "Thali", "image": "assets/images/thali.png"},
    {"name": "Veg Meal", "image": "assets/images/vegmeal.png"},
    {"name": "Momos", "image": "assets/images/momos.png"},
    {"name": "Dessert", "image": "assets/images/Dessert.png"},
    {"name": "Appetizers", "image": "assets/images/appetizers.png"},
    {"name": "Pasta & Noodles", "image": "assets/images/Pasta&noodles.png"},
    {"name": "Main Courses", "image": "assets/images/maincourses.png"},
    {"name": "South Indian", "image": "assets/images/southindian.png"},
    {"name": "Coffee", "image": "assets/images/coffee.png"},
    {"name": "Fried Rice", "image": "assets/images/friedrice.png"},
    {"name": "Paneer", "image": "assets/images/panner.png"},
    {"name": "Chinese", "image": "assets/images/chinese.png"},
    {"name": "Roll", "image": "assets/images/roll.png"},
    {"name": "Salad", "image": "assets/images/salad.png"},
    {"name": "Mushroom", "image": "assets/images/mushroom.png"},
  ];

  String selectedCategory = '';
  String? city;
  String? country;

  setCityAndCountry() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    city = sharedPreferences.getString("city");
    country = sharedPreferences.getString("country");
  }

  // Timer? _timer;
  // Add CancelToken for API requests
  //final CancelToken _cancelToken = CancelToken();

  // Fetch the restaurant data
  fetchData() async {
    // if (_cancelToken.isCancelled) return;
    //
    // final Connectivity connectivity = Connectivity();
    // final NetworkManager networkManager = NetworkManager(connectivity);
    // final ApiRepository apiRepository = ApiRepository(networkManager);

    try {
      // SharedPreferences sharedPreferences =
      //     await SharedPreferences.getInstance();
      // city = sharedPreferences.getString("city");
      // country = sharedPreferences.getString("country");
      // // city = "Bengaluru";
      // city = "Bhubaneswar";

      final response = await restaurantService!.fetchRestaurantsByArea();
      //
      // await apiRepository.fetchRestaurantByAreaWithCancelToken(
      //     city!, country!, _cancelToken);

      if (response != null &&
          response.data is List &&
          response.data.isNotEmpty &&
          // !_cancelToken.isCancelled &&
          mounted) {
        setState(() {
          final restaurantModel = RestaurantModel.fromJson(response.data[0]);
          restaurants = restaurantModel.restaurants;
          filteredRestaurants =
              List.from(restaurants); // Initially show all restaurants
          isLoading = false;
        });
      } else if (mounted
          // && !_cancelToken.isCancelled
          ) {
        setState(() {
          restaurants = []; // Ensure restaurants list is empty
          filteredRestaurants = [];
          errorMessage = "assets/images/expand-your-city.png";
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted
          // && !_cancelToken.isCancelled
          ) {
        setState(() {
          //errorMessage = "Error: $e";
          errorMessage = "assets/images/expand-your-city.png";
          isLoading = false;
        });
      }
    }
  }

  fetchDataByCategory() async {
    // // Cancel previous token if exists
    // if (!_cancelToken.isCancelled) {
    //   _cancelToken.cancel("New request started");
    // }
    // // Create new token
    // _cancelToken = CancelToken();
    setState(() {
      isLoading = true;
    });

    // if (selectedCategory.isEmpty) {
    //   // If no category is selected, show all restaurants
    //   setState(() {
    //     filteredRestaurants = List.from(restaurants);
    //     isLoading = false;
    //   });
    //   return;
    // }
    if (selectedCategory.isEmpty) {
      // If no category is selected, show all restaurants with loading effect
      await Future.delayed(const Duration(
          milliseconds: 300)); // Add small delay for visual feedback
      if (mounted
          // && !_cancelToken.isCancelled
          ) {
        setState(() {
          filteredRestaurants = List.from(restaurants);
          isLoading = false;
        });
      }
      return;
    }

    // final Connectivity connectivity = Connectivity();
    // final NetworkManager networkManager = NetworkManager(connectivity);
    // final ApiRepository apiRepository = ApiRepository(networkManager);

    try {
      // SharedPreferences sharedPreferences =
      //     await SharedPreferences.getInstance();
      // city = sharedPreferences.getString("city");
      // country = sharedPreferences.getString("country");
      // // city = "Bhubaneswar";
      if (selectedCategory == '') {
        return;
      }

      final response =
          await restaurantService!.fetchRestaurantsByCategory(selectedCategory);
      // await apiRepository.fetchRestaurantByCategoryNameWithCancelToken(
      //     city!, country!, _cancelToken, selectedCategory);

      if (response != null &&
          response.data is List &&
          response.data.isNotEmpty &&
          // !_cancelToken.isCancelled &&
          mounted) {
        final restaurantModel = RestaurantModel.fromJson(response.data[0]);
        // print(restaurantModel.restaurants.length);

        setState(() {
          final restaurantModel = RestaurantModel.fromJson(response.data[0]);
          //restaurants = restaurantModel.restaurants;
          filteredRestaurants = restaurantModel.restaurants;
          isLoading = false;
        });
      } else {
        setState(() {
          filteredRestaurants = [];
          isLoading = false;
        });
      }

      // } else if (mounted && !_cancelToken.isCancelled) {
      //   // setState(() {
      //   //   restaurants = [];
      //   //   errorMessage = "assets/images/expand-your-city.png";
      //   //   isLoading = false;
      //   // });
      // }
    }
    // catch (e) {
    //   if (mounted && !_cancelToken.isCancelled) {
    //     setState(() {
    //       errorMessage = "assets/images/expand-your-city.png";
    //       isLoading = false;
    //     });
    //   }
    // }
    catch (e) {
      if (mounted
          // && !_cancelToken.isCancelled
          ) {
        setState(() {
          filteredRestaurants = [];
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchOrders() async {
    if (mounted) {
      setState(() => _isLoadingOrders = true);
    }

    try {
      final response = await _bookingService!.fetchOrderDetails();
      if (response != null && mounted) {
        context.read<MyBookingProvider>().setMyBookings(response.user);
        // setState(() {
        //   _orders.clear();
        //   _orders.addAll(response.user);
        // });
      }
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingOrders = false);
      }
    }
  }

  bool _shouldDisplayBooking(String? status) {
    if (status == null) return false;
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'preparing' ||
        lowerStatus == 'order placed' ||
        lowerStatus == 'ready' ||
        lowerStatus == 'delayed';
  }

  @override
  void initState() {
    super.initState();
    _cancelToken = CancelToken();
    setCityAndCountry();
    // startBannerTimer();
    // fetchOrders();
  }

  // void startBannerTimer() {
  //   _timer?.cancel();
  //
  //   // First set initial state
  //   setState(() {
  //     _currentBannerIndex = 0;
  //   });
  //
  //   _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
  //     if (mounted) {
  //       // Check if widget is still mounted
  //       setState(() {
  //         _currentBannerIndex = (_currentBannerIndex + 1) % bannerImages.length;
  //       });
  //     }
  //   });
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load cart data once dependencies are resolved
    context
        .read<CartProvider>()
        .loadCartFromStorage(); // Load cart after widget initialization
    // Initialize booking service
    if (!_servicesInitialized) {
      _bookingService =
          MyBookingService(apiRepository: context.read<ApiRepository>());
      restaurantService =
          RestaurantService(apiRepository: context.read<ApiRepository>());
      _servicesInitialized = true;
    }
    fetchData();
  }

  @override
  void dispose() {
    // Cancel the banner rotation timer
    // _timer?.cancel();
    // _timer = null;

    // Cancel any ongoing API requests
    // if (!_cancelToken.isCancelled) {
    //   _cancelToken.cancel("Widget disposed");
    // }
    restaurantService!.dispose();

    // Clear data structures to free memory
    restaurants.clear();
    city = null;
    country = null;
    _bookingService!.dispose();
    _bookingService = null;
    restaurantService = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !isLoading,
        onPopInvokedWithResult: (didPop, result) {
          if (isLoading) {
            // Cancel the loading state and reset category
            setState(() {
              isLoading = false;
              selectedCategory = '';
              Provider.of<SelectedCategoryProvider>(context, listen: false)
                  .setSelectedCategory('');
            });

            // Cancel any ongoing API requests
            if (!_cancelToken.isCancelled) {
              _cancelToken.cancel("User pressed back");
            }

            // Create a new CancelToken for future requests
            _cancelToken = CancelToken();
          }
        },
        child: Stack(
          children: [
            if (widget.isCartLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
            isLoading
                ? const ShimmerLoadingEffect() // Replace CircularProgressIndicator with ShimmerLoadingEffect
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Image.asset(
                          errorMessage,
                          fit: BoxFit.contain,
                          height: 350,
                        ),
                      )
                    : SingleChildScrollView(
                        child: restaurants.isNotEmpty
                            ? Column(
                                // Wrap the entire content in a Column
                                children: [
                                  // Banner with dots
                                  const BannerSection(),
                                  // Promo restaurants
                                  if (selectedCategory.isNotEmpty &&
                                      filteredRestaurants.isEmpty)
                                    Container()
                                  else
                                    Column(
                                      children: [
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
                                          imageUrl:
                                              'assets/images/restaurant.png',
                                          restaurantName:
                                              restaurants[0].restaurantName,
                                          cuisineType:
                                              "Indian • ${restaurants[0].topratedCusine}",
                                          priceRange: getPriceRangeText(
                                              restaurants[0]
                                                  .topratedCusinePrice),
                                          rating:
                                              restaurants[0].ratings.toDouble(),
                                          promotionText:
                                              "Flat 10% off in booking",
                                          // Update if you have promo data
                                          promoCode: "Happy10",
                                          // Update this if you have promo codes
                                          location: city!,
                                          lat: restaurants[0].lat,
                                          long: restaurants[0].long,
                                          id: restaurants[0].id,
                                        ),
                                      ],
                                      // Add other widgets here if needed
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
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        // Selected category
                                        selectedCategory.isNotEmpty
                                            ? categoryItem(
                                                selectedCategory,
                                                _allCategories.firstWhere(
                                                      (category) =>
                                                          category['name'] ==
                                                          selectedCategory,
                                                    )?['image'] ??
                                                    '',
                                              )
                                            : const SizedBox.shrink(),
                                        // Other categories
                                        ..._allCategories
                                            .where((category) =>
                                                category['name'] !=
                                                selectedCategory)
                                            .map((category) {
                                          return categoryItem(
                                              category['name'] ?? '',
                                              category['image'] ?? '');
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 17),
                                  const FilterWidget(),
                                  const SizedBox(height: 18),
                                  if (selectedCategory.isNotEmpty &&
                                      filteredRestaurants.isEmpty)
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(height: 50),
                                          Icon(
                                            Icons.restaurant_menu,
                                            size: 50,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "No restaurants found for $selectedCategory ",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Hmm, looks like $selectedCategory is playing hide-and-seek. 😉 , Want to try another delicious adventure? 🌮🍜🥗",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    // Restaurant List
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: restaurants.length > 1
                                          ? restaurants.length - 1
                                          : 0,
                                      itemBuilder: (context, index) {
                                        final restaurant =
                                            restaurants[index + 1];
                                        // Calculate image index (1-4) using modulo to cycle through images
                                        final imageIndex = (index % 9) + 1;
                                        return RestaurantWidget(
                                          imageUrl:
                                              'assets/images/restaurant$imageIndex.png',
                                          restaurantName:
                                              restaurant.restaurantName,
                                          location: city!,
                                          cuisineType:
                                              "Indian • ${restaurant.topratedCusine}",
                                          priceRange: getPriceRangeText(
                                              restaurant.topratedCusinePrice),
                                          rating: restaurant.ratings.toDouble(),
                                          long: restaurant.long,
                                          id: restaurant.id,
                                        );
                                      },
                                    ),
                                  // Add bottom padding for cart
                                  const SizedBox(height: 80),
                                ],
                              )
                            : Center(
                                child: Image.asset(
                                  'assets/images/expand-your-city.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
            // if (_orders
            //     .where((order) => _shouldDisplayBooking(order.user.orderStatus))
            //     .isNotEmpty)
            //   ExpansionFloatingButton(
            //     orders: _orders,
            //     onRefresh: fetchOrders,
            //   )
            // else

            Consumer<MyBookingProvider>(
              builder: (ctx, mybookingprovider, child) {
                var _orders = mybookingprovider.myBookings;
                if (_orders
                    .where((order) =>
                        _shouldDisplayBooking(order.user.orderStatus))
                    .isNotEmpty) {
                  return ExpansionFloatingButton(
                    orders: _orders,
                    onRefresh: fetchOrders,
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            // Consumer<CartProvider>(builder: (ctx, cartProvider, child) {
            //     if (cartProvider.restaurantCarts.isEmpty) {
            //       return const SizedBox.shrink();
            //     }
            //
            //     List<CartItem> dineInItems = [];
            //     int totalItems = 0;
            //     String id = "";
            //
            //     // Iterate through restaurants to find the first "Take-Away" cart items
            //     for (var restaurantId in cartProvider.restaurantCarts.keys) {
            //       var items =
            //           cartProvider.restaurantCarts[restaurantId]?['Take-away'];
            //       if (items != null && items.isNotEmpty) {
            //         dineInItems = items;
            //         totalItems =
            //             items.fold(0, (sum, item) => sum + item.quantity);
            //         id = restaurantId;
            //         break;
            //       }
            //     }
            //
            //     // If no "Take-Away" items found in any restaurant
            //     if (dineInItems.isEmpty) {
            //       return const SizedBox.shrink();
            //     }
            //
            //     return Positioned(
            //         bottom: 0,
            //         child: FoodCartSection(
            //           name: dineInItems.first.restaurantName,
            //           items: totalItems.toString(),
            //           pressMenu: () {
            //             Navigator.pushNamed(
            //                 context, SingleRestaurantScreen.routeName,
            //                 arguments: {
            //                   'name': dineInItems.first.restaurantName,
            //                   'location': dineInItems.first.location,
            //                   'id': id,
            //                   'selectedCategory': selectedCategory,
            //                 });
            //           },
            //           pressCart: () {
            //             context.read<OrderTypeProvider>().changeHomeState(2);
            //           },
            //           pressRemove: () {
            //             ctx.read<CartProvider>().clearCart(id, 'Take-away');
            //           },
            //           // TODO: Pass onCartLoading from HomePage here if uncommented
            //         ));
            //   })
          ],
        ));
  }

  Widget categoryItem(String label, String imagePath) {
    bool isSelected = selectedCategory == label;

    return GestureDetector(
      // In your categoryItem onTap method
      onTap: () async {
        if (isLoading) return; // Prevent multiple taps while loading

        final categoryProvider =
            Provider.of<SelectedCategoryProvider>(context, listen: false);

        setState(() {
          selectedCategory = isSelected ? '' : label;
          categoryProvider.setSelectedCategory(isSelected ? '' : label);
        });

        await fetchDataByCategory();
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

  // Helper method to format price range from topratedCusinePrice
  String getPriceRangeText(dynamic price) {
    if (price == null) {
      return "₹1200-₹1500 for two"; // Default fallback
    }

    try {
      // Try to parse the price as a number
      int priceValue = int.tryParse(price.toString()) ?? 1200;

      // Calculate a range around the average price (±150)
      int lowerPrice = (priceValue - 150).clamp(100, 10000);
      int upperPrice = (priceValue + 150).clamp(200, 15000);

      return "₹$lowerPrice-₹$upperPrice for two";
    } catch (e) {
      return "₹1200-₹1500 for two"; // Fallback in case of error
    }
  }
}
