import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatit/Screens/Filter/filter_bottom_sheet.dart';
import 'package:eatit/Screens/Takeaway_DineIn//widget/dish_card_widget.dart';
import 'package:eatit/Screens/Takeaway_DineIn//widget/single_dish.dart';
import 'package:eatit/Screens/Takeaway_DineIn//widget/toggle_widget.dart';
import 'package:eatit/Screens/Takeaway_DineIn/service/restaurant_service.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/added_item.dart';
import 'package:eatit/Screens/cart_screen/services/cart_service.dart';
import 'package:eatit/Screens/homes/screen/home_screen.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/models/dish_retaurant.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:eatit/Screens/cart_screen/screen/cart_page.dart';
import 'package:eatit/provider/selected_category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:eatit/provider/saved_restaurants_provider.dart';
import 'package:eatit/models/saved_restaurant_model.dart';
import 'dart:async';

class SingleRestaurantScreen extends StatefulWidget {
  static const routeName = "/single-restaurant-screen";
  final String name;
  final String location;
  final String id;
  final String imageUrl;
  final String cuisineType;
  final String priceRange;
  final double rating;
  final String selectedCategory; // Add this

  const SingleRestaurantScreen({
    super.key,
    required this.name,
    required this.location,
    required this.id,
    required this.imageUrl,
    required this.cuisineType,
    required this.priceRange,
    required this.rating,
    this.selectedCategory = '', // Add this with default empty value
  });

  @override
  State<StatefulWidget> createState() => _SingleRestaurantScreen();
}

