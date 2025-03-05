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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SingleRestaurantScreen extends StatefulWidget {
  static const routeName = "/single-restaurant-screen";
  final String name;
  final String location;

  const SingleRestaurantScreen({
    super.key,
    required this.name,
    required this.location,
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

  void _showSlidingScreen(AvailableDish dish) {
    setState(() {
      selectedDish = dish;
      _isVisible = true;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  fetchDishes() async {
    final Connectivity connectivity = Connectivity();
    final NetworkManager networkManager = NetworkManager(connectivity);
    final ApiRepository apiRepository = ApiRepository(networkManager);
    try {
      final fetchData =
          await apiRepository.fetchDishesData(widget.name, widget.location);

      if (fetchData?.statusCode == 200) {
        final data = DishSchema.fromJson(fetchData?.data);
        categorizeAndSetDishes(data);
        setState(() {
          dish = data;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
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
          toolbarHeight: 10,
          backgroundColor: _isVisible ? Colors.black.withOpacity(0.3) : null,
          automaticallyImplyLeading: false, // This will remove the back arrow
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SingleChildScrollView(
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
                                      "assets/images/restaurant.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Back Button
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back_ios_new,
                                          size: 20,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ),
                                  // Bookmark Button
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.bookmark_border,
                                          size: 20,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () {
                                          // Add bookmark functionality here
                                        },
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
                                          onPressed: () {},
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
                              Text(
                                widget.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "${dish?.restaurant.restaurantRating} ★ "),
                                  const Text("Indian · Biryani · 2.3km"),
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
                              horizontal: 30, vertical: 10),
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
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    Text(
                                      "for two",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: const Color(0xffE5E5E5)),
                                  ),
                                ),
                                const Column(children: [
                                  Text(
                                    "20 mins",
                                    style: TextStyle(color: primaryColor),
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.5), // Shadow color
                                  spreadRadius: 2, // How far the shadow spreads
                                  blurRadius: 5, // How blurry the shadow is
                                  offset: const Offset(
                                      0, 3), // Offset in X and Y direction
                                ),
                              ],
                              borderRadius: BorderRadius.circular(
                                  8), // Optional: Rounded corners
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
                                                                  widget.name,
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
                                                                quantity: 1);
                                                            cartProvider
                                                                .addToCart(
                                                                    widget.name,
                                                                    orderType,
                                                                    cartITem);
                                                          },
                                                          onIncrement: () {
                                                            ctx
                                                                .read<
                                                                    CartProvider>()
                                                                .incrementQuantity(
                                                                    widget.name,
                                                                    orderType,
                                                                    dish.id);
                                                          },
                                                          onDecrement: () {
                                                            ctx
                                                                .read<
                                                                    CartProvider>()
                                                                .decrementQuantity(
                                                                    widget.name,
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
                        // Add a similar horizontal list for Main Course Dishes
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20, // Adjust as needed
                    left: 0,
                    right: 0,
                    child: Consumer<CartProvider>(
                        builder: (ctx, cartProvider, child) {
                      int stored = ctx.watch<OrderTypeProvider>().orderType;
                      String orderType = stored == 0 ? "Dine-in" : "Take-away";
                      int totalCount = ctx
                          .watch<CartProvider>()
                          .getTotalUniqueItems(widget.name, orderType);

                      return totalCount > 0
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: AddedItemButton(
                                  itemCount: totalCount,
                                  onPressed: () {
                                    ctx
                                        .read<OrderTypeProvider>()
                                        .changeHomeState(2);
                                    Navigator.pushReplacementNamed(
                                        context, HomePage.routeName);
                                  },
                                ),
                              ),
                            )
                          : const SizedBox
                              .shrink(); // Returns an empty widget if totalCount is 0
                    }),
                  ),
                  if (_isVisible)
                    GestureDetector(
                      onTap: _dismissSlidingScreen, // Dismiss on tap outside
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        children: [
                          // This is the background blur
                          Container(
                            color: Colors.black.withOpacity(
                                0.3), // Optional: add slight dark overlay
                          ),

                          // This is the bottom sheet content
                          AnimatedPositioned(
                              duration: const Duration(
                                  milliseconds:
                                      300), // Keep the duration for bottom sheet slide
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
                                      return FoodItemBottomSheet(
                                        name: selectedDish!.dishId.dishName,
                                        imageUrl: '',
                                        calories: '120',
                                        quantity: ctx
                                            .watch<CartProvider>()
                                            .getQuantity(widget.name, orderType,
                                                selectedDish!.id),
                                        onAddToCart: () {
                                          final cartProvider =
                                              Provider.of<CartProvider>(context,
                                                  listen: false);

                                          final cartITem = CartItem(
                                              id: selectedDish!.id,
                                              restaurantName: widget.name,
                                              orderType: orderType,
                                              dish: selectedDish!,
                                              quantity: 1);
                                          cartProvider.addToCart(
                                              widget.name, orderType, cartITem);
                                        },
                                        onIncrement: () {
                                          ctx
                                              .read<CartProvider>()
                                              .incrementQuantity(widget.name,
                                                  orderType, selectedDish!.id);
                                        },
                                        onDecrement: () {
                                          ctx
                                              .read<CartProvider>()
                                              .decrementQuantity(widget.name,
                                                  orderType, selectedDish!.id);
                                        },
                                        categories:
                                            selectedDish!.dishId.dishCatagory,
                                        price: selectedDish!.resturantDishPrice
                                            .toString(),
                                      );
                                    })),
                              )),
                        ],
                      ),
                    ),
                ],
              ));
  }
}
