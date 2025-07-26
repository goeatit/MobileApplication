import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/models/dish_retaurant.dart';
import 'package:eatit/models/saved_restaurant_model.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:eatit/provider/saved_restaurants_provider.dart';
import 'package:eatit/provider/selected_category_provider.dart';
import 'package:eatit/Screens/cart_screen/services/cart_service.dart';
import 'package:eatit/Screens/Filter/filter_bottom_sheet.dart';
import 'package:eatit/Screens/homes/screen/home_screen.dart';
import 'package:eatit/Screens/Takeaway_DineIn/service/restaurant_service.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/added_item.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/dish_card_widget.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/single_dish.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// --- NEW: Enum to represent the static sections of the screen ---
enum SectionType { Header, Toggle, Info, SearchBar, Recommended, EmptyState }

class SingleRestaurantScreen extends StatefulWidget {
  static const routeName = "/single-restaurant-screen";
  final String name;
  final String location;
  final String id;
  final String imageUrl;
  final String cuisineType;
  final String priceRange;
  final double rating;
  final String selectedCategory;

  const SingleRestaurantScreen({
    super.key,
    required this.name,
    required this.location,
    required this.id,
    required this.imageUrl,
    required this.cuisineType,
    required this.priceRange,
    required this.rating,
    this.selectedCategory = '',
  });

  @override
  State<StatefulWidget> createState() => _SingleRestaurantScreen();
}