class _SingleRestaurantScreen extends State<SingleRestaurantScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  List<String> imgurls = [
    "assets/images/burgers.png",
    "assets/images/pizza.png",
    "assets/images/healthy.png",
    "assets/images/home_style.png",
    "assets/images/image1.png",
    "assets/images/image2.png",
    "assets/images/image3.png",
    "assets/images/image4.png",
    "assets/images/image5.png",
    "assets/images/image6.png",
    "assets/images/image7.png",
    "assets/images/image8.png",
    "assets/images/image9.png",
    "assets/images/image10.png",
  ];
  bool _isVisible = false;
  DishSchema? dish;
  AvailableDish? selectedDish;
  final RestaurantService restaurantService = RestaurantService();
  bool isLoading = true; // Loading indicator flag
  DishSchema? filterDishes;
  final Map<String, List<AvailableDish>> categorizedDishes = {};
  String errorMessage = ''; // S
  var screenWidth = 0.0;
  var textTheme;
  String searchQuery = ''; // Track search query
  final TextEditingController _searchController = TextEditingController();
  // Add CancelToken for API requests
  // final CancelToken _cancelToken = CancelToken();
  List<String> buttonLabels = ["Best Seller", "Top Rated", "Veg", "Non-Veg"];
  List<bool> isSelected = [false, false, false, false];

  CartService cartService = CartService();
  String selectedSection = 'Sort By';
  String selectedSortOption = '';
  String selectedRatingOption = '';
  String selectedOfferOption = '';
  String selectedPriceOption = '';
  bool isFilterOpen = false;
  Map<String, bool> selectedFilters = {
    'Sort By': false,
    'Rating': false,
    'Veg / Non-Veg': false,
    'Offers': false,
    'Price': false,
  };

  // bool _isAnyOptionSelected() {
  //   return selectedSortOption.isNotEmpty ||
  //       selectedRatingOption.isNotEmpty ||
  //       selectedOfferOption.isNotEmpty ||
  //       selectedPriceOption.isNotEmpty;
  // }

  // Add this flag to prevent recursion
  String _getTopRatedDish() {
    if (dish?.availableDishes == null || dish!.availableDishes.isEmpty) {
      return "";
    }

    // Sort dishes by rating in descending order
    var sortedDishes = List<AvailableDish>.from(dish!.availableDishes);
    sortedDishes.sort((a, b) => (b.ratting ?? 0).compareTo(a.ratting ?? 0));

    // Return the name of the highest rated dish
    if (sortedDishes.isNotEmpty) {
      return sortedDishes.first.dishId.dishName;
    }
    return "";
  }

  bool _isFilteringInProgress = false;

  void _openMap(dynamic latitude, dynamic longitude, {String? name}) async {
    Uri googleMapsUrl;

    if (latitude == null || longitude == null) {
      googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name!)}");
    } else if (name != null && name.isNotEmpty) {
      // Use `q=$latitude,$longitude+($name)` instead of `near`
      final String encodedQuery =
          Uri.encodeComponent("$latitude,$longitude ($name)");
      googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$encodedQuery");
    } else {
      // Drop a pin at the location
      googleMapsUrl =
          Uri.parse("https://www.google.com/maps?q=$latitude,$longitude");
    }

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDishes();
    _controller = AnimationController(
      duration:
          const Duration(milliseconds: 200), // Short but noticeable duration
      vsync: this,
    );
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _searchController.addListener(_updateSearchQuery);
  }

  void _dismissSlidingScreen() {
    _controller.reverse().then((value) {
      setState(() {
        _isVisible = false;
      });
    });
  }

  void _updateSearchQuery() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
    });
    // Apply filters which include search and any active filter buttons
    if (!_isFilteringInProgress) {
      _filterDishes();
    }
  }

  void _filterDishes() {
    if (_isFilteringInProgress) return; // Prevent recursive calls

    _isFilteringInProgress = true;

    setState(() {
      // Start with all dishes
      List<AvailableDish> filteredDishes = dish?.availableDishes ?? [];

      // Apply search filter if search query exists
      if (searchQuery.isNotEmpty) {
        filteredDishes = filteredDishes
            .where((d) => d.dishId.dishName
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();
      }

      // Apply Veg filter (dishType = 0) if selected from filter buttons
      if (isSelected[2]) {
        filteredDishes =
            filteredDishes.where((d) => d.dishId.dishType == 0).toList();
      }

      // Apply Non-Veg filter (dishType = 1) if selected from filter buttons
      if (isSelected[3]) {
        filteredDishes =
            filteredDishes.where((d) => d.dishId.dishType == 1).toList();
      }

      // Apply rating filter from filter bottom sheet
      if (selectedRatingOption.isNotEmpty) {
        double minRating = 0;
        if (selectedRatingOption.contains('4.5+')) {
          minRating = 4.5;
        } else if (selectedRatingOption.contains('4.0+')) {
          minRating = 4.0;
        } else if (selectedRatingOption.contains('3.5+')) {
          minRating = 3.5;
        } else if (selectedRatingOption.contains('3.0+')) {
          minRating = 3.0;
        }

        if (minRating > 0) {
          filteredDishes = filteredDishes
              .where((d) => d.ratting != null && d.ratting >= minRating)
              .toList();
        }
      }

      // Apply price filter from filter bottom sheet
      if (selectedPriceOption.isNotEmpty) {
        if (selectedPriceOption.contains('Less than ₹150')) {
          filteredDishes = filteredDishes
              .where((d) =>
                  d.resturantDishPrice != null && d.resturantDishPrice <= 150)
              .toList();
        } else if (selectedPriceOption.contains('₹150 - ₹300')) {
          filteredDishes = filteredDishes
              .where((d) =>
                  d.resturantDishPrice != null &&
                  d.resturantDishPrice > 150 &&
                  d.resturantDishPrice <= 300)
              .toList();
        } else if (selectedPriceOption.contains('More than ₹300')) {
          filteredDishes = filteredDishes
              .where((d) =>
                  d.resturantDishPrice != null && d.resturantDishPrice > 300)
              .toList();
        }
      }

      // Apply Best Seller filter if selected from filter buttons
      if (isSelected[0]) {
        // In a real app, you'd have a flag for best seller
        // For now, let's assume dishes with rating > 4 are best sellers
        filteredDishes = filteredDishes
            .where((d) => d.ratting != null && d.ratting > 4)
            .toList();
      }

      // Apply Top Rated filter if selected from filter buttons
      if (isSelected[1]) {
        // Sort by rating in descending order and take top items
        filteredDishes.sort((a, b) {
          double ratingA = a.ratting != null ? a.ratting.toDouble() : 0;
          double ratingB = b.ratting != null ? b.ratting.toDouble() : 0;
          return ratingB.compareTo(ratingA);
        });

        // Only keep top rated items if we have enough
        if (filteredDishes.length > 5) {
          filteredDishes = filteredDishes.sublist(0, 5);
        }
      }

      // Apply sort option from filter bottom sheet
      if (selectedSortOption.isNotEmpty) {
        if (selectedSortOption == 'Price - low to high') {
          filteredDishes.sort((a, b) =>
              (a.resturantDishPrice ?? 0).compareTo(b.resturantDishPrice ?? 0));
        } else if (selectedSortOption == 'Price - high to low') {
          filteredDishes.sort((a, b) =>
              (b.resturantDishPrice ?? 0).compareTo(a.resturantDishPrice ?? 0));
        } else if (selectedSortOption == 'Rating - high to low') {
          filteredDishes.sort((a, b) {
            double ratingA = a.ratting != null ? a.ratting.toDouble() : 0;
            double ratingB = b.ratting != null ? b.ratting.toDouble() : 0;
            return ratingB.compareTo(ratingA);
          });
        } else if (selectedSortOption == 'Rating - low to high') {
          filteredDishes.sort((a, b) {
            double ratingA = a.ratting != null ? a.ratting.toDouble() : 0;
            double ratingB = b.ratting != null ? b.ratting.toDouble() : 0;
            return ratingA.compareTo(ratingB);
          });
        }
      }

      // Update the filterDishes with the filtered list
      if (dish != null) {
        filterDishes = DishSchema(
          restaurant: dish!.restaurant,
          availableDishes: filteredDishes,
          categories: dish!.categories,
        );

        // Clear existing categorized dishes
        categorizedDishes.clear();

        // Loop through filtered dishes and categorize them
        for (var dish in filteredDishes) {
          String category = dish.dishId.dishCatagory;

          // Check if the category exists, if not, create it
          if (!categorizedDishes.containsKey(category)) {
            categorizedDishes[category] = [];
          }

          // Add the dish to the respective category
          categorizedDishes[category]?.add(dish);
        }
      }
    });

    _isFilteringInProgress = false;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSlidingScreen(AvailableDish dish) {
    setState(() {
      selectedDish = dish;
      _isVisible = true;
    });
    _controller.forward();
  }

  Timer? _incrementDebounce;
  Timer? _decrementDebounce;
  Set<String> _pendingDecrementIds = {};
  Map<String, int> _previousQuantities = {};

  void _debouncedIncrement(VoidCallback action) {
    _incrementDebounce?.cancel();
    _incrementDebounce = Timer(const Duration(milliseconds: 800), () {
      action();
    });
  }

  void _debouncedDecrement(
      String id, VoidCallback? afterDecrement, String orderType) {
    _pendingDecrementIds.add(id);
    _decrementDebounce?.cancel();
    _decrementDebounce = Timer(const Duration(milliseconds: 800), () async {
      final ids = List<String>.from(_pendingDecrementIds);
      _pendingDecrementIds.clear();
      if (ids.isNotEmpty) {
        try {
          final response = await cartService.decrementCartItem(
              ids, widget.id, context, orderType);
          if (response == null || response.statusCode != 200) {
            print('Decrement:  API call failed ');
            // API failed, revert to previous state
            for (var dishId in ids) {
              _revertQuantity(dishId, orderType,
                  Provider.of<CartProvider>(context, listen: false));
            }
            _showErrorSnackBar('Failed to update cart');
          } else {
            print('Decrement:  api call success ');
          }
        } catch (e) {
          print('Decrement:  Exception ');
          for (var dishId in ids) {
            _revertQuantity(dishId, orderType,
                Provider.of<CartProvider>(context, listen: false));
          }
          _showErrorSnackBar('Network error occurred');
        }
        if (afterDecrement != null) afterDecrement();
      } else {
        print('Decrement:  API not called ');
      }
    });
  }

  // Enhanced cart operations with error handling and debounce
  Future<void> _handleAddToCart(
      String dishId, String orderType, CartItem cartItem) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    _previousQuantities[dishId] =
        cartProvider.getQuantity(widget.id, orderType, dishId);
    cartProvider.addToCart(widget.id, orderType, cartItem);
    print('Add to cart: Local state updated for dishId: '
        ' $dishId orderType: $orderType');
    _debouncedIncrement(() async {
      try {
        final response = await cartService.addToCart(
            widget.id, context, orderType, widget.location);
        if (response == null || response.statusCode != 200) {
          print('Add to cart:  API call failed for dishId: $dishId, response: '
              ' ${response?.statusCode}');
          _revertQuantity(dishId, orderType, cartProvider);
          _showErrorSnackBar('Failed to add item to cart');
        } else {
          print('Add to cart:  API call success for dishId: $dishId');
        }
      } catch (e) {
        print('Add to cart:  Exception for dishId: $dishId, error: $e');
        _revertQuantity(dishId, orderType, cartProvider);
        _showErrorSnackBar('Network error occurred');
      }
    });
  }

  Future<void> _handleIncrement(String dishId, String orderType) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    _previousQuantities[dishId] =
        cartProvider.getQuantity(widget.id, orderType, dishId);
    cartProvider.incrementQuantity(widget.id, orderType, dishId);
    print('Increment: Local state updated for dishId: '
        '$dishId  orderType: $orderType');
    _debouncedIncrement(() async {
      try {
        final response = await cartService.addToCart(
            widget.id, context, orderType, widget.location);
        if (response == null || response.statusCode != 200) {
          print('Increment: API call failed for dishId: $dishId, response: '
              '${response?.statusCode}');
          _revertQuantity(dishId, orderType, cartProvider);
          _showErrorSnackBar('Failed to update cart');
        } else {
          print('Increment:  API call success for dishId: $dishId');
        }
      } catch (e) {
        print('Increment:  Exception for dishId: $dishId, error: $e');
        _revertQuantity(dishId, orderType, cartProvider);
        _showErrorSnackBar('Network error occurred');
      }
    });
  }

  Future<void> _handleDecrement(String dishId, String orderType) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    _previousQuantities[dishId] =
        cartProvider.getQuantity(widget.id, orderType, dishId);
    cartProvider.decrementQuantity(widget.id, orderType, dishId);
    print('Decrement: Local state updated for dishId: '
        '$dishId , orderType: $orderType');
    _debouncedDecrement(dishId, () {
      print('Decrement: Debounced API not called for dishId: $dishId ');
    }, orderType);
  }

  void _revertQuantity(
      String dishId, String orderType, CartProvider cartProvider) {
    final previousQty = _previousQuantities[dishId] ?? 0;
    final currentQty = cartProvider.getQuantity(widget.id, orderType, dishId);
    if (previousQty == 0 && currentQty > 0) {
      cartProvider.removeFromCart(widget.id, orderType, dishId);
    } else if (previousQty > currentQty) {
      for (int i = currentQty; i < previousQty; i++) {
        cartProvider.incrementQuantity(widget.id, orderType, dishId);
      }
    } else if (previousQty < currentQty) {
      for (int i = currentQty; i > previousQty; i--) {
        cartProvider.decrementQuantity(widget.id, orderType, dishId);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    restaurantService.dispose();
    _searchController.removeListener(_updateSearchQuery);
    _searchController.dispose();
    dish = null;
    filterDishes = null;
    selectedDish = null;
    categorizedDishes.clear();
    _incrementDebounce?.cancel();
    _decrementDebounce?.cancel();
    super.dispose();
  }

  fetchDishes() async {
    // if (_cancelToken.isCancelled) return;
    //
    // final Connectivity connectivity = Connectivity();
    // final NetworkManager networkManager = NetworkManager(connectivity);
    // final ApiRepository apiRepository = ApiRepository(networkManager);
    try {
      final fetchData =
          await restaurantService.fetchDishesData(widget.name, widget.location);

      // await apiRepository.fetchDishesDataWithCancelToken(
      //     widget.name, widget.location, _cancelToken);

      if (fetchData?.statusCode == 200
          // && !_cancelToken.isCancelled
          ) {
        final data = DishSchema.fromJson(fetchData?.data);
        categorizeAndSetDishes(data);
        if (mounted) {
          setState(() {
            dish = data;
          });
        }
      }
    } catch (e) {
      if (mounted
          // && !_cancelToken.isCancelled
          ) {
        _showErrorDialog("Error", "An error occurred while fetching data.");
        setState(() {
          errorMessage = "Error: $e";
          isLoading = false;
        });
      }
    }
  }

  void categorizeAndSetDishes(DishSchema? data, {bool skipFiltering = false}) {
    categorizedDishes.clear();

    // Loop through availableDishes and categorize them
    for (var dish in data!.availableDishes) {
      String category = dish.dishId.dishCatagory;

      // Check if the category exists, if not, create it
      if (!categorizedDishes.containsKey(category)) {
        categorizedDishes[category] = [];
      }

      // Add the dish to the respective category
      categorizedDishes[category]?.add(dish);
    }

    // Update the state with the categorized data
    // print("data loaded");
    setState(() {
      filterDishes = data;
      isLoading = false;

      // Skip filtering if we're resetting filters
      if (!skipFiltering &&
          isSelected.any((isActive) => isActive) &&
          !_isFilteringInProgress) {
        _filterDishes();
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        selectedSection: selectedSection,
        selectedSortOption: selectedSortOption,
        selectedRatingOption: selectedRatingOption,
        selectedOfferOption: selectedOfferOption,
        selectedPriceOption: selectedPriceOption,
        onApplyFilters: (sortOption, ratingOption, offerOption, priceOption) {
          setState(() {
            selectedSortOption = sortOption;
            selectedRatingOption = ratingOption;
            selectedOfferOption = offerOption;
            selectedPriceOption = priceOption;
            isFilterOpen = false;

            // Set veg/non-veg filters based on selection
            if (offerOption == 'Pure Veg') {
              isSelected[2] = true; // Veg
              isSelected[3] = false; // Non-Veg
            } else if (offerOption == 'Non-Veg') {
              isSelected[2] = false; // Veg
              isSelected[3] = true; // Non-Veg
            } else {
              // Keep the current selection for veg/non-veg
            }

            // Now apply filters using the existing method
            _filterDishes();
          });
        },
        onClearFilters: () {
          setState(() {
            // Clear all filter values
            selectedSortOption = '';
            selectedRatingOption = '';
            selectedOfferOption = '';
            selectedPriceOption = '';
            selectedFilters.updateAll((key, value) => false);

            // Reset the filter buttons
            isSelected = [false, false, false, false];

            // Log the reset

            // Fetch the original dishes to reset to initial state
            if (dish != null) {
              filterDishes = DishSchema(
                restaurant: dish!.restaurant,
                availableDishes: dish!.availableDishes,
                categories: dish!.categories,
              );

              // Re-categorize dishes from the original dataset, but skip additional filtering
              categorizeAndSetDishes(filterDishes, skipFiltering: true);
            } else {
              // If no original dishes are available, just apply the reset filters
              _filterDishes();
            }
          });
        },
      ),
    );
  }

  Future<void> _refreshRestaurantData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    // Refresh cart data from API
    await cartService.fetchAndUpdateCart(context);
    // Then refresh restaurant data
    await fetchDishes();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width * 0.35;
    textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 20,
        backgroundColor: _isVisible ? Colors.black.withOpacity(0.3) : null,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (ctx, cartProvider, child) {
          int stored = ctx.watch<OrderTypeProvider>().orderType;
          String orderType = stored == 0 ? "Dine-in" : "Take-away";
          int totalCount = ctx
              .watch<CartProvider>()
              .getTotalUniqueItems(widget.id, orderType);

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: totalCount > 0
                ? Container(
                    width: double.infinity,
                    key: totalCount > 0
                        ? const ValueKey<int>(1)
                        : const ValueKey<int>(0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: AddedItemButton(
                        itemCount: totalCount,
                        onPressed: () {
                          Navigator.pop(context);
                          ctx.read<OrderTypeProvider>().changeHomeState(2);
                          Navigator.pushReplacementNamed(
                              context, HomePage.routeName);
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshRestaurantData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 80), // Add padding for bottom navigation
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    // Restaurant Image
                                    // Replace this part in the Stack
                                    SizedBox(
                                      width: double.infinity,
                                      height: 200,
                                      child: Image.asset(
                                        widget
                                            .imageUrl, // Use the passed imageUrl
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    // Back Button
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: SvgPicture.asset(
                                          "assets/svg/whitebackArrow.svg",
                                          width: 50,
                                          height: 50,
                                        ),
                                      ),
                                    ),
                                    // Bookmark Button
                                    // In SingleRestaurantScreen class, replace the existing bookmark button with:

                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Consumer<SavedRestaurantsProvider>(
                                        builder:
                                            (context, savedProvider, child) {
                                          bool isSaved = savedProvider
                                              .isRestaurantSaved(widget.id);

                                          return GestureDetector(
                                            onTap: () async {
                                              if (isSaved) {
                                                // Show delete confirmation dialog
                                                bool? remove =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    titlePadding:
                                                        const EdgeInsets.only(
                                                            top: 20, bottom: 5),
                                                    title: Column(
                                                      children: [
                                                        const Icon(
                                                          Icons.warning_rounded,
                                                          color:
                                                              Color(0xFFF8951D),
                                                          size: 40,
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          'Remove Restaurant',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleLarge,
                                                        ),
                                                      ],
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                      top: 5,
                                                      left: 24,
                                                      right: 24,
                                                      bottom: 20,
                                                    ),
                                                    content: Text(
                                                      'Remove ${widget.name} from saved?',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge
                                                          ?.copyWith(
                                                            color: const Color(
                                                                0xFF666666),
                                                          ),
                                                    ),
                                                    actions: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context,
                                                                        false),
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                                  side:
                                                                      const BorderSide(
                                                                    color: Color(
                                                                        0xFFF8951D),
                                                                    width: 1,
                                                                  ),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  'Cancel',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .labelMedium
                                                                      ?.copyWith(
                                                                        color: const Color(
                                                                            0xFFF8951D),
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context,
                                                                        true),
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xFFF8951D),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  'Remove',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .labelMedium
                                                                      ?.copyWith(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (remove == true) {
                                                  await savedProvider
                                                      .toggleSaveRestaurant(
                                                    SavedRestaurant(
                                                      id: widget.id,
                                                      imageUrl: widget.imageUrl,
                                                      restaurantName:
                                                          widget.name,
                                                      location: widget.location,
                                                      cuisineType:
                                                          widget.cuisineType,
                                                      // Add this
                                                      priceRange:
                                                          widget.priceRange,
                                                      // Add this
                                                      rating: widget
                                                          .rating, // Add this
                                                      // lat: dish?.restaurant
                                                      //     .resturantLatitute, // Optional
                                                      // long: dish?.restaurant
                                                      //     .resturantLongitute, // Optional
                                                    ),
                                                  );
                                                }
                                              } else {
                                                // Direct save
                                                await savedProvider
                                                    .toggleSaveRestaurant(
                                                  SavedRestaurant(
                                                    id: widget.id,
                                                    imageUrl: widget.imageUrl,
                                                    restaurantName: widget.name,
                                                    location: widget.location,
                                                    cuisineType:
                                                        widget.cuisineType,
                                                    // Add this
                                                    priceRange:
                                                        widget.priceRange,
                                                    // Add this
                                                    rating: widget
                                                        .rating, // Add this
                                                    // lat: dish?.restaurant
                                                    //     .resturantLatitute, // Optional
                                                    // long: dish?.restaurant
                                                    //     .resturantLongitute, // Optional
                                                  ),
                                                );
                                              }
                                            },
                                            child: SvgPicture.asset(
                                              isSaved
                                                  ? "assets/svg/Saved.svg"
                                                  : "assets/svg/bookmark.svg",
                                              width: 50,
                                              height: 50,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            gradient: mapLinearGradient,
                                            borderRadius: BorderRadius.circular(
                                                20), // Adjust as needed
                                          ),
                                          child: ElevatedButton.icon(
                                            onPressed: () => _openMap(
                                                dish?.restaurant
                                                    .resturantLatitute,
                                                dish?.restaurant
                                                    .resturantLongitute,
                                                name: dish?.restaurant
                                                    .restaurantName),
                                            label: const Text("Map",
                                                style: TextStyle(fontSize: 12)),
                                            icon: const Icon(
                                              IconData(0xf8ca,
                                                  fontFamily: "CupertinoIcons",
                                                  fontPackage:
                                                      "cupertino_icons"),
                                              color: Colors.white,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              foregroundColor: Colors.white,
                                              shadowColor: Colors.transparent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${dish?.restaurant.restaurantRating}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4F4F4F),
                                      ),
                                    ),
                                    Icon(
                                      Icons.star, // or Icons.star_rate
                                      color: Theme.of(context).primaryColor,
                                      size: 15, // Adjust size as needed
                                    ),
                                    Text(
                                      //" | Indian • ${widget.cuisineType} | ${_getTopRatedDish()}",
                                      " | Indian • ${_getTopRatedDish()} | 2.3km ",
                                      style: const TextStyle(
                                        color: Color(0xFF4F4F4F),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_right_outlined,
                                      size: 23,
                                      color: Color(0xFF4F4F4F),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Center(
                            child: DineInTakeawayToggle(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: const Color(0xffE5E5E5)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        widget.priceRange.split(" for")[0],
                                        style: const TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        "for two",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 55,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: const Color(0xffE5E5E5)),
                                    ),
                                  ),
                                  const Column(children: [
                                    Text(
                                      "20 mins",
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "before reaching",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ])
                                ],
                              ),
                            ),
                          ),

                          // Search Field
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(
                                        0x0D000000), // This is #0000000D in RGBA
                                    spreadRadius: 0,
                                    blurRadius: 20,
                                    offset: Offset(
                                        0, 2), // 0px horizontal, 2px vertical
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(
                                    20), // Optional: Rounded corners
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  icon: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: SvgPicture.asset(
                                      'assets/svg/search.svg',
                                      width: 30,
                                    ),
                                  ),
                                  hintText: "Search for Dishes",
                                  hintStyle: const TextStyle(
                                    color: Color(0xff737373),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Match with the container
                                    borderSide: BorderSide.none, // No border
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isFilterOpen = true;
                                        });
                                        _showFilterBottomSheet();
                                      },
                                      child: SvgPicture.asset(
                                        'assets/svg/filter.svg',
                                        // replace with your actual asset path
                                        width: 40, // adjust the size as needed
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Filter Buttons
                          _buildFilterButtons(),
                          // Dishes Categories
                          // Show recommended dishes only when a category is selected
                          if (context
                              .watch<SelectedCategoryProvider>()
                              .selectedCategory
                              .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildRecommendedDishes(),
                            ),

                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : (errorMessage.isNotEmpty
                                  ? Center(child: Text(errorMessage))
                                  : categorizedDishes
                                          .isEmpty // Check if there are no dishes
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 45),
                                              Icon(
                                                Icons
                                                    .no_meals_outlined, // or Icons.search_off
                                                size: 32,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'No dishes found',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Try adjusting your search or filters',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          children: categorizedDishes.entries
                                              .map((entry) {
                                            String category = entry.key;
                                            List<AvailableDish> dishes =
                                                entry.value;

                                            // Skip this category if it's the selected one
                                            if (category.toLowerCase() ==
                                                context
                                                    .watch<
                                                        SelectedCategoryProvider>()
                                                    .selectedCategory
                                                    .toLowerCase()) {
                                              return const SizedBox.shrink();
                                            }

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    category,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Container(
                                                      height:
                                                          220, // Adjust based on your UI needs
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Consumer<
                                                              CartProvider>(
                                                          builder: (ctx,
                                                              cartProvider,
                                                              child) {
                                                        return ListView.builder(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8),
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              dishes.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final dish =
                                                                dishes[index];
                                                            int stored = ctx
                                                                .watch<
                                                                    OrderTypeProvider>()
                                                                .orderType;
                                                            String orderType =
                                                                "";
                                                            if (stored == 0) {
                                                              orderType =
                                                                  "Dine-in";
                                                            } else {
                                                              orderType =
                                                                  "Take-away";
                                                            }
                                                            // final cartItem = cartProvider
                                                            //     .restaurantCarts[
                                                            //         widget.name]?[orderType]
                                                            //     ?.firstWhere(
                                                            //   (item) => item.id == dish.id,
                                                            //   orElse: () => CartItem(
                                                            //       id: dish.id,
                                                            //       restaurantName:
                                                            //           widget.name,
                                                            //       orderType: orderType,
                                                            //       dish: dish,
                                                            //       quantity: 0),
                                                            // );
                                                            return GestureDetector(
                                                              onTap: dish
                                                                      .available
                                                                  ? () =>
                                                                      _showSlidingScreen(
                                                                          dish)
                                                                  : null,
                                                              child: DishCard(
                                                                name: dish
                                                                    .dishId
                                                                    .dishName,
                                                                price:
                                                                    "₹${dish.resturantDishPrice}",
                                                                imageUrl:
                                                                    imgurls[
                                                                        index %
                                                                            9],
                                                                calories:
                                                                    "120 cal",
                                                                isAvailable: dish
                                                                    .available,
                                                                // Add this line

                                                                quantity: (ctx
                                                                    .watch<
                                                                        CartProvider>()
                                                                    .getQuantity(
                                                                        widget
                                                                            .id,
                                                                        orderType,
                                                                        dish.id)),
                                                                // Default to 0 if cartItem.quantity is null
                                                                onAddToCart:
                                                                    () async {
                                                                  final cartItem = CartItem(
                                                                      id: dish
                                                                          .id,
                                                                      restaurantName:
                                                                          widget
                                                                              .name,
                                                                      orderType:
                                                                          orderType,
                                                                      dish:
                                                                          dish,
                                                                      quantity:
                                                                          1,
                                                                      location:
                                                                          widget
                                                                              .location,
                                                                      restaurantImageUrl:
                                                                          widget
                                                                              .imageUrl);
                                                                  await _handleAddToCart(
                                                                      dish.id,
                                                                      orderType,
                                                                      cartItem);
                                                                },

                                                                onIncrement:
                                                                    () async {
                                                                  await _handleIncrement(
                                                                      dish.id,
                                                                      orderType);
                                                                },
                                                                onDecrement:
                                                                    () async {
                                                                  await _handleDecrement(
                                                                      dish.id,
                                                                      orderType);
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      })),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        )),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isVisible)
                  GestureDetector(
                    onTap: _dismissSlidingScreen,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                        AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: SlideTransition(
                              position: _offsetAnimation,
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Consumer<CartProvider>(
                                      builder: (ctx, cartProvider, child) {
                                    int stored = ctx
                                        .watch<OrderTypeProvider>()
                                        .orderType;
                                    String orderType = "";
                                    if (stored == 0) {
                                      orderType = "Dine-in";
                                    } else {
                                      orderType = "Take-away";
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 2), // Remove bottom padding
                                      child: FoodItemBottomSheet(
                                        name: selectedDish!.dishId.dishName,
                                        imageUrl:
                                            'https://via.placeholder.com/100',
                                        calories: '120 Cal',
                                        quantity: ctx
                                            .watch<CartProvider>()
                                            .getQuantity(widget.id, orderType,
                                                selectedDish!.id),
                                        categories:
                                            selectedDish!.dishId.dishCatagory,
                                        price: selectedDish!.resturantDishPrice
                                            .toString(),
                                        onAddToCart: () async {
                                          final cartItem = CartItem(
                                              id: selectedDish!.id,
                                              restaurantName: widget.name,
                                              restaurantImageUrl:
                                                  widget.imageUrl,
                                              orderType: orderType,
                                              dish: selectedDish!,
                                              quantity: 1,
                                              location: widget.location);
                                          await _handleAddToCart(
                                              selectedDish!.id,
                                              orderType,
                                              cartItem);
                                        },
                                        onIncrement: () async {
                                          await _handleIncrement(
                                              selectedDish!.id, orderType);
                                        },
                                        onDecrement: () async {
                                          await _handleDecrement(
                                              selectedDish!.id, orderType);
                                        },
                                      ),
                                    );
                                  })),
                            )),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(buttonLabels.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    // Toggle the filter button
                    isSelected[index] = !isSelected[index];

                    // Set filter bottom sheet selection to match button selection
                    if (index == 2 && isSelected[index]) {
                      // Veg selected
                      selectedOfferOption = 'Pure Veg';
                      // Ensure non-veg is deselected when veg is selected
                      isSelected[3] = false;
                    } else if (index == 3 && isSelected[index]) {
                      // Non-veg selected
                      selectedOfferOption = 'Non-Veg';
                      // Ensure veg is deselected when non-veg is selected
                      isSelected[2] = false;
                    }

                    // If both veg and non-veg are deselected, clear the filter option
                    if (!isSelected[2] && !isSelected[3]) {
                      selectedOfferOption = '';
                    }

                    // Apply filters
                    _filterDishes();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected[index]
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFFFFFFF),
                    border: Border.all(
                      color: isSelected[index]
                          ? const Color(0xFFF8951D)
                          : const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    // boxShadow: isSelected[index]
                    //     ? [
                    //         BoxShadow(
                    //           color: const Color(0xFFF8951D).withOpacity(0.3),
                    //           blurRadius: 6,
                    //           offset: const Offset(0, 3),
                    //         )
                    //       ]
                    //     : [],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterIcon(index),
                      const SizedBox(width: 8),
                      Text(
                        buttonLabels[index],
                        style: TextStyle(
                          color: isSelected[index]
                              ? Colors.black
                              : const Color(0xFF757575),
                          fontSize: 14,
                          fontWeight: isSelected[index]
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRecommendedDishes() {
    // List of food images to cycle through
    final List<String> foodImages = [
      "assets/images/burgers.png",
      "assets/images/pizza.png",
      "assets/images/healthy.png",
      "assets/images/home_style.png",
      "assets/images/image1.png",
      "assets/images/image2.png",
      "assets/images/image3.png",
      "assets/images/image4.png",
      "assets/images/image5.png",
      "assets/images/image6.png",
      "assets/images/image7.png",
      "assets/images/image8.png",
      "assets/images/image9.png",
      "assets/images/image10.png",
    ];

    return Consumer<SelectedCategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.selectedCategory.isEmpty) {
          return const SizedBox
              .shrink(); // Don't show anything if no category is selected
        }

        // Create a list to store recommended dishes
        List<AvailableDish> recommendedDishes = [];

        // Go through all categorized dishes
        categorizedDishes.entries.forEach((entry) {
          entry.value.forEach((dish) {
            // Check if dish belongs to selected category
            if (dish.dishId.dishCatagory
                .toLowerCase()
                .contains(categoryProvider.selectedCategory.toLowerCase())) {
              recommendedDishes.add(dish);
            }
            // Check if dish name contains the selected category keyword
            else if (dish.dishId.dishName
                .toLowerCase()
                .contains(categoryProvider.selectedCategory.toLowerCase())) {
              recommendedDishes.add(dish);
            }
          });
        });

        if (recommendedDishes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show selected category name
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Text(
                categoryProvider.selectedCategory,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendedDishes.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final dish = recommendedDishes[index];
                  // Get image based on index, cycling through the list
                  final imageIndex = index % foodImages.length;
                  final imageUrl = foodImages[imageIndex];

                  return Container(
                    width: 166,
                    margin: const EdgeInsets.only(right: 5),
                    child: Consumer<CartProvider>(
                      builder: (ctx, cartProvider, child) {
                        int stored = ctx.watch<OrderTypeProvider>().orderType;
                        String orderType =
                            stored == 0 ? "Dine-in" : "Take-away";

                        return DishCard(
                          name: dish.dishId.dishName,
                          price: "₹${dish.resturantDishPrice}",
                          imageUrl: imageUrl,
                          isAvailable: dish.available,
                          calories: "120 cal",
                          quantity: ctx
                              .watch<CartProvider>()
                              .getQuantity(widget.id, orderType, dish.id),
                          onAddToCart: () async {
                            final cartItem = CartItem(
                              id: dish.id,
                              restaurantName: widget.name,
                              orderType: orderType,
                              dish: dish,
                              quantity: 1,
                              location: widget.location,
                              restaurantImageUrl: widget.imageUrl,
                            );
                            await _handleAddToCart(
                                dish.id, orderType, cartItem);
                          },
                          onIncrement: () async {
                            await _handleIncrement(dish.id, orderType);
                          },
                          onDecrement: () async {
                            await _handleDecrement(dish.id, orderType);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

// Custom icon builder based on index
  Widget _buildFilterIcon(int index) {
    if (index == 0) {
      // Best Seller Icon
      return const Icon(
        Icons.local_fire_department,
        size: 18,
        color: Color(0xFFF8951D),
      );
    } else if (index == 1) {
      // Top Rated Star Icon
      return const Icon(
        Icons.star,
        size: 18,
        color: Color(0xFF139456),
      );
    } else if (index == 2) {
      // Veg Icon
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: const Color(0xFF36F456),
            width: 1.5,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.circle,
            size: 10,
            color: Color(0xFF36F456),
          ),
        ),
      );
    } else {
      // Non-Veg Icon
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Color(0xFFF44336),
            width: 1.5,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.circle,
            size: 10,
            color: Color(0xFFF44336),
          ),
        ),
      );
    }
  }
}
