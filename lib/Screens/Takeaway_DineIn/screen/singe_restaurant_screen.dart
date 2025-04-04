import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatit/Screens/Takeaway_DineIn//widget/dish_card_widget.dart';
import 'package:eatit/Screens/Takeaway_DineIn//widget/single_dish.dart';
import 'package:eatit/Screens/Takeaway_DineIn//widget/toggle_widget.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/added_item.dart';
import 'package:eatit/Screens/homes/screen/home_screen.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/models/dish_retaurant.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:eatit/Screens/cart_screen/screen/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class SingleRestaurantScreen extends StatefulWidget {
  static const routeName = "/single-restaurant-screen";
  final String name;
  final String location;
  final String id;

  const SingleRestaurantScreen({
    super.key,
    required this.name,
    required this.location,
    required this.id,
  });

  @override
  State<StatefulWidget> createState() => _SingleRestaurantScreen();
}

class _SingleRestaurantScreen extends State<SingleRestaurantScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  List<String> imgurls = [
    "assets/images/burgers.png",
    "assets/images/pizza.png",
    "assets/images/healthy.png",
    "assets/images/home_style.png",
    "assets/images/chicken.png"
  ];
  bool _isVisible = false;
  DishSchema? dish;
  AvailableDish? selectedDish;
  bool isLoading = true; // Loading indicator flag
  DishSchema? filterDishes;
  final Map<String, List<AvailableDish>> categorizedDishes = {};
  String errorMessage = ''; // S
  var screenWidth = 0.0;
  var textTheme;
  String searchQuery = ''; // Track search query
  final TextEditingController _searchController = TextEditingController();
  // Add CancelToken for API requests
  final CancelToken _cancelToken = CancelToken();

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
    _filterDishes();
  }

  void _filterDishes() {
    setState(() {
      if (searchQuery.isEmpty) {
        // If the search query is empty, show all available dishes
        filterDishes = dish;
        categorizeAndSetDishes(dish);
      } else {
        // Filter available dishes by dish name or category based on the search query
        List<AvailableDish> filteredDishes = dish?.availableDishes
                .where((d) => d.dishId.dishName
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList() ??
            [];

        // Update the filterDishes DishSchema with the filtered available dishes
        filterDishes = DishSchema(
          restaurant: dish!.restaurant,
          availableDishes: filteredDishes,
          categories: dish!.categories,
        );
        categorizeAndSetDishes(filterDishes);
      }
    });
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

  @override
  void dispose() {
    // Make sure animation controller is properly disposed
    _controller.stop();
    _controller.dispose();

    // Cancel any ongoing API requests
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel("Widget disposed");
    }

    // Dispose of text controller
    _searchController.removeListener(_updateSearchQuery);
    _searchController.dispose();

    // Clear large data structures
    dish = null;
    filterDishes = null;
    selectedDish = null;
    categorizedDishes.clear();

    super.dispose();
  }

  fetchDishes() async {
    if (_cancelToken.isCancelled) return;

    final Connectivity connectivity = Connectivity();
    final NetworkManager networkManager = NetworkManager(connectivity);
    final ApiRepository apiRepository = ApiRepository(networkManager);
    try {
      final fetchData = await apiRepository.fetchDishesDataWithCancelToken(
          widget.name, widget.location, _cancelToken);

      if (fetchData?.statusCode == 200 && !_cancelToken.isCancelled) {
        final data = DishSchema.fromJson(fetchData?.data);
        categorizeAndSetDishes(data);
        if (mounted) {
          setState(() {
            dish = data;
          });
        }
      }
    } catch (e) {
      if (mounted && !_cancelToken.isCancelled) {
        _showErrorDialog("Error", "An error occurred while fetching data.");
        setState(() {
          errorMessage = "Error: $e";
          isLoading = false;
        });
      }
    }
  }

  void categorizeAndSetDishes(DishSchema? data) {
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
    setState(() {
      filterDishes = data;
      isLoading = false;
    });
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
                SingleChildScrollView(
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
                                  SizedBox(
                                    width: double.infinity,
                                    height: 200,
                                    child: Image.asset(
                                      "assets/images/singerestaurant.png",
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
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Your onTap functionality here
                                      },
                                      child: SvgPicture.asset(
                                        "assets/svg/bookmark.svg",
                                        width: 50,
                                        height: 50,
                                      ),
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
                                              name: dish
                                                  ?.restaurant.restaurantName),
                                          label: const Text("Map",
                                              style: TextStyle(fontSize: 12)),
                                          icon: const Icon(
                                            IconData(0xf8ca,
                                                fontFamily: "CupertinoIcons",
                                                fontPackage: "cupertino_icons"),
                                            color: Colors.white,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
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
                                  const Text(
                                    " | Indian • Biryani | 2.3km ",
                                    style: TextStyle(
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Column(
                                  children: [
                                    Text(
                                      "₹1200-₹1500",
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: primaryColor, // Search icon color
                                ),
                                hintText: "Search for Dishes",
                                hintStyle: const TextStyle(
                                  color: Color(0xff737373),
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'Nunito Sans',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Match with the container
                                  borderSide: BorderSide.none, // No border
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Dishes Categories
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : (errorMessage.isNotEmpty
                                ? Center(child: Text(errorMessage))
                                : Column(
                                    children:
                                        categorizedDishes.entries.map((entry) {
                                      String category = entry.key;
                                      List<AvailableDish> dishes = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                                height:
                                                    220, // Adjust based on your UI needs
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Consumer<CartProvider>(
                                                    builder: (ctx, cartProvider,
                                                        child) {
                                                  return ListView.builder(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: dishes.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final dish =
                                                          dishes[index];
                                                      int stored = ctx
                                                          .watch<
                                                              OrderTypeProvider>()
                                                          .orderType;
                                                      String orderType = "";
                                                      if (stored == 0) {
                                                        orderType = "Dine-in";
                                                      } else {
                                                        orderType = "Take-away";
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
                                                        onTap: () =>
                                                            _showSlidingScreen(
                                                                dish),
                                                        child: DishCard(
                                                          name: dish
                                                              .dishId.dishName,
                                                          price:
                                                              "₹${dish.resturantDishPrice}",
                                                          imageUrl: imgurls[
                                                              index % 5],
                                                          calories: "120 cal",
                                                          quantity: (ctx
                                                              .watch<
                                                                  CartProvider>()
                                                              .getQuantity(
                                                                  widget.id,
                                                                  orderType,
                                                                  dish.id)),
                                                          // Default to 0 if cartItem.quantity is null
                                                          onAddToCart: () {
                                                            final cartProvider =
                                                                Provider.of<
                                                                        CartProvider>(
                                                                    context,
                                                                    listen:
                                                                        false);

                                                            final cartITem = CartItem(
                                                                id: dish.id,
                                                                restaurantName:
                                                                    widget.name,
                                                                orderType:
                                                                    orderType,
                                                                dish: dish,
                                                                quantity: 1,
                                                                location: widget
                                                                    .location);
                                                            cartProvider
                                                                .addToCart(
                                                                    widget.id,
                                                                    orderType,
                                                                    cartITem);
                                                          },
                                                          onIncrement: () {
                                                            ctx
                                                                .read<
                                                                    CartProvider>()
                                                                .incrementQuantity(
                                                                    widget.id,
                                                                    orderType,
                                                                    dish.id);
                                                          },
                                                          onDecrement: () {
                                                            ctx
                                                                .read<
                                                                    CartProvider>()
                                                                .decrementQuantity(
                                                                    widget.id,
                                                                    orderType,
                                                                    dish.id);
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
                                        onAddToCart: () {
                                          final cartProvider =
                                              Provider.of<CartProvider>(context,
                                                  listen: false);

                                          final cartITem = CartItem(
                                              id: selectedDish!.id,
                                              restaurantName: widget.name,
                                              orderType: orderType,
                                              dish: selectedDish!,
                                              quantity: 1,
                                              location: widget.location);
                                          cartProvider.addToCart(
                                              widget.id, orderType, cartITem);
                                        },
                                        onIncrement: () {
                                          ctx
                                              .read<CartProvider>()
                                              .incrementQuantity(widget.id,
                                                  orderType, selectedDish!.id);
                                        },
                                        onDecrement: () {
                                          ctx
                                              .read<CartProvider>()
                                              .decrementQuantity(widget.id,
                                                  orderType, selectedDish!.id);
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
}