class _SingleRestaurantScreen extends State<SingleRestaurantScreen>
    with SingleTickerProviderStateMixin {
  // --- Constants ---
  static const _animationDuration = Duration(milliseconds: 200);

  // --- State Variables ---
  bool isLoading = true;
  bool _isVisible = false;
  bool _servicesInitialized = false;
  bool _isFilteringInProgress = false;
  String errorMessage = '';
  String searchQuery = '';
  String _topRatedDishName = '';

  // --- Controllers & Keys ---
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  final TextEditingController _searchController = TextEditingController();
  CancelToken? _cancelToken;

  // --- Data Holders ---
  DishSchema? dish;
  DishSchema? filterDishes;
  final Map<String, List<AvailableDish>> _categorizedDishes = {};
  AvailableDish? selectedDish;

  // --- Services ---
  late final RestaurantService _restaurantService;
  late final CartService _cartService;

  // --- Filter State ---
  List<bool> isSelected = [false, false, false, false];
  String selectedSortOption = '';
  String selectedRatingOption = '';
  String selectedOfferOption = '';
  String selectedPriceOption = '';
  bool isFilterOpen = false;
  String selectedSection = 'Sort By';
  Map<String, bool> selectedFilters = {
    'Sort By': false,
    'Rating': false,
    'Veg / Non-Veg': false,
    'Offers': false,
    'Price': false,
  };

  // --- Debouncing for Cart ---
  Timer? _incrementDebounce;
  Timer? _decrementDebounce;
  final Set<String> _pendingDecrementIds = {};
  final Map<String, int> _previousQuantities = {};

  // --- Image URLs ---
  final List<String> imgurls = [
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_servicesInitialized) {
      _restaurantService =
          RestaurantService(apiRepository: context.read<ApiRepository>());
      _cartService = CartService(apiRepository: context.read<ApiRepository>());
      _servicesInitialized = true;
      _fetchDishes();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cancelToken?.cancel("Screen disposed");
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _incrementDebounce?.cancel();
    _decrementDebounce?.cancel();
    super.dispose();
  }

  // --- Data Fetching & Handling ---

  Future<void> _fetchDishes() async {
    _cancelToken?.cancel("New fetch started");
    _cancelToken = CancelToken();

    try {
      final response = await _restaurantService.fetchDishesData(
          widget.name, widget.location);

      if (response?.statusCode == 200 && mounted) {
        final data = DishSchema.fromJson(response!.data);
        dish = data;
        filterDishes = data;
        _calculateTopRatedDish();
        categorizeAndSetDishes(data);
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel && mounted) {
        _showErrorDialog("Error", "An error occurred while fetching data.");
        setState(() {
          errorMessage = "Error: ${e.message}";
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("Error", "An unexpected error occurred.");
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _refreshRestaurantData() async {
    setState(() => isLoading = true);
    await _cartService.fetchAndUpdateCart(context);
    await _fetchDishes();
  }

  void categorizeAndSetDishes(DishSchema? data, {bool skipFiltering = false}) {
    if (data == null) return;

    _categorizedDishes.clear();
    for (var dish in data.availableDishes) {
      final category = dish.dishId.dishCatagory;
      (_categorizedDishes[category] ??= []).add(dish);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // --- Filtering & Searching Logic ---

  void _onSearchChanged() {
    if (searchQuery != _searchController.text) {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
      _filterDishes();
    }
  }

  void _filterDishes() {
    if (_isFilteringInProgress || dish == null) return;
    _isFilteringInProgress = true;

    List<AvailableDish> filtered = List.from(dish!.availableDishes);

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((d) => d.dishId.dishName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }
    if (isSelected[0]) {
      filtered =
          filtered.where((d) => d.ratting != null && d.ratting > 4).toList();
    }
    if (isSelected[1]) {
      filtered.sort((a, b) => (b.ratting ?? 0).compareTo(a.ratting ?? 0));
      if (filtered.length > 5) filtered = filtered.sublist(0, 5);
    }
    if (isSelected[2])
      filtered = filtered.where((d) => d.dishId.dishType == 0).toList();
    if (isSelected[3])
      filtered = filtered.where((d) => d.dishId.dishType == 1).toList();

    if (selectedRatingOption.isNotEmpty) {
      double minRating = 0;
      if (selectedRatingOption.contains('4.5+'))
        minRating = 4.5;
      else if (selectedRatingOption.contains('4.0+'))
        minRating = 4.0;
      else if (selectedRatingOption.contains('3.5+'))
        minRating = 3.5;
      else if (selectedRatingOption.contains('3.0+')) minRating = 3.0;
      if (minRating > 0) {
        filtered =
            filtered.where((d) => (d.ratting ?? 0) >= minRating).toList();
      }
    }
    if (selectedPriceOption.isNotEmpty) {
      if (selectedPriceOption.contains('Less than ₹150')) {
        filtered =
            filtered.where((d) => (d.resturantDishPrice ?? 0) <= 150).toList();
      } else if (selectedPriceOption.contains('₹150 - ₹300')) {
        filtered = filtered
            .where((d) =>
                (d.resturantDishPrice ?? 0) > 150 &&
                d.resturantDishPrice <= 300)
            .toList();
      } else if (selectedPriceOption.contains('More than ₹300')) {
        filtered =
            filtered.where((d) => (d.resturantDishPrice ?? 0) > 300).toList();
      }
    }
    if (selectedSortOption.isNotEmpty) {
      if (selectedSortOption == 'Price - low to high') {
        filtered.sort((a, b) =>
            (a.resturantDishPrice ?? 0).compareTo(b.resturantDishPrice ?? 0));
      } else if (selectedSortOption == 'Price - high to low') {
        filtered.sort((a, b) =>
            (b.resturantDishPrice ?? 0).compareTo(a.resturantDishPrice ?? 0));
      } else if (selectedSortOption == 'Rating - high to low') {
        filtered.sort((a, b) => (b.ratting ?? 0).compareTo(a.ratting ?? 0));
      } else if (selectedSortOption == 'Rating - low to high') {
        filtered.sort((a, b) => (a.ratting ?? 0).compareTo(b.ratting ?? 0));
      }
    }

    setState(() {
      filterDishes = DishSchema(
        restaurant: dish!.restaurant,
        availableDishes: filtered,
        categories: dish!.categories,
      );
      categorizeAndSetDishes(filterDishes, skipFiltering: true);
    });

    _isFilteringInProgress = false;
  }

  // --- Cart Logic ---
  // Unchanged from previous versions...
  void _debouncedIncrement(VoidCallback action) {
    _incrementDebounce?.cancel();
    _incrementDebounce = Timer(const Duration(milliseconds: 800), action);
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
          final response = await _cartService.decrementCartItem(
              ids, widget.id, context, orderType);
          if (response == null || response.statusCode != 200) {
            for (var dishId in ids) {
              _revertQuantity(dishId, orderType, context.read<CartProvider>());
            }
            _showErrorSnackBar('Failed to update cart');
          }
        } catch (e) {
          for (var dishId in ids) {
            _revertQuantity(dishId, orderType, context.read<CartProvider>());
          }
          _showErrorSnackBar('Network error occurred');
        }
        afterDecrement?.call();
      }
    });
  }

  Future<void> _handleAddToCart(
      String dishId, String orderType, CartItem cartItem) async {
    final cartProvider = context.read<CartProvider>();
    _previousQuantities[dishId] =
        cartProvider.getQuantity(widget.id, orderType, dishId);
    cartProvider.addToCart(widget.id, orderType, cartItem);

    _debouncedIncrement(() async {
      try {
        final response = await _cartService.addToCart(
            widget.id, context, orderType, widget.location);
        if (response == null || response.statusCode != 200) {
          _revertQuantity(dishId, orderType, cartProvider);
          _showErrorSnackBar('Failed to add item to cart');
        }
      } catch (e) {
        _revertQuantity(dishId, orderType, cartProvider);
        _showErrorSnackBar('Network error occurred');
      }
    });
  }

  Future<void> _handleIncrement(String dishId, String orderType) async {
    final cartProvider = context.read<CartProvider>();
    _previousQuantities[dishId] =
        cartProvider.getQuantity(widget.id, orderType, dishId);
    cartProvider.incrementQuantity(widget.id, orderType, dishId);

    _debouncedIncrement(() async {
      try {
        final response = await _cartService.addToCart(
            widget.id, context, orderType, widget.location);
        if (response == null || response.statusCode != 200) {
          _revertQuantity(dishId, orderType, cartProvider);
          _showErrorSnackBar('Failed to update cart');
        }
      } catch (e) {
        _revertQuantity(dishId, orderType, cartProvider);
        _showErrorSnackBar('Network error occurred');
      }
    });
  }

  Future<void> _handleDecrement(String dishId, String orderType) async {
    final cartProvider = context.read<CartProvider>();
    _previousQuantities[dishId] =
        cartProvider.getQuantity(widget.id, orderType, dishId);
    cartProvider.decrementQuantity(widget.id, orderType, dishId);
    _debouncedDecrement(dishId, () {}, orderType);
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

  // --- UI Helpers & Popups ---
  // Unchanged from previous versions...
  void _showSlidingScreen(AvailableDish dish) {
    setState(() {
      selectedDish = dish;
      _isVisible = true;
    });
    _controller.forward();
  }

  void _dismissSlidingScreen() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isVisible = false);
      }
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

            if (offerOption == 'Pure Veg') {
              isSelected[2] = true;
              isSelected[3] = false;
            } else if (offerOption == 'Non-Veg') {
              isSelected[2] = false;
              isSelected[3] = true;
            }
            _filterDishes();
          });
        },
        onClearFilters: () {
          setState(() {
            selectedSortOption = '';
            selectedRatingOption = '';
            selectedOfferOption = '';
            selectedPriceOption = '';
            selectedFilters.updateAll((key, value) => false);
            isSelected = [false, false, false, false];

            if (dish != null) {
              filterDishes = DishSchema(
                restaurant: dish!.restaurant,
                availableDishes: dish!.availableDishes,
                categories: dish!.categories,
              );
              categorizeAndSetDishes(filterDishes, skipFiltering: true);
            } else {
              _filterDishes();
            }
          });
        },
      ),
    );
  }

  // --- Utility Methods ---

  void _calculateTopRatedDish() {
    if (dish?.availableDishes == null || dish!.availableDishes.isEmpty) {
      _topRatedDishName = "";
      return;
    }
    var sortedDishes = List<AvailableDish>.from(dish!.availableDishes);
    sortedDishes.sort((a, b) => (b.ratting ?? 0).compareTo(a.ratting ?? 0));

    if (mounted) {
      setState(() {
        _topRatedDishName =
            sortedDishes.isNotEmpty ? sortedDishes.first.dishId.dishName : "";
      });
    }
  }

  void _openMap(dynamic latitude, dynamic longitude, {String? name}) async {
    Uri googleMapsUrl;
    if (latitude != null && longitude != null) {
      googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
    } else if (name != null) {
      googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name)}");
    } else {
      _showErrorSnackBar("Location data not available.");
      return;
    }

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      _showErrorSnackBar("Could not open map.");
    }
  }

  // --- Build Method & Widgets ---

  @override
  Widget build(BuildContext context) {
    // --- NEW: Create the build plan for the ListView.builder ---
    List<dynamic> sections = [];
    if (!isLoading) {
      // Add all static sections
      sections.add(SectionType.Header);
      sections.add(SectionType.Toggle);
      sections.add(SectionType.Info);
      sections.add(SectionType.SearchBar);

      // Conditionally add the recommended section based on provider
      final selectedCategory =
          context.watch<SelectedCategoryProvider>().selectedCategory;
      if (selectedCategory.isNotEmpty) {
        sections.add(SectionType.Recommended);
      }

      // Add dish categories or the empty state message
      final visibleCategories = _categorizedDishes.entries
          .where((e) => e.key.toLowerCase() != selectedCategory.toLowerCase())
          .toList();

      if (_categorizedDishes.isEmpty) {
        sections.add(SectionType.EmptyState);
      } else {
        sections.addAll(visibleCategories);
      }
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 20,
        backgroundColor: _isVisible ? Colors.black.withOpacity(0.3) : null,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: _buildBottomCartBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshRestaurantData,
                  // --- CHANGE: Replaced with ListView.builder ---
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final item = sections[index];

                      // Build static sections based on enum type
                      if (item is SectionType) {
                        switch (item) {
                          case SectionType.Header:
                            return _buildRestaurantHeader();
                          case SectionType.Toggle:
                            return const Center(child: DineInTakeawayToggle());
                          case SectionType.Info:
                            return _buildInfoAndToggleSection();
                          case SectionType.SearchBar:
                            return _buildSearchBarAndFilters();
                          case SectionType.Recommended:
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildRecommendedDishes(),
                            );
                          case SectionType.EmptyState:
                            return _buildEmptyState();
                        }
                      }

                      // Build dynamic category sections
                      if (item is MapEntry<String, List<AvailableDish>>) {
                        return _buildCategorySection(item.key, item.value);
                      }

                      return const SizedBox.shrink(); // Fallback
                    },
                  ),
                ),
                if (_isVisible) _buildSlidingPanel(),
              ],
            ),
    );
  }

  // --- NEW: Helper widget for the empty/no dishes found state ---
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_meals_outlined, size: 32, color: Colors.grey),
            SizedBox(height: 5),
            Text('No dishes found',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Text('Try adjusting your search or filters',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // --- NEW: Helper widget to build a single category section ---
  Widget _buildCategorySection(String category, List<AvailableDish> dishes) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: Consumer<CartProvider>(
              builder: (ctx, cartProvider, child) {
                final orderType =
                    context.read<OrderTypeProvider>().orderType == 0
                        ? "Dine-in"
                        : "Take-away";
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    final cartItem = CartItem(
                      id: dish.id,
                      restaurantName: widget.name,
                      orderType: orderType,
                      dish: dish,
                      quantity: 1,
                      location: widget.location,
                      restaurantImageUrl: widget.imageUrl,
                    );
                    return GestureDetector(
                      onTap: dish.available
                          ? () => _showSlidingScreen(dish)
                          : null,
                      child: DishCard(
                        name: dish.dishId.dishName,
                        price: "₹${dish.resturantDishPrice}",
                        imageUrl: imgurls[index % imgurls.length],
                        calories: "120 cal",
                        isAvailable: dish.available,
                        quantity: cartProvider.getQuantity(
                            widget.id, orderType, dish.id),
                        onAddToCart: () =>
                            _handleAddToCart(dish.id, orderType, cartItem),
                        onIncrement: () => _handleIncrement(dish.id, orderType),
                        onDecrement: () => _handleDecrement(dish.id, orderType),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Other build helpers (unchanged) ---
  Widget _buildRestaurantHeader() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.asset(widget.imageUrl, fit: BoxFit.cover),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset("assets/svg/whitebackArrow.svg",
                      width: 50, height: 50),
                ),
              ),
              _buildBookmarkButton(),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: mapLinearGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _openMap(
                        dish?.restaurant.resturantLatitute,
                        dish?.restaurant.resturantLongitute,
                        name: dish?.restaurant.restaurantName),
                    label: const Text("Map", style: TextStyle(fontSize: 12)),
                    icon: const Icon(
                        IconData(0xf8ca,
                            fontFamily: "CupertinoIcons",
                            fontPackage: "cupertino_icons"),
                        color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${dish?.restaurant.restaurantRating ?? widget.rating}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF4F4F4F))),
              Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
              Text(" | Indian • $_topRatedDishName | 2.3km ",
                  style: const TextStyle(
                      color: Color(0xFF4F4F4F), fontWeight: FontWeight.bold)),
              const Icon(Icons.keyboard_arrow_right_outlined,
                  size: 23, color: Color(0xFF4F4F4F)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return Positioned(
      top: 10,
      right: 10,
      child: Consumer<SavedRestaurantsProvider>(
        builder: (context, savedProvider, child) {
          bool isSaved = savedProvider.isRestaurantSaved(widget.id);
          return GestureDetector(
            onTap: () async {
              final restaurantToSave = SavedRestaurant(
                id: widget.id,
                imageUrl: widget.imageUrl,
                restaurantName: widget.name,
                location: widget.location,
                cuisineType: widget.cuisineType,
                priceRange: widget.priceRange,
                rating: widget.rating,
              );

              if (isSaved) {
                bool? remove = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    titlePadding: const EdgeInsets.only(top: 20, bottom: 5),
                    title: Column(
                      children: [
                        const Icon(Icons.warning_rounded,
                            color: Color(0xFFF8951D), size: 40),
                        const SizedBox(height: 8),
                        Text('Remove Restaurant',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    contentPadding: const EdgeInsets.only(
                        top: 5, left: 24, right: 24, bottom: 20),
                    content: Text('Remove ${widget.name} from saved?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: const Color(0xFF666666))),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(
                                      color: Color(0xFFF8951D), width: 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text('Cancel',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                            color: const Color(0xFFF8951D),
                                            fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFF8951D),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text('Remove',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                if (remove == true) {
                  await savedProvider.toggleSaveRestaurant(restaurantToSave);
                }
              } else {
                await savedProvider.toggleSaveRestaurant(restaurantToSave);
              }
            },
            child: SvgPicture.asset(
              isSaved ? "assets/svg/Saved.svg" : "assets/svg/bookmark.svg",
              width: 50,
              height: 50,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoAndToggleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: const Color(0xffE5E5E5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(widget.priceRange.split(" for")[0],
                    style: const TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold)),
                const Text("for two",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
                height: 55,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: const Color(0xffE5E5E5)))),
            const Column(children: [
              Text("20 mins",
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold)),
              Text("before reaching",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0D000000),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: Offset(0, 2))
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                icon: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child:
                        SvgPicture.asset('assets/svg/search.svg', width: 30)),
                hintText: "Search for Dishes",
                hintStyle: const TextStyle(color: Color(0xff737373)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: SvgPicture.asset('assets/svg/filter.svg', width: 40),
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildFilterButtons(),
      ],
    );
  }

  Widget _buildFilterButtons() {
    final buttonLabels = ["Best Seller", "Top Rated", "Veg", "Non-Veg"];
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
                    isSelected[index] = !isSelected[index];
                    if (index == 2 && isSelected[2]) isSelected[3] = false;
                    if (index == 3 && isSelected[3]) isSelected[2] = false;
                  });
                  _filterDishes();
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
                        width: 1),
                    borderRadius: BorderRadius.circular(30),
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

  Widget _buildSlidingPanel() {
    return GestureDetector(
      onTap: _dismissSlidingScreen,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.3)),
          AnimatedPositioned(
            duration: _animationDuration,
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _offsetAnimation,
              child: GestureDetector(
                onTap: () {},
                child: Consumer2<CartProvider, OrderTypeProvider>(
                  builder: (ctx, cartProvider, orderTypeProvider, child) {
                    final orderType = orderTypeProvider.orderType == 0
                        ? "Dine-in"
                        : "Take-away";
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: FoodItemBottomSheet(
                        name: selectedDish!.dishId.dishName,
                        imageUrl: 'https://via.placeholder.com/100',
                        calories: '120 Cal',
                        quantity: cartProvider.getQuantity(
                            widget.id, orderType, selectedDish!.id),
                        categories: selectedDish!.dishId.dishCatagory,
                        price: selectedDish!.resturantDishPrice.toString(),
                        onAddToCart: () {
                          final cartItem = CartItem(
                              id: selectedDish!.id,
                              restaurantName: widget.name,
                              restaurantImageUrl: widget.imageUrl,
                              orderType: orderType,
                              dish: selectedDish!,
                              quantity: 1,
                              location: widget.location);
                          _handleAddToCart(
                              selectedDish!.id, orderType, cartItem);
                        },
                        onIncrement: () =>
                            _handleIncrement(selectedDish!.id, orderType),
                        onDecrement: () =>
                            _handleDecrement(selectedDish!.id, orderType),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCartBar() {
    return Consumer2<CartProvider, OrderTypeProvider>(
      builder: (ctx, cartProvider, orderTypeProvider, child) {
        final orderType =
            orderTypeProvider.orderType == 0 ? "Dine-in" : "Take-away";
        final totalCount =
            cartProvider.getTotalUniqueItems(widget.id, orderType);

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
    );
  }

  Widget _buildRecommendedDishes() {
    return Consumer2<SelectedCategoryProvider, OrderTypeProvider>(
      builder: (context, categoryProvider, orderTypeProvider, child) {
        if (categoryProvider.selectedCategory.isEmpty) {
          return const SizedBox.shrink();
        }

        List<AvailableDish> recommendedDishes = [];
        _categorizedDishes.forEach((category, dishes) {
          if (category
              .toLowerCase()
              .contains(categoryProvider.selectedCategory.toLowerCase())) {
            recommendedDishes.addAll(dishes);
          }
        });

        if (recommendedDishes.isEmpty) {
          return const SizedBox.shrink();
        }

        final orderType =
            orderTypeProvider.orderType == 0 ? "Dine-in" : "Take-away";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Text(
                categoryProvider.selectedCategory,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 190,
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, _) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendedDishes.length,
                    clipBehavior: Clip.none,
                    itemBuilder: (context, index) {
                      final dish = recommendedDishes[index];
                      final imageUrl = imgurls[index % imgurls.length];

                      return Container(
                        width: 166,
                        margin: const EdgeInsets.only(right: 5),
                        child: DishCard(
                          name: dish.dishId.dishName,
                          price: "₹${dish.resturantDishPrice}",
                          imageUrl: imageUrl,
                          isAvailable: dish.available,
                          calories: "120 cal",
                          quantity: cartProvider.getQuantity(
                              widget.id, orderType, dish.id),
                          onAddToCart: () {
                            final cartItem = CartItem(
                              id: dish.id,
                              restaurantName: widget.name,
                              orderType: orderType,
                              dish: dish,
                              quantity: 1,
                              location: widget.location,
                              restaurantImageUrl: widget.imageUrl,
                            );
                            _handleAddToCart(dish.id, orderType, cartItem);
                          },
                          onIncrement: () =>
                              _handleIncrement(dish.id, orderType),
                          onDecrement: () =>
                              _handleDecrement(dish.id, orderType),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildFilterIcon(int index) {
    if (index == 0) {
      return const Icon(Icons.local_fire_department,
          size: 18, color: Color(0xFFF8951D));
    } else if (index == 1) {
      return const Icon(Icons.star, size: 18, color: Color(0xFF139456));
    } else if (index == 2) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFF36F456), width: 1.5),
        ),
        child: const Center(
            child: Icon(Icons.circle, size: 10, color: Color(0xFF36F456))),
      );
    } else {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFFF44336), width: 1.5),
        ),
        child: const Center(
            child: Icon(Icons.circle, size: 10, color: Color(0xFFF44336))),
      );
    }
  }
}
